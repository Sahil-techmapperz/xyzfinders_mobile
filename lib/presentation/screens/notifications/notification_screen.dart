import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/notification_provider.dart';
import '../../../../data/models/notification_model.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return Center(
              child: VStack([
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                16.heightBox,
                provider.error!.text.center.make(),
                16.heightBox,
                ElevatedButton(
                  onPressed: () => provider.fetchNotifications(),
                  child: const Text('Retry'),
                ),
              ]).p16(),
            );
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState(provider);
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            color: AppTheme.primaryColor,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 24, thickness: 0.5),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationTile(context, notification, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(NotificationProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.fetchNotifications(),
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No notifications yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  'When you get updates, they\'ll show up here.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationModel notification, NotificationProvider provider) {
    final bool isUnread = !notification.isRead;
    final String type = notification.type;

    IconData iconData;
    Color iconBgColor;
    Color iconColor;

    switch (type) {
      case 'promo':
      case 'promotion':
        iconData = Icons.local_offer;
        iconBgColor = Colors.orange.shade50;
        iconColor = AppTheme.secondaryColor;
        break;
      case 'order':
      case 'product':
        iconData = Icons.local_shipping;
        iconBgColor = Colors.blue.shade50;
        iconColor = Colors.blue;
        break;
      case 'system':
        iconData = Icons.info_outline;
        iconBgColor = Colors.grey.shade100;
        iconColor = Colors.grey.shade700;
        break;
      case 'wishlist':
      case 'favorite':
        iconData = Icons.favorite;
        iconBgColor = Colors.red.shade50;
        iconColor = Colors.red;
        break;
      case 'message':
      case 'chat':
        iconData = Icons.chat_bubble;
        iconBgColor = Colors.green.shade50;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.notifications;
        iconBgColor = Colors.grey.shade100;
        iconColor = Colors.black54;
    }

    // Format time
    String timeAgo(DateTime date) {
      final duration = DateTime.now().difference(date);
      if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
      if (duration.inHours < 24) return '${duration.inHours}h ago';
      if (duration.inDays < 7) return '${duration.inDays}d ago';
      return '${date.day}/${date.month}';
    }

    return InkWell(
      onTap: () {
        if (isUnread) {
          provider.markAsRead(notification.id);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(notification: notification.toJson()),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Avatar / Icon
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeAgo(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnread ? AppTheme.secondaryColor : Colors.grey,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
               notification.message,
                style: TextStyle(
                  fontSize: 13,
                  color: isUnread ? Colors.black87 : Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        // Unread Indicator
        if (isUnread) ...[
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppTheme.secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    ),
    );
  }
}
