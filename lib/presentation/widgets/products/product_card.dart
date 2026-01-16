import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/product_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = product.firstImageUrl != null 
        ? '$baseUrl${product.firstImageUrl}'
        : null;

    return VxBox(
      child: VStack([
        // Image Section
        Stack(
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white, height: 110),
                  );
                },
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),

            // Heart Icon (Top Right)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),

        // Info Section
        VStack([
          product.title.text.base.semiBold.black.maxLines(2).ellipsis.make(),
          
          6.heightBox,
          
          HStack([
            "\$${product.price.toStringAsFixed(0)}".text.bold.xl.color(AppTheme.secondaryColor).make(), // Orange Price
          ]),

          6.heightBox,

          HStack([
             // Location
             (product.location != null ? product.location!['name'] : 'N/A').toString().text.sm.color(const Color(0xFF666666)).ellipsis.make().expand(),
          ]),
        ]).p8(),
      ]),
    )
    .withDecoration(BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ))
    .clip(Clip.antiAlias)
    .make()
    .onInkTap(onTap);
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 110,
      color: Vx.gray200,
      child: const Center(
        child: Icon(Icons.image, color: Vx.gray400),
      ),
    );
  }
}

