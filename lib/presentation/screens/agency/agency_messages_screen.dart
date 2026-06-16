import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../providers/chat_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../chats/chat_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/agency_provider.dart';

class AgencyMessagesScreen extends StatefulWidget {
  const AgencyMessagesScreen({super.key});

  @override
  State<AgencyMessagesScreen> createState() => _AgencyMessagesScreenState();
}

class _AgencyMessagesScreenState extends State<AgencyMessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final conversations = provider.conversations;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: "Agency Messages".text.bold.make(),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: provider.isLoadingConversations && conversations.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
          : RefreshIndicator(
              onRefresh: () => provider.loadConversations(),
              child: conversations.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conv = conversations[index];
                        return _buildConversationTile(conv);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        "No messages yet.".text.gray400.make().centered(),
      ],
    );
  }

  Widget _buildConversationTile(dynamic conv) {
    // Assuming the structure matches ChatProvider's conversation model
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppTheme.secondaryColor),
          ),
          if (conv.unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: conv.unreadCount.toString().text.white.xs.bold.make().centered(),
              ),
            ),
        ],
      ),
      title: (conv.otherUser?.name ?? 'Customer').text.bold.make(),
      subtitle: (conv.lastMessage?.text ?? '').text.xs.gray500.maxLines(1).ellipsis.make(),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          (conv.lastMessage?.time ?? '').text.xs.gray400.make(),
          const SizedBox(height: 4),
          if (conv.product != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
              child: (conv.product?.title ?? '').text.xs.blue600.ellipsis.make().w(60),
            ),
        ],
      ),
      onTap: () {
        final currentUserId = context.read<AuthProvider>().user?.id;
        final otherUser = conv.otherUser;
        final product = conv.product;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatData: {
                'otherUserId': otherUser?.id.toString(),
                'name': otherUser?.name ?? 'User',
                'avatarUrl': otherUser?.avatar ?? '',
                'productId': product?.id,
                'productTitle': product?.title,
                'productPrice': product?.price,
                'productImage': product?.imageUrl,
                'isAgencyChat': true,
                'agencyIdResolved': context.read<AgencyProvider>().agencyUser?.agencyId,
              },
            ),
          ),
        );
      },
    );
  }
}
