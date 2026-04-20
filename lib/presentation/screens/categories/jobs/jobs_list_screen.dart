import '../../chats/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/product_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';
import '../../../widgets/category_search_header.dart';
import '../../../widgets/favorite_toggle_button.dart';

class JobsListScreen extends StatefulWidget {
  final int? categoryId;
  const JobsListScreen({super.key, this.categoryId});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
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
              prefixIcon: Icons.work_rounded,
              hintText: "Search Jobs...",
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
                    ? Center(child: "No jobs found".text.make())
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
          _buildFilterChip(null, "Salary", hasDropdown: true),
          _buildFilterChip(null, "Job Type", hasDropdown: true),
          _buildFilterChip(null, "Location", hasDropdown: true),
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
          if (icon != null) Icon(icon, size: 16, color: Colors.brown).box.padding(EdgeInsets.only(right: isIconOnly ? 0 : 4)).make(),
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
          "Showing Results - ${_products.length}".text.italic.gray600.size(12).make(),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.brown.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business_center_rounded, color: Colors.brown, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              "₹ ${item.price}".text.xl.bold.color(Colors.brown).make(),
                              Row(
                                children: [
                                  if (item.isFeatured)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.verified, color: Colors.green, size: 12),
                                          const SizedBox(width: 4),
                                          "VERIFIED".text.green700.bold.size(8).make(),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  FavoriteToggleButton(
                                    product: item,
                                    iconSize: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          item.title.text.semiBold.lg.black.make(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    (item.location?['name'] ?? 'Remote').toString().text.gray600.size(13).make(),
                    const Spacer(),
                    const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    "Full Time".text.gray600.size(13).make(),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    "${item.viewsCount} candidates viewed".text.gray500.size(12).make(),
                  ],
                ),
                const SizedBox(height: 20),
                InkWell(
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
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_rounded, color: Color(0xFF1E88E5), size: 18),
                        const SizedBox(width: 10),
                        "Chat for Details".text.color(const Color(0xFF1E88E5)).bold.make(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
