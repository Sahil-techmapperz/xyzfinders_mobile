import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/product_provider.dart';
import '../../widgets/products/product_card.dart';
import '../../widgets/featured_carousel.dart';
import '../../../core/utils/product_navigation_utils.dart';
import '../../../data/services/category_service.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';
import '../../../data/models/category_model.dart';
import '../../../core/config/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../widgets/common/location_search_sheet.dart';

class ProductListScreen extends StatefulWidget {
  final String? searchQuery;
  final int? categoryId;
  final String? categoryName;
  final int? locationId;
  final String? locationName;

  const ProductListScreen({
    super.key,
    this.searchQuery,
    this.categoryId,
    this.categoryName,
    this.locationId,
    this.locationName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Future<List<CategoryModel>>? _categoriesFuture;
  Future<List<dynamic>>? _locationsFuture;
  
  // Persistent filter state
  double _minPrice = 0;
  double _maxPrice = 100000;
  String? _selectedCondition;
  int? _selectedCategoryId;
  int? _selectedLocationId;
  String? _selectedLocationName;
  String? _selectedSortBy;
  String? _currentSearchQuery;

  @override
  void initState() {
    super.initState();
    _currentSearchQuery = widget.searchQuery;
    _searchController.text = _currentSearchQuery ?? '';
    _selectedCategoryId = widget.categoryId;
    _selectedLocationId = widget.locationId;
    _selectedLocationName = widget.locationName;
    _categoriesFuture = CategoryService().getCategories();
    _locationsFuture = _fetchLocations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(
            refresh: true,
            search: _currentSearchQuery,
            categoryId: widget.categoryId,
            locationId: widget.locationId,
            locationSearch: widget.locationId == null ? widget.locationName : null,
          );
    });
    _scrollController.addListener(_onScroll);
  }

  Future<List<dynamic>> _fetchLocations() async {
    try {
      final response = await ApiService().get(ApiConstants.locations);
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Error fetching locations in ProductListScreen: $e');
    }
    return [];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ProductProvider>().loadMore(
            search: _currentSearchQuery,
            categoryId: widget.categoryId,
            locationId: _selectedLocationId,
            locationSearch: _selectedLocationId == null ? _selectedLocationName : null,
          );
    }
  }

  Future<void> _onRefresh() async {
    await context.read<ProductProvider>().fetchProducts(
          refresh: true,
          search: _currentSearchQuery,
          categoryId: widget.categoryId,
          locationId: _selectedLocationId,
          locationSearch: _selectedLocationId == null ? _selectedLocationName : null,
        );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        "Filter Products".text.xl2.bold.make(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    20.heightBox,

                    // Location Filter
                    "Location".text.bold.make(),
                    10.heightBox,
                    FutureBuilder<List<dynamic>>(
                      future: _locationsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return "No locations available".text.color(Colors.grey).make();
                        }
                        
                        final locations = snapshot.data!;
                        final displayLocation = _selectedLocationId != null
                            ? "${locations.firstWhere((l) => l['id'] == _selectedLocationId, orElse: () => {'name': 'Unknown', 'city_name': ''})['name']}, ${locations.firstWhere((l) => l['id'] == _selectedLocationId, orElse: () => {'city_name': ''})['city_name']}"
                            : (_selectedLocationName ?? "All Locations");

                        return InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return LocationSearchSheet(
                                  locations: locations,
                                  selectedLocationId: _selectedLocationId,
                                  selectedLocationName: _selectedLocationName,
                                  onSelect: (id, name) {
                                    setModalState(() {
                                      _selectedLocationId = id;
                                      _selectedLocationName = name;
                                    });
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    displayLocation,
                                    style: TextStyle(
                                      color: _selectedLocationId != null || _selectedLocationName != null ? Colors.black : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    20.heightBox,
                    
                    // Category Filter
                    "Category".text.bold.make(),
                    10.heightBox,
                    FutureBuilder<List<CategoryModel>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          debugPrint('Category load error: ${snapshot.error}');
                          return "Error loading categories".text.color(Colors.red).make();
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return "No categories available".text.color(Colors.grey).make();
                        }
                        
                        final categories = snapshot.data!;
                        return DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          hint: const Text("All Categories"),
                          value: _selectedCategoryId,
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text("All Categories", overflow: TextOverflow.ellipsis),
                            ),
                            ...categories.map((cat) {
                              return DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(cat.name, overflow: TextOverflow.ellipsis),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setModalState(() => _selectedCategoryId = val);
                          },
                        );
                      },
                    ),
                    20.heightBox,

                    // Sort By Price
                    "Sort By".text.bold.make(),
                    10.heightBox,
                    Wrap(
                      spacing: 10,
                      children: [
                        ChoiceChip(
                          label: const Text('Default'),
                          selected: _selectedSortBy == null,
                          onSelected: (selected) {
                            if (selected) setModalState(() => _selectedSortBy = null);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Price: Low to High'),
                          selected: _selectedSortBy == 'price_low',
                          onSelected: (selected) {
                            if (selected) setModalState(() => _selectedSortBy = 'price_low');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Price: High to Low'),
                          selected: _selectedSortBy == 'price_high',
                          onSelected: (selected) {
                            if (selected) setModalState(() => _selectedSortBy = 'price_high');
                          },
                        ),
                      ],
                    ),
                    20.heightBox,

                    // Price Range
                    "Price Range".text.bold.make(),
                    10.heightBox,
                    RangeSlider(
                      values: RangeValues(_minPrice, _maxPrice),
                      min: 0,
                      max: 100000,
                      divisions: 100,
                      activeColor: AppTheme.primaryColor,
                      labels: RangeLabels('₹${_minPrice.toInt()}', '₹${_maxPrice.toInt()}'),
                      onChanged: (values) {
                        setModalState(() {
                          _minPrice = values.start;
                          _maxPrice = values.end;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        '₹${_minPrice.toInt()}'.text.color(Colors.grey).make(),
                        '₹${_maxPrice.toInt()}'.text.color(Colors.grey).make(),
                      ],
                    ),
                    20.heightBox,

                    // Condition
                    "Condition".text.bold.make(),
                    10.heightBox,
                    Wrap(
                      spacing: 10,
                      children: [
                        ChoiceChip(
                          label: const Text('Any'),
                          selected: _selectedCondition == null,
                          onSelected: (selected) {
                            if (selected) setModalState(() => _selectedCondition = null);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('New'),
                          selected: _selectedCondition == 'new',
                          onSelected: (selected) {
                            if (selected) setModalState(() => _selectedCondition = 'new');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Used'),
                          selected: _selectedCondition == 'used',
                          onSelected: (selected) {
                            if (selected) setModalState(() => _selectedCondition = 'used');
                          },
                        ),
                      ],
                    ),
                    30.heightBox,
                    
                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<ProductProvider>().fetchProducts(
                                refresh: true,
                                search: _currentSearchQuery,
                                categoryId: _selectedCategoryId,
                                locationId: _selectedLocationId,
                                locationSearch: _selectedLocationId == null ? _selectedLocationName : null,
                                minPrice: _minPrice > 0 ? _minPrice : null,
                                maxPrice: _maxPrice < 100000 ? _maxPrice : null,
                                condition: _selectedCondition,
                                sortBy: _selectedSortBy,
                              );
                        },
                        child: "Apply Filters".text.white.bold.make(),
                      ),
                    ),
                    12.heightBox,
                    // Clear Filters Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setModalState(() {
                            _minPrice = 0;
                            _maxPrice = 100000;
                            _selectedCondition = null;
                            _selectedCategoryId = widget.categoryId;
                            _selectedLocationId = widget.locationId;
                            _selectedLocationName = widget.locationName;
                            _selectedSortBy = null;
                          });
                          Navigator.pop(context);
                          context.read<ProductProvider>().fetchProducts(
                                refresh: true,
                                search: _currentSearchQuery,
                                categoryId: widget.categoryId,
                                locationId: widget.locationId,
                                locationSearch: widget.locationId == null ? widget.locationName : null,
                                minPrice: null,
                                maxPrice: null,
                                condition: null,
                                sortBy: null,
                              );
                        },
                        child: "Clear Filters".text.color(AppTheme.primaryColor).bold.make(),
                      ),
                    ),
                    20.heightBox,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _currentSearchQuery != null && _currentSearchQuery!.isNotEmpty
        ? "Results for '${_currentSearchQuery}'"
        : widget.categoryName ?? "Discover";

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: title.text.color(AppTheme.textColor).xl2.bold.make(),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.products.isEmpty) {
            return _buildShimmerLoading();
          }

          if (provider.error != null && provider.products.isEmpty) {
            return Center(
              child: VStack([
                const Icon(Icons.error_outline, size: 64, color: Vx.gray400),
                16.heightBox,
                provider.error!.text.color(Vx.gray600).center.make(),
                16.heightBox,
                ElevatedButton(
                  onPressed: _onRefresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Retry'),
                ),
              ], crossAlignment: CrossAxisAlignment.center).p16(),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.heightBox,
                      if (_currentSearchQuery == null && widget.categoryId == null)
                        FeaturedCarousel(products: provider.products),
                      if (_currentSearchQuery == null && widget.categoryId == null)
                        20.heightBox,
                      ((_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) ? "Search Results" : "Recent Listings")
                          .text
                          .xl
                          .semiBold
                          .color(AppTheme.textColor)
                          .make()
                          .pOnly(left: 16, bottom: 8),
                      if (_currentSearchQuery == null && widget.categoryId == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search products...',
                                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      hintStyle: TextStyle(color: Colors.grey.shade500),
                                      suffixIcon: _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {
                                                  _currentSearchQuery = null;
                                                });
                                                // Clear current search results and reset to original category/query
                                                context.read<ProductProvider>().fetchProducts(
                                                      refresh: true,
                                                      search: null,
                                                      categoryId: _selectedCategoryId ?? widget.categoryId,
                                                      locationId: _selectedLocationId,
                                                      locationSearch: _selectedLocationId == null ? _selectedLocationName : null,
                                                      minPrice: _minPrice > 0 ? _minPrice : null,
                                                      maxPrice: _maxPrice < 100000 ? _maxPrice : null,
                                                      condition: _selectedCondition,
                                                      sortBy: _selectedSortBy,
                                                    );
                                              },
                                            )
                                          : null,
                                    ),
                                    style: const TextStyle(color: Colors.black, fontSize: 16),
                                    textInputAction: TextInputAction.search,
                                    onSubmitted: (val) {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        _currentSearchQuery = val.trim().isEmpty ? null : val.trim();
                                      });
                                      context.read<ProductProvider>().fetchProducts(
                                            refresh: true,
                                            search: _currentSearchQuery,
                                            categoryId: _selectedCategoryId ?? widget.categoryId,
                                            locationId: _selectedLocationId,
                                            locationSearch: _selectedLocationId == null ? _selectedLocationName : null,
                                            minPrice: _minPrice > 0 ? _minPrice : null,
                                            maxPrice: _maxPrice < 100000 ? _maxPrice : null,
                                            condition: _selectedCondition,
                                            sortBy: _selectedSortBy,
                                          );
                                    },
                                    onChanged: (val) {
                                      setState(() {}); // to update the suffix close icon
                                    },
                                  ),
                                ),
                              ),
                              12.widthBox,
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.filter_list, color: Colors.white),
                                  onPressed: _showFilterBottomSheet,
                                ),
                              ),
                            ],
                          ),
                        ),
                      8.heightBox,
                    ],
                  ),
                ),
                if (provider.products.isEmpty)
                   SliverToBoxAdapter(
                     child: SizedBox(
                       height: MediaQuery.of(context).size.height * 0.4,
                       child: Center(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             const Icon(Icons.search_off, size: 64, color: Colors.grey),
                             16.heightBox,
                             "No ads found".text.xl.color(Colors.grey.shade600).make(),
                             8.heightBox,
                             "Try adjusting your filters or search term".text.color(Colors.grey.shade500).make(),
                           ],
                         ),
                       ),
                     ),
                   )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, rowIndex) {
                          final leftIndex = rowIndex * 2;
                          final rightIndex = leftIndex + 1;
                          final leftProduct = provider.products[leftIndex];
                          final rightProduct = rightIndex < provider.products.length
                              ? provider.products[rightIndex]
                              : null;

                          // NOTE: .animate() must wrap the outermost widget — NOT inside
                          // IntrinsicHeight, because animate() uses LayoutBuilder internally
                          // which doesn't support intrinsic dimensions.
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ProductCard(
                                    product: leftProduct,
                                    onTap: () => ProductNavigationUtils.navigateTo(context, leftProduct),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: rightProduct != null
                                      ? ProductCard(
                                          product: rightProduct,
                                          onTap: () => ProductNavigationUtils.navigateTo(context, rightProduct),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ).animate()
                            .fadeIn(duration: 400.ms, delay: (50 * rowIndex).ms)
                            .slideY(begin: 0.1, end: 0);
                        },
                        childCount: (provider.products.length / 2).ceil(),
                      ),
                    ),
                  ),
                if (provider.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                    ),
                  ),
                // Bottom padding for navigation bar
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 4,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

