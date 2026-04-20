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

  ChatProvider() {
    // When Provider is instantiated, we can't initialize socket without token
    // We should initialize socket manually when user authenticates
  }

  void initializeSocket(String token) {
    _socketService.initSocket(token);
    _socketService.onMessageReceived((data) {
      final newMessage = ChatMessage.fromJson(data);

      // Check if this message belongs to the currently open conversation
      final matchesAgency = (newMessage.receiverAgencyId != null && 'agency-${newMessage.receiverAgencyId}' == _activeEntityId);
      final matchesSender = newMessage.senderId?.toString() == _activeEntityId ||
          newMessage.receiverId?.toString() == _activeEntityId ||
          matchesAgency;
      final matchesProduct = _activeProductId == null || newMessage.productId == _activeProductId;

      if (_activeEntityId != null && matchesSender && matchesProduct) {
        // Avoid duplicates (own sent messages are added immediately in sendMessage)
        final alreadyExists = _currentMessages.any((m) => m.id == newMessage.id);
        if (!alreadyExists) {
          _currentMessages.add(newMessage);
          notifyListeners();
          // Trigger scroll-to-bottom callback on the open ChatScreen
          onNewMessageReceived?.call();
        }
      }

      // Always refresh the inbox list to update previews / unread counts
      loadConversations();
    });
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
        (c.senderId.toString() == entityId || c.receiverId.toString() == entityId || 'agency-${c.agencyIdResolved}' == entityId) && 
        c.productId == productId
      );
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
  }) async {
    _isSending = true;
    _error = null;
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

      _currentMessages.add(sentMessage);
      
      // Optimistically fetch conversations to update the latest message preview
      loadConversations();
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
