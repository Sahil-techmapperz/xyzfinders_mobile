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
import '../categories/real_estate/real_estate_detail_screen.dart';
import '../../../data/services/category_service.dart';
import '../../../data/models/category_model.dart';

class ProductListScreen extends StatefulWidget {
  final String? searchQuery;
  final int? categoryId;
  final String? categoryName;

  const ProductListScreen({
    super.key,
    this.searchQuery,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Future<List<CategoryModel>>? _categoriesFuture;
  
  // Persistent filter state
  double _minPrice = 0;
  double _maxPrice = 100000;
  String? _selectedCondition;
  int? _selectedCategoryId;
  String? _selectedSortBy;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _categoriesFuture = CategoryService().getCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(
            refresh: true,
            search: widget.searchQuery,
            categoryId: widget.categoryId,
          );
    });
    _scrollController.addListener(_onScroll);
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
            search: widget.searchQuery,
            categoryId: widget.categoryId,
          );
    }
  }

  Future<void> _onRefresh() async {
    await context.read<ProductProvider>().fetchProducts(
          refresh: true,
          search: widget.searchQuery,
          categoryId: widget.categoryId,
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
                              child: Text("All Categories"),
                            ),
                            ...categories.map((cat) {
                              return DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(cat.name),
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
                                search: _searchController.text.isEmpty ? widget.searchQuery : _searchController.text,
                                categoryId: _selectedCategoryId,
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
                            _selectedSortBy = null;
                          });
                          Navigator.pop(context);
                          context.read<ProductProvider>().fetchProducts(
                                refresh: true,
                                search: _searchController.text.isEmpty ? widget.searchQuery : _searchController.text,
                                categoryId: widget.categoryId,
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
    final title = widget.searchQuery != null
        ? "Results for '${widget.searchQuery}'"
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
                      if (widget.searchQuery == null && widget.categoryId == null)
                        FeaturedCarousel(products: provider.products),
                      if (widget.searchQuery == null && widget.categoryId == null)
                        20.heightBox,
                      (widget.searchQuery != null ? "Search Results" : "Recent Listings")
                          .text
                          .xl
                          .semiBold
                          .color(AppTheme.textColor)
                          .make()
                          .pOnly(left: 16, bottom: 8),
                      if (widget.searchQuery == null && widget.categoryId == null)
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
                                                setState(() {});
                                                // Clear current search results and reset to original category/query
                                                context.read<ProductProvider>().fetchProducts(
                                                      refresh: true,
                                                      search: widget.searchQuery,
                                                      categoryId: _selectedCategoryId ?? widget.categoryId,
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
                                      context.read<ProductProvider>().fetchProducts(
                                            refresh: true,
                                            search: val.isEmpty ? widget.searchQuery : val,
                                            categoryId: _selectedCategoryId ?? widget.categoryId,
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
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = provider.products[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RealEstateDetailScreen(
                                    productId: product.id,
                                  ),
                                ),
                              );
                            },
                          ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
                        },
                        childCount: provider.products.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75, // Adjusted for card height
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
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
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

