import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/product_model.dart';
import '../../core/theme/app_theme.dart';

class FavoriteToggleButton extends StatelessWidget {
  final ProductModel product;
  final double iconSize;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final EdgeInsets? padding;

  const FavoriteToggleButton({
    super.key,
    required this.product,
    this.iconSize = 20,
    this.backgroundColor,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.grey,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoriteProvider, AuthProvider>(
      builder: (context, favProvider, authProvider, child) {
        final isFav = favProvider.isFavorite(product.id);
        
        return GestureDetector(
          onTap: () {
            if (!authProvider.isAuthenticated) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Please log in to wishlist this ad', style: TextStyle(fontWeight: FontWeight.w600)),
                  backgroundColor: AppTheme.secondaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Login',
                    textColor: Colors.white,
                    onPressed: () {
                      // Optional: show login modal
                    },
                  ),
                ),
              );
              return;
            }
            favProvider.toggleFavorite(product);
          },
          child: Container(
            padding: padding ?? const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: backgroundColor == null ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ] : null,
            ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? activeColor : inactiveColor,
              size: iconSize,
            ),
          ),
        );
      },
    );
  }
}
