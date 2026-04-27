import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../../data/models/chat_model.dart';
import '../../../../core/constants/api_constants.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;

  const ChatScreen({super.key, required this.chatData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  ChatProvider? _chatProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final String entityId = widget.chatData['otherUserId'];
      final int? productId = widget.chatData['productId'];
      _chatProvider = context.read<ChatProvider>();
      _chatProvider!.loadMessages(entityId: entityId, productId: productId);
      // Register scroll callback so incoming socket messages scroll into view
      _chatProvider!.onNewMessageReceived = () {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      };
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Safe: using cached reference, NOT context.read() which is illegal in dispose()
    _chatProvider?.clearActiveConversation();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final hasImage = _selectedImage != null;
    
    if (text.isEmpty && !hasImage) return;

    final provider = context.read<ChatProvider>();
    final isAgencyChat = widget.chatData['isAgencyChat'] == true;
    final otherUserId = widget.chatData['otherUserId'].toString();
    final receiverId = !isAgencyChat ? otherUserId : null;
    final receiverAgencyId = isAgencyChat ? widget.chatData['agencyIdResolved']?.toString() : null;

    final success = await provider.sendMessage(
      productId: widget.chatData['productId'],
      receiverId: receiverId,
      receiverAgencyId: receiverAgencyId,
      message: text,
      attachment: _selectedImage,
    );

    if (success) {
      setState(() {
         _messageController.clear();
         _selectedImage = null;
      });
      _scrollToBottom();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to send message')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // reverse:true means 0.0 is the bottom (newest message)
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  String _formatTime(DateTime dateStr) {
    try {
      final date = dateStr.toLocal();
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.chatData['name'] as String? ?? 'User';
    final String avatarUrl = widget.chatData['avatarUrl'] as String? ?? '';
    final bool isOnline = widget.chatData['isOnline'] as bool? ?? false;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(name, avatarUrl, isOnline),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoadingMessages && chatProvider.currentMessages.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          final messages = chatProvider.currentMessages.reversed.toList();

          return Column(
            children: [
              if (widget.chatData['productId'] != null)
                 _buildProductBanner(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Newest messages at the bottom
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              _buildMessageInput(chatProvider.isSending),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductBanner() {
    final title = widget.chatData['productTitle'] ?? 'Product';
    final price = widget.chatData['productPrice'] ?? '';
    final image = widget.chatData['productImage'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildProductImage(image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (price.toString().isNotEmpty)
                  Text(
                    price.toString(),
                    style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              foregroundColor: AppTheme.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('View', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(dynamic image) {
    if (image == null) return const Icon(Icons.image_outlined, color: Colors.grey);
    
    if (image is String) {
      if (image.startsWith('http')) {
        return Image.network(image, fit: BoxFit.cover);
      }
      try {
        final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
        return Image.network('$baseUrl$image', fit: BoxFit.cover);
      } catch (_) {
        return const Icon(Icons.image_outlined, color: Colors.grey);
      }
    }
    return const Icon(Icons.image_outlined, color: Colors.grey);
  }

  PreferredSizeWidget _buildAppBar(String name, String avatarUrl, bool isOnline) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: avatarUrl.isEmpty ? const Icon(Icons.person, color: AppTheme.primaryColor) : null,
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isOnline ? 'Active Now' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final currentUserId = context.read<AuthProvider>().user?.id;
    final bool isMe = message.senderId == currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              border: isMe ? null : Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isMe ? 0.1 : 0.02),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.attachmentUrl != null)
                   Padding(
                     padding: const EdgeInsets.only(bottom: 8.0),
                     child: ClipRRect(
                       borderRadius: BorderRadius.circular(12),
                       child: CachedNetworkImage(
                         imageUrl: message.attachmentUrl!,
                         placeholder: (context, url) => Container(
                           width: 200,
                           height: 150,
                           color: Colors.grey.shade200,
                           child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                         ),
                         errorWidget: (context, url, error) => const Icon(Icons.error),
                         fit: BoxFit.cover,
                         width: 200,
                       ),
                     ),
                   ),
                if (message.message.isNotEmpty)
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isSending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedImage != null)
               _buildImagePreview(),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline, 
                    color: _selectedImage != null ? AppTheme.primaryColor : Colors.grey
                  ),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: isSending 
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_selectedImage!, height: 90, width: 90, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
               onTap: () => setState(() => _selectedImage = null),
               child: Container(
                 padding: const EdgeInsets.all(4),
                 decoration: const BoxDecoration(
                   color: Colors.red,
                   shape: BoxShape.circle,
                 ),
                 child: const Icon(Icons.close, size: 16, color: Colors.white),
               ),
            ),
          ),
        ],
      ),
    );
  }
}
