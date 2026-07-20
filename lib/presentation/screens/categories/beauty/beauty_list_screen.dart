import '../../chats/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/product_service.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'beauty_detail_screen.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';
import '../../../widgets/category_search_header.dart';
import '../../../widgets/favorite_toggle_button.dart';
import '../../../widgets/common/filter_bottom_sheet.dart';

class BeautyListScreen extends StatefulWidget {
  final int? categoryId;
  const BeautyListScreen({super.key, this.categoryId});

  @override
  State<BeautyListScreen> createState() => _BeautyListScreenState();
}

class _BeautyListScreenState extends State<BeautyListScreen> {
  bool _isVerifiedOnly = false;
  int _currentNavIndex = 0;
  
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  // Filter State
  double? _minPrice;
  double? _maxPrice;
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _productService.getProducts(
        categoryId: widget.categoryId,
        verifiedOnly: _isVerifiedOnly,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        brand: _selectedBrand,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
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

  void _resetFilters() {
    setState(() {
      _isVerifiedOnly = false;
      _minPrice = null;
      _maxPrice = null;
      _selectedBrand = null;
      _searchController.clear();
    });
    _fetchProducts();
  }

  void _showPriceFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        title: "Select Price Range",
        options: const ["Under ₹500", "₹500 - ₹2,000", "₹2,000 - ₹5,000", "Above ₹5,000"],
        selectedValue: _maxPrice == null ? null : (_maxPrice == 500 ? "Under ₹500" : null),
        onSelected: (val) {
          setState(() {
            if (val == "Under ₹500") {
              _minPrice = 0; _maxPrice = 500;
            } else if (val == "₹500 - ₹2,000") {
              _minPrice = 500; _maxPrice = 2000;
            } else if (val == "₹2,000 - ₹5,000") {
              _minPrice = 2000; _maxPrice = 5000;
            } else if (val == "Above ₹5,000") {
              _minPrice = 5000; _maxPrice = 1000000;
            } else {
              _minPrice = null; _maxPrice = null;
            }
          });
          _fetchProducts();
        },
      ),
    );
  }

  void _showBrandFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        title: "Select Brand",
        options: const ["L'Oreal", "Maybelline", "MAC", "Clinique", "The Body Shop"],
        selectedValue: _selectedBrand,
        onSelected: (val) {
          setState(() => _selectedBrand = val);
          _fetchProducts();
        },
      ),
    );
  }

  void _showAllFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Advanced filters coming soon!")),
    );
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
              prefixIcon: Icons.search_rounded,
              hintText: "Search in Beauty & Wellness...",
              onBack: () => Navigator.pop(context),
              controller: _searchController,
              onSubmitted: (val) => _fetchProducts(),
            ),
            _buildFilterBar(),
            _buildResultsSummary(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _error != null 
                  ? Center(child: "Error: $_error".text.make())
                  : _products.isEmpty
                    ? Center(child: "No beauty products found".text.make())
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
          CustomBottomNavBar.handleGlobalNavigation(context, index, _currentNavIndex, false);
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
          _buildFilterChip(Icons.tune, "Filter", hasDropdown: false, isIconOnly: true).onTap(() => _showAllFilters()),
          _buildFilterChip(null, _selectedBrand ?? "Brand", hasDropdown: true).onTap(() => _showBrandFilter()),
          _buildFilterChip(null, "Price", hasDropdown: true).onTap(() => _showPriceFilter()),
          const VerticalDivider(width: 20, indent: 8, endIndent: 8),
          "All Filters".text.semiBold.black.make().centered().px(8).onTap(() => _showAllFilters()),
          "Reset".text.gray500.make().centered().px(8).onTap(() => _resetFilters()),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData? icon, String label, {bool hasDropdown = false, bool isIconOnly = false}) {
    bool isActive = label != "Brand" && label != "Price" && !isIconOnly;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.pink.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? Colors.pink.shade300 : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 16, color: Colors.pink).box.padding(EdgeInsets.only(right: isIconOnly ? 0 : 4)).make(),
          if (!isIconOnly) label.text.size(12).semiBold.color(isActive ? Colors.pink.shade900 : Colors.black).make(),
          if (hasDropdown) Icon(Icons.keyboard_arrow_down, size: 16, color: isActive ? Colors.pink : Colors.grey).box.padding(const EdgeInsets.only(left: 4)).make(),
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
          "Showing Results - ${_products.length}".text.italic.gray600.size(12).make(),
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
                        child: const Icon(Icons.spa, color: Colors.grey, size: 50).centered(),
                      ),
                    )
                  : Container(
                      height: 220,
                      color: Colors.grey[200],
                      width: double.infinity,
                      child: const Icon(Icons.spa, color: Colors.grey, size: 50).centered(),
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
                        "FEATURED".text.white.bold.size(8).make(),
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
                CurrencyUtils.formatPriceDisplay(item.price).text.xl2.bold.color(AppTheme.secondaryColor).make(),
                item.title.text.semiBold.xl.black.make(),
                const SizedBox(height: 4),
                "Condition: ${item.formattedCondition}".text.gray600.medium.size(13).make(),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: (item.cityName ?? item.locationName ?? 'N/A').toString().text.gray500.size(12).maxLines(2).ellipsis.make(),
                    ),
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
                              "Chat".text.color(const Color(0xFF1E88E5)).semiBold.make(),
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
          MaterialPageRoute(builder: (context) => BeautyDetailScreen(
            productId: item.id,
            title: item.title,
          )),
        );
    });
  }

}
