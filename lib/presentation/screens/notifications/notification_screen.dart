import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = _getMockNotifications();

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
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 24, thickness: 0.5),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(context, notification);
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
    );
  }

  Widget _buildNotificationTile(BuildContext context, Map<String, dynamic> data) {
    final bool isUnread = data['isUnread'] as bool? ?? false;
    final String type = data['type'] as String;

    IconData iconData;
    Color iconBgColor;
    Color iconColor;

    switch (type) {
      case 'promo':
        iconData = Icons.local_offer;
        iconBgColor = Colors.orange.shade50;
        iconColor = AppTheme.secondaryColor;
        break;
      case 'order':
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
        iconData = Icons.favorite;
        iconBgColor = Colors.red.shade50;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        iconBgColor = Colors.grey.shade100;
        iconColor = Colors.black54;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(notification: data),
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
                      data['title'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data['time'] as String,
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
               data['body'] as String,
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

  // Mock Data Generator
  List<Map<String, dynamic>> _getMockNotifications() {
    return [
      {
        'title': 'Welcome to XYZFinders!',
        'body': 'Explore thousands of listings exactly tailored to your needs. Tap here to set up your profile preferences.',
        'time': 'Just now',
        'type': 'system',
        'isUnread': true,
      },
      {
        'title': 'Price Drop Alert!',
        'body': 'An item in your wishlist (BMW M5 Competition) just dropped in price by ₹5,000. Act fast!',
        'time': '2h ago',
        'type': 'wishlist',
        'isUnread': true,
      },
      {
        'title': 'Weekend Super Sale',
        'body': 'Get up to 40% off on all electronics listings this weekend only. Use code WEEKEND40 at checkout.',
        'time': '1d ago',
        'type': 'promo',
        'isUnread': false,
      },
      {
        'title': 'Order Delivered',
        'body': 'Your recent order #XY100924 has been successfully delivered. Please leave a review for the seller.',
        'time': '2d ago',
        'type': 'order',
        'isUnread': false,
      },
      {
        'title': 'Security Update',
        'body': 'We noticed a new login from a Mac OS device on Chrome. If this wasn\'t you, please secure your account.',
        'time': '4d ago',
        'type': 'system',
        'isUnread': false,
      },
      {
        'title': 'Host an Event with Us',
        'body': 'Did you know you can list Local Events completely free for the next month?',
        'time': '1w ago',
        'type': 'promo',
        'isUnread': false,
      },
    ];
  }
}
