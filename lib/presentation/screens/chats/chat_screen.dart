import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;

  const ChatScreen({super.key, required this.chatData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  IO.Socket? _socket;
  int? _currentUserId;
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt(AppConstants.userIdKey);
    
    await _fetchMessages();
    _initSocket();
  }

  void _initSocket() {
    if (_currentUserId == null) return;

    _socket = IO.io(ApiConstants.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Connected to Socket');
      _socket!.emit('join_user', _currentUserId);
    });

    _socket!.on('receive_user_message', (data) {
      _handleIncomingMessage(data);
    });
  }

  void _handleIncomingMessage(dynamic msg) {
    if (!mounted) return;
    
    final otherUserId = widget.chatData['otherUserId'];
    if (msg['sender_id'] != otherUserId && msg['receiver_id'] != otherUserId) return;

    setState(() {
      final exists = _messages.any((m) => m['rawId'] == msg['id']);
      if (!exists) {
        _messages.insert(0, {
          'rawId': msg['id'],
          'text': msg['message'],
          'attachmentUrl': msg['attachment_url'],
          'isMe': msg['sender_id'] == _currentUserId,
          'time': _formatTime(msg['created_at']),
        });
      }
    });
    _scrollToBottom();
  }

  Future<void> _fetchMessages() async {
    try {
      final productId = widget.chatData['productId'] ?? 'null';
      final otherUserId = widget.chatData['otherUserId'];
      
      final response = await ApiService().get('/messages/$productId/$otherUserId');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        
        // Reverse because listview is reverse: true
        final parsedMessages = data.map((m) {
          return {
            'rawId': m['id'],
            'text': m['message'],
            'attachmentUrl': m['attachment_url'],
            'isMe': m['sender_id'] == _currentUserId,
            'time': _formatTime(m['created_at']),
          };
        }).toList().reversed.toList();

        if (mounted) {
          setState(() {
            _messages = parsedMessages.isEmpty ? _getDemoMessages() : parsedMessages;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _messages = _getDemoMessages();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      if (mounted) {
        setState(() {
          _messages = _getDemoMessages();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getDemoMessages() {
    return [
      {
        'rawId': 'm-demo-1',
        'text': 'Hi, is this still available?',
        'isMe': true,
        'time': '10:30 AM',
      },
      {
        'rawId': 'm-demo-2',
        'text': 'Yes, it is! Are you interested in a viewing?',
        'isMe': false,
        'time': '10:32 AM',
      },
      {
        'rawId': 'm-demo-3',
        'text': 'Great! What is your best price for this?',
        'isMe': true,
        'time': '10:35 AM',
      },
      {
        'rawId': 'm-demo-4',
        'text': 'We can discuss that in person. How about tomorrow at 5 PM?',
        'isMe': false,
        'time': '10:40 AM',
      },
    ].reversed.toList(); // Reverse because listview is reverse: true
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
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

  Future<String?> _uploadToImageKit(File imageFile) async {
    try {
      // 1. Get Auth Params
      final authRes = await ApiService().get('/auth/imagekit');
      if (authRes.statusCode != 200) return null;

      final authData = authRes.data;
      final String token = authData['token'];
      final String signature = authData['signature'];
      final int expire = authData['expire'];
      final String publicKey = authData['publicKey'];

      // 2. Upload to ImageKit
      final String fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'fileName': fileName,
        'token': token,
        'signature': signature,
        'expire': expire,
        'publicKey': publicKey,
        'useUniqueFileName': 'true',
        'folder': '/chat_attachments',
      });

      final uploadRes = await dio.post(
        'https://upload.imagekit.io/api/v1/files/upload',
        data: formData,
      );

      if (uploadRes.statusCode == 200) {
        return uploadRes.data['url'];
      }
    } catch (e) {
      debugPrint('Error uploading to ImageKit: $e');
    }
    return null;
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final hasImage = _selectedImage != null;
    
    if ((text.isEmpty && !hasImage) || _currentUserId == null) return;

    String? imageUrl;
    if (hasImage) {
      setState(() => _isUploading = true);
      imageUrl = await _uploadToImageKit(_selectedImage!);
      if (imageUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image. Please try again.')),
          );
          setState(() => _isUploading = false);
        }
        return;
      }
    }

    // Optimistic UI update
    final tempMsg = {
      'rawId': DateTime.now().millisecondsSinceEpoch,
      'text': text,
      'attachmentUrl': imageUrl,
      'isMe': true,
      'time': 'Just now',
    };

    setState(() {
      _messages.insert(0, tempMsg);
      _messageController.clear();
      _selectedImage = null;
      _isUploading = false;
    });
    _scrollToBottom();

    final productId = widget.chatData['productId'];
    final otherUserId = widget.chatData['otherUserId'];

    try {
      final response = await ApiService().post(
        ApiConstants.messages,
        data: {
          'product_id': productId,
          'receiver_id': otherUserId,
          'message': text,
          'attachment_url': imageUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newMsg = response.data['data'];
        if (_socket != null) {
          if (productId == null) {
            _socket!.emit('send_admin_message', newMsg);
          } else {
            _socket!.emit('send_user_message', {
              'receiverId': otherUserId,
              'message': newMsg,
            });
            _socket!.emit('new_notification', otherUserId);
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to send message: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
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
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Column(
              children: [
                if (widget.chatData['productId'] != null)
                   _buildProductBanner(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Newest messages at the bottom
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
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
                if (price.isNotEmpty)
                  Text(
                    price,
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
        // Handle base64
        return Image.memory(
          Uri.parse(image).data!.contentAsBytes(),
          fit: BoxFit.cover,
        );
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
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.black87),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isMe = message['isMe'] as bool;
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
                if (message['attachmentUrl'] != null)
                   Padding(
                     padding: const EdgeInsets.only(bottom: 8.0),
                     child: ClipRRect(
                       borderRadius: BorderRadius.circular(12),
                       child: CachedNetworkImage(
                         imageUrl: message['attachmentUrl'] as String,
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
                if (message['text'] != null && (message['text'] as String).isNotEmpty)
                  Text(
                    message['text'] as String,
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
            message['time'] as String,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
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
                  child: _isUploading 
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
