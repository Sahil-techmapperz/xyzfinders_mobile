import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/product_model.dart';

class ShareButton extends StatelessWidget {
  final ProductModel product;
  final double iconSize;
  final Color? color;

  const ShareButton({
    super.key,
    required this.product,
    this.iconSize = 24,
    this.color = Colors.black87,
  });

  String _getCategoryRoute(String? categoryName) {
    if (categoryName == null) return 'product';
    switch (categoryName.toLowerCase().trim()) {
      case 'real estate':
        return 'real-estate';
      case 'automobiles':
        return 'automobiles';
      case 'mobiles':
        return 'mobiles';
      case 'furniture':
        return 'furniture';
      case 'electronics':
        return 'gadgets';
      case 'beauty':
        return 'beauty';
      case 'jobs':
        return 'jobs';
      case 'pets & animals accessories':
      case 'pets & animals':
      case 'pets':
        return 'pets';
      case 'learning & education':
      case 'education':
        return 'education';
      case 'local events':
      case 'events':
        return 'events';
      case 'services':
        return 'services';
      case 'fashion & accessories':
      case 'fashion':
        return 'fashion';
      default:
        return 'product';
    }
  }

  String _createSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'(^-|-$)'), '');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final box = context.findRenderObject() as RenderBox?;
        final String categoryRoute = _getCategoryRoute(product.categoryName);
        final String slug = _createSlug(product.title);
        final String url = categoryRoute == 'product'
            ? 'https://xyzfinders.in/product/${product.id}'
            : 'https://xyzfinders.in/$categoryRoute/${product.id}-$slug';
            
        final String shareText = 'Check out this listing on XYZ Finders: ${product.title}\n\n$url';
        Share.share(
          shareText,
          sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
        );
      },
      child: Icon(Icons.share_outlined, size: iconSize, color: color),
    );
  }
}
