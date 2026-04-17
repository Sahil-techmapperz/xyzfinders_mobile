import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../core/theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool isSellerMode;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    this.isSellerMode = false,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      color: AppTheme.secondaryColor,
      elevation: 0,
      padding: EdgeInsets.zero,
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, isSellerMode ? Icons.dashboard_rounded : Icons.home_filled, isSellerMode ? 'Dashboard' : 'Home'),
            _buildNavItem(1, isSellerMode ? Icons.campaign_rounded : Icons.favorite_border, isSellerMode ? 'My Ads' : 'Wishlist'),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(3, Icons.forum_outlined, 'Chats'),
            _buildNavItem(4, Icons.menu, 'Menu'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFab extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSellerMode;
  const CustomFab({super.key, required this.onPressed, this.isSellerMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RawMaterialButton(
        onPressed: onPressed,
        shape: const CircleBorder(),
        fillColor: Colors.white,
        child: Icon(
          isSellerMode ? Icons.add_photo_alternate_rounded : Icons.add,
          size: 32,
          color: AppTheme.secondaryColor
        ),
      ),
    );
  }
}
