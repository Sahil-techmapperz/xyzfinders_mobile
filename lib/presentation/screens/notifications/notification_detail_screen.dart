import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final String type = notification['type'] as String;
    
    IconData iconData;
    Color iconBgColor;
    Color iconColor;
    String actionText;

    switch (type) {
      case 'promo':
        iconData = Icons.local_offer;
        iconBgColor = Colors.orange.shade50;
        iconColor = AppTheme.secondaryColor;
        actionText = 'Shop Now';
        break;
      case 'order':
        iconData = Icons.local_shipping;
        iconBgColor = Colors.blue.shade50;
        iconColor = Colors.blue;
        actionText = 'Track Order';
        break;
      case 'system':
        iconData = Icons.info_outline;
        iconBgColor = Colors.grey.shade100;
        iconColor = Colors.grey.shade700;
        actionText = 'Review Settings';
        break;
      case 'wishlist':
        iconData = Icons.favorite;
        iconBgColor = Colors.red.shade50;
        iconColor = Colors.red;
        actionText = 'View Item';
        break;
      default:
        iconData = Icons.notifications;
        iconBgColor = Colors.grey.shade100;
        iconColor = Colors.black54;
        actionText = 'Mark as Read';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Details',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Big Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 40),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                notification['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Timestamp
              Text(
                notification['time'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 24),

              // Full Body Content
              Text(
                notification['body'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              
              const Spacer(),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Just pop for mock implementation
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
