import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CategorySearchHeader extends StatelessWidget {
  final IconData prefixIcon;
  final String hintText;
  final VoidCallback onBack;
  final VoidCallback? onNotificationTap;
  final bool showNotification;

  const CategorySearchHeader({
    super.key,
    this.prefixIcon = Icons.location_on,
    required this.hintText,
    required this.onBack,
    this.onNotificationTap,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28, color: Colors.black),
              onPressed: onBack,
            ),
          ),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100, width: 1),
              ),
              child: Row(
                children: [
                  Icon(prefixIcon, color: AppTheme.secondaryColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15, fontWeight: FontWeight.normal),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showNotification) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.notifications_none, size: 30, color: Colors.grey),
              onPressed: onNotificationTap,
            ),
          ],
        ],
      ),
    );
  }
}
