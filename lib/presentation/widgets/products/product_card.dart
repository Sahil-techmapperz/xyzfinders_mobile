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
import '../../../core/utils/currency_utils.dart';

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
          imageWidget = AspectRatio(
            aspectRatio: 1.3,
            child: Image.memory(
              base64Decode(base64String),
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            ),
          );
        } catch (e) {
          imageWidget = _buildPlaceholder();
        }
      } else if (imageUrl.startsWith('http')) {
        // Handle Full URL
        imageWidget = AspectRatio(
          aspectRatio: 1.3,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: AspectRatio(aspectRatio: 1.3, child: Container(color: Colors.white)),
            ),
            errorWidget: (context, url, error) => _buildPlaceholder(),
          ),
        );
      } else {
        // Handle Relative Path
        imageWidget = AspectRatio(
          aspectRatio: 1.3,
          child: CachedNetworkImage(
            imageUrl: '$baseUrl$imageUrl',
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: AspectRatio(aspectRatio: 1.3, child: Container(color: Colors.white)),
            ),
            errorWidget: (context, url, error) => _buildPlaceholder(),
          ),
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
            CurrencyUtils.formatPriceDisplay(product.price).text.bold.xl.color(AppTheme.secondaryColor).make(),
          ]),

          6.heightBox,

          Builder(
            builder: (context) {
              final catName = product.categoryName ?? (product.category != null ? product.category!['name'] : null);
              return Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (catName != null && catName.toString().isNotEmpty) 
                    catName.toString().text.xs.color(Colors.white).make().pSymmetric(h: 6, v: 2).box.color(AppTheme.primaryColor).roundedSM.make(),
                  if (product.condition.isNotEmpty)
                    product.condition.toUpperCase().text.xs.color(Colors.grey.shade800).bold.make().pSymmetric(h: 6, v: 2).box.color(Colors.grey.shade200).roundedSM.make(),
                ],
              );
            }
          ),

          6.heightBox,

          HStack([
             const Icon(Icons.location_on, size: 14, color: Colors.grey),
             4.widthBox,
             // Location
             (product.cityName ?? product.locationName ?? (product.location != null ? product.location!['name'] : null) ?? 'N/A').toString().text.xs.color(const Color(0xFF666666)).ellipsis.make().expand(),
          ]),
        ]).p8(),
      ]),
    )
    .withDecoration(BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
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
    return AspectRatio(
      aspectRatio: 1.3,
      child: Container(
        color: Vx.gray200,
        child: const Center(
          child: Icon(Icons.image, color: Vx.gray400),
        ),
      ),
    );
  }
}
