import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/chat_model.dart';
import '../../data/services/chat_service.dart';
import '../../data/services/socket_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final SocketService _socketService = SocketService();

  List<Conversation> _conversations = [];
  List<ChatMessage> _currentMessages = [];
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _error;

  // Track the active open conversation so socket messages go to the right place
  String? _activeEntityId;
  int? _activeProductId;
  VoidCallback? onNewMessageReceived;

  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get currentMessages => _currentMessages;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String? get error => _error;

  int get totalUnreadCount {
    return _conversations.fold(0, (sum, item) => sum + item.unreadCount);
  }

  void initializeSocket(String token, {String? userId, String? agencyId}) {
    // ALWAYS unregister old listener before registering a new one
    // This prevents stacking of duplicate handlers across re-logins / re-inits
    _socketService.offMessageReceived();
    _socketService.offMessagesRead();
    _socketService.offMessageDelivered();

    _socketService.initSocket(token);

    if (userId != null) {
      _socketService.joinUser(userId);
    }
    if (agencyId != null) {
      _socketService.joinAgency(agencyId);
    }

    _socketService.onMessageReceived((data) {
      _handleIncomingMessage(data);
    });

    _socketService.onMessagesRead((data) {
      _handleMessagesRead(data);
    });

    _socketService.onMessageDelivered((data) {
      _handleMessageDelivered(data);
    });
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      SocketService.log('Raw incoming message data: $data');
      if (data == null) {
        SocketService.log('Warning: Received null message data');
        return;
      }
      
      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(data as Map);
      final newMessage = ChatMessage.fromJson(jsonMap);
      SocketService.log('Parsed incoming message: ID=${newMessage.id}, text="${newMessage.message}"');

      // 1. Mark as delivered in DB immediately!
      _chatService.markAsDelivered(newMessage.id);

      // 2. Emit socket delivery receipt back to the sender
      final currentUserId = newMessage.receiverId?.toString();
      if (currentUserId != null) {
        _socketService.emitMessageDelivered(
          messageId: newMessage.id,
          senderId: newMessage.senderId!.toString(),
          receiverId: currentUserId,
          productId: newMessage.productId,
        );
      }

      // --- 3. Update the open ChatScreen if this message belongs to it ---
      if (_activeEntityId != null) {
        final matchesAgency = newMessage.receiverAgencyId != null &&
            'agency-${newMessage.receiverAgencyId}' == _activeEntityId;
        final matchesSender = newMessage.senderId?.toString() == _activeEntityId ||
            newMessage.receiverId?.toString() == _activeEntityId ||
            matchesAgency;
        final matchesProduct =
            _activeProductId == null || newMessage.productId == _activeProductId;

        SocketService.log('Active check: entityId=$_activeEntityId, productId=$_activeProductId, matchesSender=$matchesSender, matchesProduct=$matchesProduct');

        if (matchesSender && matchesProduct) {
          // Avoid duplicates — sender's own message was already added optimistically
          final alreadyExists = _currentMessages.any((m) => m.id == newMessage.id);
          if (!alreadyExists) {
            _currentMessages.add(newMessage);

            // Mark this specific message as read in DB
            _chatService.markAsRead(newMessage.id);

            // Emit read receipt so the sender knows we read it immediately
            if (currentUserId != null) {
              _socketService.emitMessagesRead(
                senderId: _activeEntityId!,
                receiverId: currentUserId,
                productId: _activeProductId,
              );
            }

            notifyListeners();
            onNewMessageReceived?.call();
            SocketService.log('Message added to current active messages list');
          } else {
            SocketService.log('Message already exists in current list, skipping');
          }
          // Don't return here — also update the conversations list below
        }
      }

      // --- 4. Update the chat list in-memory (no API call needed) ---
      _updateConversationPreview(newMessage);
    } catch (e, stackTrace) {
      SocketService.log('Error handling incoming message: $e\n$stackTrace');
    }
  }

  void _handleMessagesRead(dynamic data) {
    try {
      SocketService.log('Received read receipt: $data');
      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(data as Map);
      final String otherUserId = jsonMap['receiverId'].toString(); // the user who read our messages
      final dynamic rawProductId = jsonMap['productId'];
      final int? productId = rawProductId != null ? int.tryParse(rawProductId.toString()) : null;

      if (_activeEntityId == otherUserId && _activeProductId == productId) {
        _currentMessages = _currentMessages.map((m) {
          // If the message is sent by me (not the other user), set isRead to true
          if (m.senderId?.toString() != _activeEntityId) {
            return ChatMessage(
              id: m.id,
              productId: m.productId,
              senderId: m.senderId,
              receiverId: m.receiverId,
              receiverAgencyId: m.receiverAgencyId,
              message: m.message,
              attachmentUrl: m.attachmentUrl,
              isRead: true,
              isDelivered: true,
              createdAt: m.createdAt,
              senderName: m.senderName,
              receiverName: m.receiverName,
              agencyName: m.agencyName,
              agencyLogo: m.agencyLogo,
              isAgencyChat: m.isAgencyChat,
              reportId: m.reportId,
            );
          }
          return m;
        }).toList();
        notifyListeners();
        SocketService.log('Marked sent messages as READ in active window');
      }
    } catch (e) {
      SocketService.log('Error handling read receipt: $e');
    }
  }

  void _handleMessageDelivered(dynamic data) {
    try {
      SocketService.log('Received delivery receipt: $data');
      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(data as Map);
      final String otherUserId = jsonMap['receiverId'].toString(); // the user who received our message
      final dynamic rawProductId = jsonMap['productId'];
      final int? productId = rawProductId != null ? int.tryParse(rawProductId.toString()) : null;
      final int messageId = jsonMap['messageId'] as int;

      if (_activeEntityId == otherUserId && _activeProductId == productId) {
        _currentMessages = _currentMessages.map((m) {
          // If this is the specific message that was delivered and is NOT currently read
          if (m.id == messageId && !m.isRead) {
            return ChatMessage(
              id: m.id,
              productId: m.productId,
              senderId: m.senderId,
              receiverId: m.receiverId,
              receiverAgencyId: m.receiverAgencyId,
              message: m.message,
              attachmentUrl: m.attachmentUrl,
              isRead: m.isRead,
              isDelivered: true,
              createdAt: m.createdAt,
              senderName: m.senderName,
              receiverName: m.receiverName,
              agencyName: m.agencyName,
              agencyLogo: m.agencyLogo,
              isAgencyChat: m.isAgencyChat,
              reportId: m.reportId,
            );
          }
          return m;
        }).toList();
        notifyListeners();
        SocketService.log('Marked message ID $messageId as DELIVERED in active window');
      }
    } catch (e) {
      SocketService.log('Error handling delivery receipt: $e');
    }
  }

  /// Updates the conversation list in-memory when a new socket message arrives.
  /// This avoids a slow API round-trip just to refresh the preview text.
  void _updateConversationPreview(ChatMessage newMessage) {
    final idx = _conversations.indexWhere((c) {
      // Match by the participants involved in this message
      final senderMatch = c.senderId?.toString() == newMessage.senderId?.toString() ||
          c.senderId?.toString() == newMessage.receiverId?.toString();
      final receiverMatch = c.receiverId?.toString() == newMessage.senderId?.toString() ||
          c.receiverId?.toString() == newMessage.receiverId?.toString();
      final agencyMatch = newMessage.receiverAgencyId != null &&
          c.agencyIdResolved == newMessage.receiverAgencyId;
      final productMatch = c.productId == newMessage.productId;
      return (senderMatch || receiverMatch || agencyMatch) && productMatch;
    });

    if (idx != -1) {
      final existing = _conversations[idx];
      // Build updated conversation with the new message preview & incremented unread
      final updated = Conversation(
        id: existing.id,
        productId: existing.productId,
        productTitle: existing.productTitle,
        productPrice: existing.productPrice,
        productImage: existing.productImage,
        senderId: existing.senderId,
        senderName: existing.senderName,
        senderAvatar: existing.senderAvatar,
        receiverId: existing.receiverId,
        receiverName: existing.receiverName,
        receiverAvatar: existing.receiverAvatar,
        agencyName: existing.agencyName,
        agencyLogo: existing.agencyLogo,
        isAgencyChat: existing.isAgencyChat,
        agencyIdResolved: existing.agencyIdResolved,
        // Increment unread only if this chat is NOT the currently open one
        unreadCount: (_activeEntityId != null &&
                (existing.senderId?.toString() == _activeEntityId ||
                    existing.receiverId?.toString() == _activeEntityId ||
                    'agency-${existing.agencyIdResolved}' == _activeEntityId))
            ? 0
            : existing.unreadCount + 1,
        message: newMessage.message.isNotEmpty
            ? newMessage.message
            : (newMessage.attachmentUrl != null ? '📷 Image' : existing.message),
        attachmentUrl: newMessage.attachmentUrl ?? existing.attachmentUrl,
        isRead: false,
        createdAt: newMessage.createdAt,
      );
      // Move updated conversation to the top
      _conversations.removeAt(idx);
      _conversations.insert(0, updated);
    } else {
      // New conversation not yet in list — do a full refresh from API
      loadConversations();
      return;
    }

    notifyListeners();
  }

  void clearActiveConversation() {
    _activeEntityId = null;
    _activeProductId = null;
    onNewMessageReceived = null;
  }

  void disposeSocket() {
    _socketService.offMessageReceived();
    _socketService.disconnect();
  }

  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _chatService.getConversations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages({required String entityId, int? productId}) async {
    _activeEntityId = entityId;
    _activeProductId = productId;
    _isLoadingMessages = true;
    _error = null;
    _currentMessages = [];
    notifyListeners();

    try {
      _currentMessages = await _chatService.getMessages(entityId: entityId, productId: productId);

      // Clear unread counts for this specific conversation in the list locally
      final idx = _conversations.indexWhere((c) =>
          (c.senderId.toString() == entityId ||
              c.receiverId.toString() == entityId ||
              'agency-${c.agencyIdResolved}' == entityId) &&
          c.productId == productId);
      if (idx != -1) {
        final existing = _conversations[idx];
        _conversations[idx] = Conversation(
          id: existing.id,
          productId: existing.productId,
          productTitle: existing.productTitle,
          productPrice: existing.productPrice,
          productImage: existing.productImage,
          senderId: existing.senderId,
          senderName: existing.senderName,
          receiverId: existing.receiverId,
          receiverName: existing.receiverName,
          agencyName: existing.agencyName,
          agencyLogo: existing.agencyLogo,
          isAgencyChat: existing.isAgencyChat,
          agencyIdResolved: existing.agencyIdResolved,
          unreadCount: 0,
          message: existing.message,
          attachmentUrl: existing.attachmentUrl,
          isRead: true,
          createdAt: existing.createdAt,
        );
      }

      // Emit read status to the server so the other user knows we've read their messages!
      if (_currentMessages.isNotEmpty) {
        final firstMsg = _currentMessages.first;
        String? currentUserId;
        if (firstMsg.senderId?.toString() == entityId) {
          currentUserId = firstMsg.receiverId?.toString();
        } else {
          currentUserId = firstMsg.senderId?.toString();
        }
        if (currentUserId != null) {
          _socketService.emitMessagesRead(
            senderId: entityId,
            receiverId: currentUserId,
            productId: productId,
          );
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage({
    int? productId,
    String? receiverId,
    String? receiverAgencyId,
    String? message,
    File? attachment,
    int? senderId,
  }) async {
    _isSending = true;
    _error = null;

    final tempId = -(DateTime.now().millisecondsSinceEpoch);
    final optimisticMsg = ChatMessage(
      id: tempId,
      productId: productId,
      senderId: senderId,
      receiverId: receiverId != null ? int.tryParse(receiverId) : null,
      receiverAgencyId: receiverAgencyId != null ? int.tryParse(receiverAgencyId) : null,
      message: message ?? '',
      attachmentUrl: attachment?.path,
      isRead: false,
      createdAt: DateTime.now(),
      senderName: 'Me',
      receiverName: '',
      isAgencyChat: receiverAgencyId != null,
    );

    _currentMessages.add(optimisticMsg);
    onNewMessageReceived?.call();
    notifyListeners();

    try {
      String? attachmentUrl;
      if (attachment != null) {
        attachmentUrl = await _chatService.uploadChatAttachment(attachment);
      }

      final sentMessage = await _chatService.sendMessage(
        productId: productId,
        receiverId: receiverId,
        receiverAgencyId: receiverAgencyId,
        message: message,
        attachmentUrl: attachmentUrl,
      );

      // Replace the optimistic placeholder with the real persisted message
      final index = _currentMessages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        _currentMessages[index] = sentMessage;
      } else {
        _currentMessages.add(sentMessage);
      }

      SocketService.log('API message sent successfully, ID=${sentMessage.id}');

      // Emit via socket so the RECEIVER gets it instantly
      if (receiverAgencyId != null) {
        SocketService.log('Emitting emitAgencyMessage to agency_$receiverAgencyId');
        _socketService.emitAgencyMessage(
            agencyId: receiverAgencyId, message: sentMessage.toJson());
      } else if (receiverId != null) {
        SocketService.log('Emitting emitUserMessage to user_$receiverId');
        _socketService.emitUserMessage(
            receiverId: receiverId, message: sentMessage.toJson());
      }

      // Update conversation preview locally for the sender
      _updateConversationPreview(sentMessage);

      return true;
    } catch (e, stackTrace) {
      SocketService.log('Error sending message: $e\n$stackTrace');
      _currentMessages.removeWhere((m) => m.id == tempId);
      _error = e.toString();
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
