import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/product_model.dart';
import '../../../core/constants/api_constants.dart';

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
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white, height: 150),
                  );
                },
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),

            // Sold Badge
            if (product.isSold)
              "SOLD".text.xs.bold.white.make()
                  .px8()
                  .py4()
                  .box.red500.roundedSM.make()
                  .positioned(top: 8, right: 8),
          ],
        ),

        // Info Section
        VStack([
          product.title.text.sm.semiBold.maxLines(2).ellipsis.make(),
          
          4.heightBox,
          
          HStack([
            "\$${product.price.toStringAsFixed(0)}".text.bold.color(context.theme.primaryColor).make(),
            if (product.hasDiscount) ...[
              6.widthBox,
              "\$${product.originalPrice!.toStringAsFixed(0)}"
                  .text.xs.lineThrough.gray400.make(),
            ]
          ]),

          4.heightBox,

          HStack([
             product.condition.toUpperCase().text.xs.gray500.make(),
             Spacer(),
             // Location icon if needed, or just keep it simple
             const Icon(Icons.location_on, size: 12, color: Vx.gray400),
             2.widthBox,
             (product.location != null ? product.location!['name'] : 'N/A').toString().text.xs.gray400.ellipsis.make().expand(),
          ]),
        ]).p8(),
      ]),
    )
    .white
    .roundedLg
    .shadowSm
    .clip(Clip.antiAlias)
    .make()
    .onInkTap(onTap);
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      color: Vx.gray200,
      child: const Center(
        child: Icon(Icons.image, color: Vx.gray400),
      ),
    );
  }
}

