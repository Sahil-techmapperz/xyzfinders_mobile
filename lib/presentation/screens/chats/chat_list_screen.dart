import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'chat_screen.dart';
import '../../../../core/config/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getInt(AppConstants.userIdKey);

      final response = await ApiService().get(ApiConstants.conversations);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        
        final parsedChats = data.map((c) {
          final isMeSender = c['sender_id'] == _currentUserId;
          final otherUserId = isMeSender ? c['receiver_id'] : c['sender_id'];
          final otherUserName = isMeSender ? c['receiver_name'] : c['sender_name'];
          
          return {
            'rawId': c['id'],
            'otherUserId': otherUserId,
            'name': otherUserName ?? 'Unknown User',
            'lastMessage': c['message'] ?? '',
            'time': _formatTime(c['created_at']),
            'unreadCount': c['unread_count'] ?? 0,
            'productId': c['product_id'],
            'productTitle': c['product_title'],
            'productPrice': c['product_price'],
            'productImage': c['product_image'],
            'avatarUrl': 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(otherUserName ?? 'U')}&background=random',
          };
        }).toList();

        if (mounted) {
          setState(() {
            _chats = parsedChats.isEmpty ? _getDemoChats() : parsedChats;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _chats = _getDemoChats();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
      if (mounted) {
        setState(() {
          _chats = _getDemoChats();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getDemoChats() {
    return [
      {
        'rawId': 'demo-1',
        'otherUserId': 101,
        'name': 'Rahul Sharma',
        'lastMessage': 'Yes, the BMW M5 is still available for test drive.',
        'time': '10:42 AM',
        'unreadCount': 2,
        'productId': 1,
        'productTitle': 'BMW M5 2023',
        'productPrice': '₹ 1,50,00,000',
        'productImage': 'https://images.unsplash.com/photo-1555215695-3004980ad916?auto=format&fit=crop&w=300&q=80',
        'avatarUrl': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=100&q=80',
      },
      {
        'rawId': 'demo-2',
        'otherUserId': 102,
        'name': 'Priya Das',
        'lastMessage': 'Can I come see the flat tomorrow evening?',
        'time': 'Yesterday',
        'unreadCount': 0,
        'productId': 2,
        'productTitle': 'Luxurious 3BHK Flat',
        'productPrice': '₹ 2,50,00,000',
        'productImage': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=300&q=80',
        'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80',
      },
      {
        'rawId': 'demo-3',
        'otherUserId': 103,
        'name': 'Amit Verma',
        'lastMessage': 'Is the price for the iPhone 16 Pro negotiable?',
        'time': 'Mon',
        'unreadCount': 1,
        'productId': 3,
        'productTitle': 'iPhone 16 Pro Max',
        'productPrice': '₹ 1,44,900',
        'productImage': 'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?auto=format&fit=crop&w=300&q=80',
        'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80',
      },
      {
        'rawId': 'demo-4',
        'otherUserId': 104,
        'name': 'Support Team',
        'lastMessage': 'Hello! How can we help you today?',
        'time': 'Mar 12',
        'unreadCount': 0,
        'productId': null,
        'productTitle': 'General Inquiry',
        'avatarUrl': 'https://ui-avatars.com/api/?name=Support&background=0D8ABC&color=fff',
      },
    ];
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
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
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _chats.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchConversations,
                  color: AppTheme.primaryColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _chats.length,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(left: 76, right: 16),
                      child: Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300),
                    ),
                    itemBuilder: (context, index) {
                      return _buildChatTile(context, _chats[index]);
                    },
                  ),
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

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> chat) {
    final bool isUnread = (chat['unreadCount'] as int) > 0;

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatData: chat),
          ),
        );
        // Refresh when returning from chat screen
        _fetchConversations();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(chat['avatarUrl'] as String),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 16),
            
            // Middle Content (Name & Message)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['name'] as String,
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
                      if (chat['productId'] == null)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.support_agent, size: 14, color: Colors.blue),
                        ),
                      Expanded(
                        child: Text(
                          chat['lastMessage'] as String,
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

            // Right Content (Time & Badge)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'] as String,
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
                        chat['unreadCount'].toString(),
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
                  const SizedBox(height: 20), // Placeholder to maintain alignment
              ],
            ),
          ],
        ),
      ),
    );
  }
}
