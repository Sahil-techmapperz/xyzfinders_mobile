import '../../../core/utils/currency_utils.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/seller_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/buyer_service.dart';
import '../../widgets/favorite_toggle_button.dart';
import '../../../core/utils/product_navigation_utils.dart';

class StoreDetailScreen extends StatefulWidget {
  final int sellerId;
  const StoreDetailScreen({super.key, required this.sellerId});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  final BuyerService _buyerService = BuyerService();
  SellerModel? _seller;
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final data = await _buyerService.getSellerDetail(widget.sellerId);
      setState(() {
        _seller = data['seller'];
        _products = data['products'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching store detail: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_seller == null) {
      return Scaffold(
        appBar: AppBar(),
        body: "Store not found".text.make().centered(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildStoreInfo()),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: "Store Products (${_products.length})".text.bold.xl.make().pOnly(bottom: 16),
            ),
          ),
          if (_products.isEmpty)
            SliverToBoxAdapter(
              child: "No products available in this store".text.make().centered().p20(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildProductCard(_products[index]),
                  childCount: _products.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final bannerUrl = _seller?.storeBanner;

    Widget bannerWidget;
    if (bannerUrl != null) {
      if (bannerUrl.startsWith('data:image')) {
        try {
          final base64String = bannerUrl.split(',').last;
          bannerWidget = Image.memory(base64Decode(base64String), fit: BoxFit.cover);
        } catch (e) {
          bannerWidget = Container(color: AppTheme.secondaryColor.withOpacity(0.1));
        }
      } else if (bannerUrl.startsWith('http')) {
        bannerWidget = CachedNetworkImage(imageUrl: bannerUrl, fit: BoxFit.cover);
      } else {
        bannerWidget = CachedNetworkImage(imageUrl: '$baseUrl$bannerUrl', fit: BoxFit.cover);
      }
    } else {
      bannerWidget = Container(color: AppTheme.secondaryColor.withOpacity(0.1));
    }

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: bannerWidget,
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ).p8(),
    );
  }

  Widget _buildStoreInfo() {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final avatarUrl = _seller?.avatar;

    Widget avatarWidget;
    if (avatarUrl != null) {
      if (avatarUrl.startsWith('data:image')) {
        try {
          final base64String = avatarUrl.split(',').last;
          avatarWidget = Image.memory(base64Decode(base64String), fit: BoxFit.cover);
        } catch (e) {
          avatarWidget = const Icon(Icons.store, size: 40, color: AppTheme.secondaryColor);
        }
      } else if (avatarUrl.startsWith('http')) {
        avatarWidget = CachedNetworkImage(imageUrl: avatarUrl, fit: BoxFit.cover);
      } else {
        avatarWidget = CachedNetworkImage(imageUrl: '$baseUrl$avatarUrl', fit: BoxFit.cover);
      }
    } else {
      avatarWidget = const Icon(Icons.store, size: 40, color: AppTheme.secondaryColor);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: avatarWidget,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _seller!.companyName.text.bold.xl2.make(),
                        if (_seller!.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.verified, color: Colors.blue, size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    "Member since ${_seller!.joinedYear ?? 'N/A'}".text.xs.color(Colors.grey).make(),
                    const SizedBox(height: 8),
                    if (_seller!.address != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(child: _seller!.address!.text.xs.color(Colors.grey).make()),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Active Ads", _seller!.adCount.toString()),
              _buildStatItem("Sales", "0"), // Placeholder as no sales field in model
              _buildStatItem("Rating", "4.8"), // Placeholder
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        value.text.bold.xl.make(),
        label.text.xs.color(Colors.grey).make(),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = product.firstImageUrl;

    Widget imageWidget;
    if (imageUrl != null) {
      if (imageUrl.startsWith('data:image')) {
        try {
          final base64String = imageUrl.split(',').last;
          imageWidget = Image.memory(
            base64Decode(base64String),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported)),
          );
        } catch (e) {
          imageWidget = const Center(child: Icon(Icons.image_not_supported));
        }
      } else if (imageUrl.startsWith('http')) {
        imageWidget = CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Center(child: Icon(Icons.image_not_supported)),
        );
      } else {
        imageWidget = CachedNetworkImage(
          imageUrl: '$baseUrl$imageUrl',
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Center(child: Icon(Icons.image_not_supported)),
        );
      }
    } else {
      imageWidget = const Center(child: Icon(Icons.image));
    }

    return GestureDetector(
      onTap: () => ProductNavigationUtils.navigateTo(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: imageWidget,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FavoriteToggleButton(product: product),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  product.title.text.semiBold.maxLines(1).ellipsis.make(),
                  const SizedBox(height: 4),
                  CurrencyUtils.formatPriceDisplay(product.price).text.bold.color(AppTheme.secondaryColor).make(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
