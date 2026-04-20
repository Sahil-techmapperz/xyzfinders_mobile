import '../../chats/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/product_service.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../pets_accessories/pets_accessories_detail_screen.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';
import '../../../widgets/category_search_header.dart';
import '../../../widgets/favorite_toggle_button.dart';

class PetsAccessoriesListScreen extends StatefulWidget {
  final int? categoryId;
  const PetsAccessoriesListScreen({super.key, this.categoryId});

  @override
  State<PetsAccessoriesListScreen> createState() => _PetsAccessoriesListScreenState();
}

class _PetsAccessoriesListScreenState extends State<PetsAccessoriesListScreen> {
  bool _isVerifiedOnly = false;
  int _currentNavIndex = 0;

  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _productService.getProducts(categoryId: widget.categoryId);
      if (mounted) {
        setState(() {
          _products = List<ProductModel>.from(response['products']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            CategorySearchHeader(
              prefixIcon: Icons.pets_rounded,
              hintText: "Search Pet Accessories...",
              onBack: () => Navigator.pop(context),
            ),
            _buildFilterBar(),
            _buildResultsSummary(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _error != null 
                  ? Center(child: "Error: $_error".text.make())
                  : _products.isEmpty
                    ? Center(child: "No pet accessories found".text.make())
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(context, _products[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          if (index != 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
      ),
      floatingActionButton: CustomFab(onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(Icons.tune, "Filter", hasDropdown: false, isIconOnly: true),
          _buildFilterChip(null, "Price", hasDropdown: true),
          _buildFilterChip(null, "Pet Type", hasDropdown: true),
          _buildFilterChip(null, "Category", hasDropdown: true),
          const VerticalDivider(width: 20, indent: 8, endIndent: 8),
          "All Filters".text.semiBold.black.make().centered().px(8),
          "Reset".text.gray500.make().centered().px(8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData? icon, String label, {bool hasDropdown = false, bool isIconOnly = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 16, color: Colors.orange.shade700).box.padding(EdgeInsets.only(right: isIconOnly ? 0 : 4)).make(),
          if (!isIconOnly) label.text.size(12).semiBold.make(),
          if (hasDropdown) const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey).box.padding(const EdgeInsets.only(left: 4)).make(),
        ],
      ),
    );
  }

  Widget _buildResultsSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          "Showing Results - ${_products.length} items".text.italic.gray600.size(12).make(),
          Row(
            children: [
              "Verified Only".text.semiBold.size(12).make(),
              const SizedBox(width: 8),
              SizedBox(
                height: 24,
                width: 40,
                child: Switch(
                  value: _isVerifiedOnly,
                  onChanged: (val) => setState(() => _isVerifiedOnly = val),
                  activeColor: AppTheme.secondaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel item) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: item.firstImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.resolveImageUrl(baseUrl) ?? '',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        height: 220,
                        color: Colors.grey[200],
                        width: double.infinity,
                        child: const Icon(Icons.pets, color: Colors.grey, size: 50).centered(),
                      ),
                    )
                  : Container(
                      height: 220,
                      color: Colors.grey[200],
                      width: double.infinity,
                      child: const Icon(Icons.pets, color: Colors.grey, size: 50).centered(),
                    ),
              ),
              if (item.isFeatured)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 10),
                        const SizedBox(width: 4),
                        "VERIFIED SELLER".text.white.bold.size(8).make(),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                right: 10,
                child: FavoriteToggleButton(product: item),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    "₹ ${item.price}".text.xl2.bold.color(AppTheme.secondaryColor).make(),
                  ],
                ),
                const SizedBox(height: 12),
                "Category ID: ${item.categoryId}  •  ${item.condition}".text.gray600.medium.size(13).make(),
                const SizedBox(height: 4),
                item.title.text.semiBold.xl.black.make(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    "Views: ${item.viewsCount}".text.gray500.size(12).make(),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatData: {
                                  'rawId': null,
                                  'otherUserId': item.userId?.toString() ?? '',
                                  'name': item.sellerName ?? 'Seller',
                                  'productId': item.id,
                                  'productTitle': item.title,
                                  'productPrice': item.price,
                                  'productImage': item.allImageUrls.isNotEmpty ? item.allImageUrls.first : null,
                                  'avatarUrl': item.sellerAvatar,
                                  'isAgencyChat': false,
                                  'agencyIdResolved': null,
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble, color: Color(0xFF1E88E5), size: 18),
                              const SizedBox(width: 8),
                              "Chat Now".text.color(const Color(0xFF1E88E5)).semiBold.make(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).onTap(() {
       Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetsAccessoriesDetailScreen(
              productId: item.id,
              title: item.title,
            ),
          ),
        );
    });
  }

}
