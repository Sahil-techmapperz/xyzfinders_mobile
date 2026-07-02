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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final box = context.findRenderObject() as RenderBox?;
        final String shareText = 'Check out this listing on XYZ Finders: ${product.title}\n\n'
            'https://xyzfinders.com/product/${product.id}';
        Share.share(
          shareText,
          sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
        );
      },
      child: Icon(Icons.share_outlined, size: iconSize, color: color),
    );
  }
}
