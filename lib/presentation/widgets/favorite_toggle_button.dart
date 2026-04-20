import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../../data/models/product_model.dart';

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
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        final isFav = favProvider.isFavorite(product.id);
        
        return GestureDetector(
          onTap: () => favProvider.toggleFavorite(product),
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
