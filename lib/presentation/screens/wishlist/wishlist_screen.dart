import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../../data/models/product_model.dart';
import '../categories/real_estate/real_estate_detail_screen.dart';
import '../categories/automobiles/automobile_detail_screen.dart';
import '../categories/electronics/electronics_detail_screen.dart';
import '../categories/fashion/fashion_detail_screen.dart';
import '../categories/furniture/furniture_detail_screen.dart';
import '../categories/mobiles/mobiles_detail_screen.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class WishlistScreen extends StatefulWidget {
  final bool showAppBar;
  const WishlistScreen({super.key, this.showAppBar = true});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<FavoriteProvider>().loadFavorites();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(BuildContext context, ProductModel product) {
    final title = product.title.toLowerCase();
    Widget target;

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
      target = RealEstateDetailScreen(productId: product.id, title: product.title);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => target),
    ).then((_) {
      if (mounted) context.read<FavoriteProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<FavoriteProvider>(
        builder: (context, favProvider, child) {
          final products = _getFilteredProducts(favProvider.favoriteProducts);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildHeader(favProvider.favoriteProducts),
              
              if (favProvider.isLoading && favProvider.favoriteProducts.isEmpty)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (favProvider.favoriteProducts.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context))
              else if (products.isEmpty)
                SliverFillRemaining(child: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    "No matching items found".text.gray500.make(),
                  ],
                )))
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildModernProductCard(context, products[index], baseUrl, favProvider),
                      childCount: products.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      bottomNavigationBar: !widget.showAppBar ? null : Consumer<AuthProvider>(
        builder: (context, auth, _) => CustomBottomNavBar(
          selectedIndex: 1,
          isSellerMode: auth.isSellerMode,
          onItemSelected: (index) {
            if (index == 1) return;
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      floatingActionButton: !widget.showAppBar ? null : Consumer<AuthProvider>(
        builder: (context, auth, _) => CustomFab(
          isSellerMode: auth.isSellerMode,
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  List<ProductModel> _getFilteredProducts(List<ProductModel> all) {
    return all.where((p) {
      // Category filter
      if (_selectedCategory != 'All' && p.categoryName != _selectedCategory) return false;
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final titleMatch = p.title.toLowerCase().contains(query);
        final descMatch = p.description.toLowerCase().contains(query);
        if (!titleMatch && !descMatch) return false;
      }
      
      // Price filter
      if (_minPrice != null && p.price < _minPrice!) return false;
      if (_maxPrice != null && p.price > _maxPrice!) return false;
      
      return true;
    }).toList();
  }

  Widget _buildHeader(List<ProductModel> allProducts) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, AppTheme.primaryColor.withValues(alpha: 0.05)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchBar(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    _buildCategoryDropdown(allProducts),
                    const SizedBox(height: 8),
                    _buildPriceFilter(allProducts),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      title: "My Wishlist".text.bold.color(const Color(0xFF1E293B)).make(),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "Search in wishlist...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18), 
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                }
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<ProductModel> allProducts) {
    final categories = ['All', ...allProducts.map((p) => p.categoryName ?? 'Other').toSet()];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          items: categories.map((cat) => DropdownMenuItem(
            value: cat,
            child: cat.text.sm.color(const Color(0xFF1E293B)).make(),
          )).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
        ),
      ),
    );
  }

  Widget _buildPriceFilter(List<ProductModel> allProducts) {
    final hasPriceFilter = _minPrice != null || _maxPrice != null;
    
    // Find absolute min/max prices from current wishlist
    double absMax = 100000;
    if (allProducts.isNotEmpty) {
      absMax = allProducts.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    }
    if (absMax < 1000) absMax = 1000;

    return GestureDetector(
      onTap: () {
        _showPriceRangePicker(absMax);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: hasPriceFilter ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasPriceFilter ? AppTheme.primaryColor : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.payments_outlined, size: 16, color: hasPriceFilter ? AppTheme.primaryColor : Colors.grey),
            const SizedBox(width: 8),
            (hasPriceFilter 
                ? "₹ ${_minPrice!.round()} - ₹ ${_maxPrice!.round()}"
                : "Price Range"
            ).text.sm.bold.color(hasPriceFilter ? AppTheme.primaryColor : Colors.grey.shade600).make(),
            const Spacer(),
            if (hasPriceFilter) 
              GestureDetector(
                onTap: () => setState(() {
                  _minPrice = null;
                  _maxPrice = null;
                }),
                child: Icon(Icons.close, size: 16, color: AppTheme.primaryColor),
              ),
            Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showPriceRangePicker(double maxLimit) {
    double tempMin = _minPrice ?? 0;
    double tempMax = _maxPrice ?? maxLimit;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      "Price Range".text.xl.bold.make(),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  RangeSlider(
                    values: RangeValues(tempMin, tempMax),
                    min: 0,
                    max: maxLimit,
                    activeColor: AppTheme.primaryColor,
                    inactiveColor: Colors.grey.shade200,
                    labels: RangeLabels("₹${tempMin.round()}", "₹${tempMax.round()}"),
                    onChanged: (values) {
                      setModalState(() {
                        tempMin = values.start;
                        tempMax = values.end;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      "₹ ${tempMin.round()}".text.semiBold.make(),
                      "₹ ${tempMax.round()}".text.semiBold.make(),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = tempMin;
                          _maxPrice = tempMax;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: "Apply Filter".text.white.bold.make(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernProductCard(BuildContext context, ProductModel product, String baseUrl, FavoriteProvider provider) {
    final hasDiscount = product.originalPrice != null && product.originalPrice! > product.price;
    final discountPercent = hasDiscount ? (((product.originalPrice! - product.price) / product.originalPrice!) * 100).round() : 0;

    return GestureDetector(
      onTap: () => _navigateToDetail(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: _buildProductImage(product, baseUrl),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: "-$discountPercent%".text.white.bold.xs.make(),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => provider.toggleFavorite(product),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: product.categoryName!.toUpperCase().text.bold.xs.color(AppTheme.primaryColor).make(),
                      ),
                    product.title.text.bold.sm.maxLines(1).ellipsis.color(const Color(0xFF1E293B)).make(),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        "₹ ${product.price.toStringAsFixed(0)}".text.bold.color(AppTheme.primaryColor).make(),
                        if (hasDiscount) ...[
                          const SizedBox(width: 4),
                          "₹${product.originalPrice!.toStringAsFixed(0)}".text.gray400.xs.lineThrough.make(),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: (product.cityName ?? 'Global').text.xs.gray500.maxLines(1).ellipsis.make(),
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

  Widget _buildProductImage(ProductModel product, String baseUrl) {
    final imageUrl = product.resolveImageUrl(baseUrl);
    
    if (imageUrl == null) {
      return Container(
        color: Colors.grey.shade100,
        child: const Center(child: Icon(Icons.image_outlined, color: Colors.grey, size: 30)),
      );
    }

    if (imageUrl.startsWith('data:image') || imageUrl.length > 500) {
      try {
        final base64Str = imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl;
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade100,
            child: const Icon(Icons.image_outlined, color: Colors.grey),
          ),
        );
      } catch (e) {
        return Container(
          color: Colors.grey.shade100,
          child: const Icon(Icons.image_outlined, color: Colors.grey),
        );
      }
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: Colors.grey.shade100),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade100,
        child: const Icon(Icons.image_outlined, color: Colors.grey),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_rounded, size: 80, color: AppTheme.primaryColor.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 32),
          "Wishlist is empty".text.xl2.bold.make(),
          const SizedBox(height: 12),
          "Save items you're interested in\nand we'll track them for you.".text.center.gray500.make(),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
            child: "Start Shopping".text.bold.make(),
          ),
        ],
      ),
    );
  }
}
