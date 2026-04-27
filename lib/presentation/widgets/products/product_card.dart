import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:shimmer/shimmer.dart';
import '../favorite_toggle_button.dart';
import '../../providers/favorite_provider.dart';
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
    final imageUrl = product.firstImageUrl;
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    Widget imageWidget;
    if (imageUrl != null) {
      if (imageUrl.startsWith('data:image')) {
        // Handle Base64 Data URI
        try {
          final base64String = imageUrl.split(',').last;
          imageWidget = Image.memory(
            base64Decode(base64String),
            height: 110,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          );
        } catch (e) {
          imageWidget = _buildPlaceholder();
        }
      } else if (imageUrl.startsWith('http')) {
        // Handle Full URL
        imageWidget = CachedNetworkImage(
          imageUrl: imageUrl,
          height: 110,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.white, height: 110),
          ),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        );
      } else {
        // Handle Relative Path
        imageWidget = CachedNetworkImage(
          imageUrl: '$baseUrl$imageUrl',
          height: 110,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.white, height: 110),
          ),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        );
      }
    } else {
      imageWidget = _buildPlaceholder();
    }

    return VxBox(
      child: VStack([
        // Image Section
        Stack(
          children: [
            imageWidget,

            // Heart Icon (Top Right)
            Positioned(
              top: 8,
              right: 8,
              child: FavoriteToggleButton(
                product: product,
                iconSize: 18,
                padding: const EdgeInsets.all(6),
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

