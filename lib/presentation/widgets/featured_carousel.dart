import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../data/models/product_model.dart';
import '../../../core/constants/api_constants.dart';
import '../screens/products/product_detail_screen.dart';

class FeaturedCarousel extends StatelessWidget {
  final List<ProductModel> products;

  const FeaturedCarousel({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    // Take top 5 products as "featured"
    final featuredProducts = products.take(5).toList();

    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: false,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 1.0,
      ),
      items: featuredProducts.map((product) {
        final String? imageUrl = (product.images != null && product.images!.isNotEmpty)
            ? '${ApiConstants.baseUrl.replaceAll('/api', '')}/api/images/product/${product.images![0]['id']}'
            : null;

        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      productId: product.id,
                      title: product.title,
                    ),
                  ),
                );
              },
              child: VxBox(
                child: ZStack([
                  if (imageUrl != null)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),
                  
                  // Gradient Overlay
                  VxBox()
                      .withGradient(
                        LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      )
                      .make(),

                  // Text Content
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: VStack([
                      product.title.text.white.bold.xl.make(),
                      "\$${product.price.toStringAsFixed(2)}".text.color(context.theme.primaryColorLight).bold.lg.make(),
                      if (product.location != null)
                        product.location!['name'].toString().text.white.sm.make(),
                    ]).p16(),
                  ),
                ]),
              )
              .withDecoration(BoxDecoration(
                boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.1),
                     blurRadius: 10,
                     offset: const Offset(0, 5),
                   ),
                ],
              ))
              .clip(Clip.antiAlias)
              .make(),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
      ),
    );
  }
}
