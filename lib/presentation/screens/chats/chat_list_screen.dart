import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch newly if we want, or just rely on global state + pull-to-refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatProvider>().loadConversations();
    });
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.isLoadingConversations && chatProvider.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          if (chatProvider.error != null && chatProvider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${chatProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => chatProvider.loadConversations(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (chatProvider.conversations.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => chatProvider.loadConversations(),
            color: AppTheme.primaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chatProvider.conversations.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 76, right: 16),
                child: Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300),
              ),
              itemBuilder: (context, index) {
                return _buildChatTile(context, chatProvider.conversations[index], chatProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 70, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'No messages yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            'When you contact a seller or receive a\nmessage, it will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, dynamic chat, ChatProvider provider) {
    final bool isUnread = chat.unreadCount > 0;
    
    final currentUserId = context.read<AuthProvider>().user?.id;
    final isMeSender = chat.senderId == currentUserId;
    final otherUserId = isMeSender ? chat.receiverId : chat.senderId;
    final otherUserName = isMeSender ? chat.receiverName : chat.senderName;
    // Use real avatar from API, fall back to generated initials avatar
    final realAvatar = isMeSender ? chat.receiverAvatar : chat.senderAvatar;
    final avatarUrl = (realAvatar != null && realAvatar.isNotEmpty)
        ? realAvatar
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(otherUserName)}&background=4A7C59&color=fff';
    final entityId = isMeSender
        ? chat.isAgencyChat ? 'agency-${chat.agencyIdResolved}' : chat.receiverId.toString()
        : chat.isAgencyChat ? 'agency-${chat.agencyIdResolved}' : chat.senderId.toString();

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatData: {
                'rawId': chat.id,
                'otherUserId': entityId,
                'name': otherUserName,
                'productId': chat.productId,
                'productTitle': chat.productTitle,
                'productPrice': chat.productPrice,
                'productImage': chat.productImage,
                'avatarUrl': avatarUrl,
                'isAgencyChat': chat.isAgencyChat,
                'agencyIdResolved': chat.agencyIdResolved,
              },
            ),
          ),
        );
        provider.loadConversations();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (_, __) {},
              child: null,
            ),
            const SizedBox(width: 16),
            
            // Middle Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (chat.productId == null)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.support_agent, size: 14, color: Colors.blue),
                        ),
                      Expanded(
                        child: Text(
                          chat.message ?? (chat.attachmentUrl != null ? 'Image Attachment' : ''),
                          style: TextStyle(
                            fontSize: 14,
                            color: isUnread ? Colors.black87 : Colors.grey.shade600,
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(chat.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnread ? AppTheme.secondaryColor : Colors.grey.shade500,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                if (isUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        chat.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
