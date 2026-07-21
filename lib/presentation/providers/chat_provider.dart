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
  }

  void _handleIncomingMessage(dynamic data) {
    final newMessage = ChatMessage.fromJson(data as Map<String, dynamic>);

    // --- 1. Update the open ChatScreen if this message belongs to it ---
    if (_activeEntityId != null) {
      final matchesAgency = newMessage.receiverAgencyId != null &&
          'agency-${newMessage.receiverAgencyId}' == _activeEntityId;
      final matchesSender = newMessage.senderId?.toString() == _activeEntityId ||
          newMessage.receiverId?.toString() == _activeEntityId ||
          matchesAgency;
      final matchesProduct =
          _activeProductId == null || newMessage.productId == _activeProductId;

      if (matchesSender && matchesProduct) {
        // Avoid duplicates — sender's own message was already added optimistically
        final alreadyExists = _currentMessages.any((m) => m.id == newMessage.id);
        if (!alreadyExists) {
          _currentMessages.add(newMessage);
          notifyListeners();
          onNewMessageReceived?.call();
        }
        // Don't return here — also update the conversations list below
      }
    }

    // --- 2. Update the chat list in-memory (no API call needed) ---
    _updateConversationPreview(newMessage);
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
        senderId: newMessage.senderId,
        senderName: newMessage.senderName,
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

      // Emit via socket so the RECEIVER gets it instantly
      if (receiverAgencyId != null) {
        _socketService.emitAgencyMessage(
            agencyId: receiverAgencyId, message: sentMessage.toJson());
      } else if (receiverId != null) {
        _socketService.emitUserMessage(
            receiverId: receiverId, message: sentMessage.toJson());
      }

      // Update conversation preview locally for the sender
      _updateConversationPreview(sentMessage);

      return true;
    } catch (e) {
      _currentMessages.removeWhere((m) => m.id == tempId);
      _error = e.toString();
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
