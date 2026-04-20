import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../providers/favorite_provider.dart';
import '../../../../data/models/product_model.dart';
import '../categories/real_estate/real_estate_detail_screen.dart';
import '../categories/automobiles/automobile_detail_screen.dart';
import '../categories/electronics/electronics_detail_screen.dart';
import '../categories/fashion/fashion_detail_screen.dart';
import '../categories/furniture/furniture_detail_screen.dart';
import '../categories/mobiles/mobiles_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteProvider>().loadFavorites();
    });
  }

  void _navigateToDetail(BuildContext context, ProductModel product) {
    final title = product.title.toLowerCase();
    Widget target;

    // Logic to select the right detail screen based on type or title
    if (title.contains('real estate') || title.contains('apartment') || title.contains('house')) {
      target = RealEstateDetailScreen(productId: product.id, title: product.title);
    } else if (title.contains('automobile') || title.contains('car') || title.contains('bmw')) {
      target = AutomobileDetailScreen(productId: product.id, title: product.title);
    } else if (title.contains('electronic') || title.contains('gadget') || title.contains('processor')) {
      target = ElectronicsDetailScreen(productId: product.id, title: product.title);
    } else if (title.contains('mobile') || title.contains('phone') || title.contains('iphone')) {
      target = MobilesDetailScreen(productId: product.id, title: product.title);
    } else if (title.contains('fashion') || title.contains('dress')) {
      target = FashionDetailScreen(productId: product.id, title: product.title);
    } else if (title.contains('furniture') || title.contains('sofa')) {
      target = FurnitureDetailScreen(productId: product.id, title: product.title);
    } else {
      target = RealEstateDetailScreen(productId: product.id, title: product.title); // Default fallback
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => target),
    ).then((_) {
      // Refresh list when coming back in case status changed
      context.read<FavoriteProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favProvider, child) {
          if (favProvider.isLoading && favProvider.favoriteProducts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (favProvider.favoriteProducts.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => favProvider.loadFavorites(),
            color: AppTheme.primaryColor,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: favProvider.favoriteProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = favProvider.favoriteProducts[index];
                return _buildProductCard(context, product, baseUrl, favProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product, String baseUrl, FavoriteProvider provider) {
    return InkWell(
      onTap: () => _navigateToDetail(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with heart icon overlay
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: product.resolveImageUrl(baseUrl) ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade100),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Heart Icon (Remove action)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => provider.toggleFavorite(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            )
                          ]
                        ),
                        child: const Icon(Icons.favorite, color: Colors.red, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹ ${product.price}/-",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.cityName ?? product.locationName ?? 'Location unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border_rounded, size: 64, color: Colors.red.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore products and save your\nfavorites here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Usually navigate to home or search
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Start Exploring', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
