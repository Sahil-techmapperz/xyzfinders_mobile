import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_modal.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';
import '../../../data/services/socket_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  bool _hasLoadedChats = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isAuth = Provider.of<AuthProvider>(context).isAuthenticated;
    if (isAuth && !_hasLoadedChats) {
      _hasLoadedChats = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ChatProvider>().loadConversations();
        }
      });
    } else if (!isAuth) {
      _hasLoadedChats = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateStr) {
    try {
      final date = dateStr.toLocal();
      final now = DateTime.now();
      
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(date.year, date.month, date.day);
      
      final timeString = DateFormat('h:mm a').format(date);
      
      if (messageDate == today) {
        return timeString;
      } else if (messageDate == yesterday) {
        return 'Yesterday';
      } else {
        return DateFormat('d MMM').format(date);
      }
    } catch (_) {
      return '';
    }
  }

  void _showDebugDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final logs = List<String>.from(SocketService.debugLogs.reversed);
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('App Debug Logs'),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _showDebugDialog(context);
                },
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: logs.isEmpty
                ? const Center(child: Text('No debug logs captured yet.'))
                : ListView.separated(
                    itemCount: logs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          logs[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SocketService.debugLogs.clear();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Clear Logs'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Chats', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 22)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 120, color: Colors.grey.shade300),
                const SizedBox(height: 32),
                const Text(
                  'Log in to view your messages',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chat with sellers, ask questions, and make deals.',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade500, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => AuthModal.show(context, initialIsLogin: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Log In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              )
            : GestureDetector(
                onDoubleTap: () => _showDebugDialog(context),
                child: const Text(
                  'Chats',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black87),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
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

          final searchQuery = _searchController.text.trim().toLowerCase();
          final filteredConversations = chatProvider.conversations.where((chat) {
            if (searchQuery.isEmpty) return true;
            
            final currentUserId = context.read<AuthProvider>().user?.id?.toString();
            final isMeSender = chat.senderId?.toString() == currentUserId;
            final otherUserName = isMeSender ? chat.receiverName : chat.senderName;
            
            final nameMatch = (otherUserName?.toLowerCase() ?? '').contains(searchQuery);
            final productMatch = (chat.productTitle?.toLowerCase() ?? '').contains(searchQuery);
            
            return nameMatch || productMatch;
          }).toList();

          if (filteredConversations.isEmpty && searchQuery.isNotEmpty) {
            return Center(
              child: Text(
                'No chats found for "$searchQuery"',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => chatProvider.loadConversations(),
            color: AppTheme.primaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredConversations.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 76, right: 16),
                child: Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300),
              ),
              itemBuilder: (context, index) {
                return _buildChatTile(context, filteredConversations[index], chatProvider);
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
    
    final currentUserId = context.read<AuthProvider>().user?.id?.toString();
    final isMeSender = chat.senderId?.toString() == currentUserId;
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
