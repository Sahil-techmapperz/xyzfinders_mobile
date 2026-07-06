import '../../chats/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/product_service.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'mobiles_detail_screen.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';
import '../../../widgets/category_search_header.dart';
import '../../../widgets/favorite_toggle_button.dart';
import '../../../widgets/common/filter_bottom_sheet.dart';

class MobilesListScreen extends StatefulWidget {
  final int? categoryId;
  const MobilesListScreen({super.key, this.categoryId});

  @override
  State<MobilesListScreen> createState() => _MobilesListScreenState();
}

class _MobilesListScreenState extends State<MobilesListScreen> {
  bool _isVerifiedOnly = false;
  int _currentNavIndex = 0;

  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  // Filter State
  String? _selectedBrand;
  String? _selectedStorage;
  String? _selectedRam;
  double? _minPrice;
  double? _maxPrice;

  Widget _buildFilterChip(IconData? icon, String label, {bool hasDropdown = false, bool isIconOnly = false}) {
    bool isActive = label != "Brand" && label != "Storage" && label != "RAM" && label != "Price" && !isIconOnly;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? Colors.orange.shade300 : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 16, color: Colors.orange.shade700).box.padding(EdgeInsets.only(right: isIconOnly ? 0 : 4)).make(),
          if (!isIconOnly) label.text.size(12).semiBold.color(isActive ? Colors.orange.shade900 : Colors.black).make(),
          if (hasDropdown) Icon(Icons.keyboard_arrow_down, size: 16, color: isActive ? Colors.orange.shade700 : Colors.grey).box.padding(const EdgeInsets.only(left: 4)).make(),
        ],
      ),
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
          _buildFilterChip(null, _selectedStorage ?? "Storage", hasDropdown: true).onTap(() => _showStorageFilter()),
          _buildFilterChip(null, _selectedRam ?? "RAM", hasDropdown: true).onTap(() => _showRamFilter()),
          _buildFilterChip(null, "Price", hasDropdown: true).onTap(() => _showPriceFilter()),
          const VerticalDivider(width: 20, indent: 8, endIndent: 8),
          "All Filters".text.semiBold.black.make().centered().px(8).onTap(() => _showAllFilters()),
          "Reset".text.gray500.make().centered().px(8).onTap(() => _resetFilters()),
        ],
      ),
    );
  }

  Widget _buildResultsSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MobilesDetailScreen(
          productId: item.id,
          title: item.title,
        )),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: item.firstImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.firstImageUrl != null && item.firstImageUrl!.startsWith('http')
                            ? item.firstImageUrl!
                            : '$baseUrl${item.firstImageUrl}',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[100],
                          width: double.infinity,
                          child: const Icon(Icons.phone_android_outlined, color: Colors.grey, size: 50).centered(),
                        ),
                      )
                    : Container(
                        height: 200,
                        color: Colors.grey[100],
                        width: double.infinity,
                        child: const Icon(Icons.phone_android_outlined, color: Colors.grey, size: 50).centered(),
                      ),
                ),
                if (item.isFeatured)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          "VERIFIED SELLER".text.white.size(8).bold.make(),
                        ],
                      ),
                    ),
                  ),
                 Positioned(
                  top: 12,
                  right: 12,
                  child: FavoriteToggleButton(product: item),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CurrencyUtils.formatIndianCurrency(item.price).text.xl2.bold.color(AppTheme.secondaryColor).make(),
                  const SizedBox(height: 8),
                  item.title.text.lg.bold.make(),
                  const SizedBox(height: 4),
                  "Condition: ${item.formattedCondition}".text.gray500.size(12).semiBold.make(),
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
                                  'otherUserId': item.agencyId != null ? 'agency-${item.agencyId}' : (item.userId?.toString() ?? ''),
                                  'name': item.sellerName ?? 'Seller',
                                  'productId': item.id,
                                  'productTitle': item.title,
                                  'productPrice': item.price,
                                  'productImage': item.allImageUrls.isNotEmpty ? item.allImageUrls.first : null,
                                  'avatarUrl': item.sellerAvatar,
                                  'isAgencyChat': item.agencyId != null,
                                  'agencyIdResolved': item.agencyId?.toString(),
                                  'categoryId': item.categoryId,
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
      ),
    );
  }

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
        brand: _selectedBrand,
        storage: _selectedStorage,
        ram: _selectedRam,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
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
      _selectedBrand = null;
      _selectedStorage = null;
      _selectedRam = null;
      _minPrice = null;
      _maxPrice = null;
      _searchController.clear();
    });
    _fetchProducts();
  }

  void _showBrandFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        title: "Select Brand",
        options: const ["Apple", "Samsung", "Google", "OnePlus", "Xiaomi", "Vivo", "Oppo"],
        selectedValue: _selectedBrand,
        onSelected: (val) {
          setState(() => _selectedBrand = val);
          _fetchProducts();
        },
      ),
    );
  }

  void _showStorageFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        title: "Select Storage",
        options: const ["64 GB", "128 GB", "256 GB", "512 GB", "1 TB"],
        selectedValue: _selectedStorage,
        onSelected: (val) {
          setState(() => _selectedStorage = val);
          _fetchProducts();
        },
      ),
    );
  }

  void _showRamFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        title: "Select RAM",
        options: const ["4 GB", "6 GB", "8 GB", "12 GB", "16 GB"],
        selectedValue: _selectedRam,
        onSelected: (val) {
          setState(() => _selectedRam = val);
          _fetchProducts();
        },
      ),
    );
  }

  void _showPriceFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        title: "Select Price Range",
        options: const ["Under ₹10,000", "₹10,000 - ₹30,000", "₹30,000 - ₹70,000", "Above ₹70,000"],
        selectedValue: _maxPrice == null ? null : (_maxPrice == 10000 ? "Under ₹10,000" : null),
        onSelected: (val) {
          setState(() {
            if (val == "Under ₹10,000") {
              _minPrice = 0; _maxPrice = 10000;
            } else if (val == "₹10,000 - ₹30,000") {
              _minPrice = 10000; _maxPrice = 30000;
            } else if (val == "₹30,000 - ₹70,000") {
              _minPrice = 30000; _maxPrice = 70000;
            } else if (val == "Above ₹70,000") {
              _minPrice = 70000; _maxPrice = 1000000;
            } else {
              _minPrice = null; _maxPrice = null;
            }
          });
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
              hintText: "Search Mobiles & Tablets...",
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
                    ? Center(child: "No mobiles found".text.make())
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
}
