import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import 'create_product_screen.dart';
import 'edit_product_screen.dart';
import 'seller_product_detail_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'All'; // All, Active, Sold, Pending
  String _selectedCategory = 'All Categories';
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  List<String> get _categories {
    final cats = _products.map((p) => p.categoryName ?? 'Other').toSet().toList();
    cats.sort();
    return ['All Categories', ...cats];
  }

  // Filtered products based on selected filter
  List<ProductModel> get _filteredProducts {
    var filtered = _products;
    
    if (_selectedFilter == 'Active') filtered = filtered.where((p) => p.isActive).toList();
    if (_selectedFilter == 'Inactive') filtered = filtered.where((p) => !p.isActive && !p.isSold).toList();
    if (_selectedFilter == 'Sold') filtered = filtered.where((p) => p.isSold).toList();
    
    if (_selectedCategory != 'All Categories') {
      filtered = filtered.where((p) => (p.categoryName ?? 'Other') == _selectedCategory).toList();
    }
    
    if (_searchQuery.trim().isNotEmpty) {
      filtered = filtered.where((p) => p.title.toLowerCase().contains(_searchQuery.trim().toLowerCase())).toList();
    }
    
    if (_selectedDateRange != null) {
      filtered = filtered.where((p) {
        final dateStr = p.createdAt;
        if (dateStr.isEmpty) return false;
        final date = DateTime.tryParse(dateStr);
        if (date == null) return false;
        final itemDate = DateTime(date.year, date.month, date.day);
        final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day);
        return itemDate.isAfter(start.subtract(const Duration(days: 1))) && itemDate.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    }
    
    return filtered;
  }

  // Stats
  int get _totalAds => _products.length;
  int get _activeAds => _products.where((p) => p.isActive).length;
  int get _inactiveAds => _products.where((p) => !p.isActive && !p.isSold).length;
  int get _soldAds => _products.where((p) => p.isSold).length;


  @override
  void initState() {
    super.initState();
    _fetchMyProducts();
  }

  Future<void> _fetchMyProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _productService.getMyProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct(int productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(productId);
        if (mounted) {
          ToastUtils.showSuccess('Product deleted successfully');
          _fetchMyProducts(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError('Failed to delete: $e');
        }
      }
    }
  }

  Future<void> _markAsSold(int productId) async {
    try {
      await _productService.markAsSold(productId);
      if (mounted) {
        ToastUtils.showSuccess('Product marked as sold');
        _fetchMyProducts(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError('Failed to mark as sold: $e');
      }
    }
  }

  Future<void> _relistProduct(int productId) async {
    try {
      await _productService.relistProduct(productId);
      if (mounted) {
        ToastUtils.showSuccess('Product relisted successfully!');
        _fetchMyProducts();
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError('Failed to relist product: $e');
      }
    }
  }

  Future<void> _activateProduct(int productId) async {
    try {
      await _productService.relistProduct(productId);
      if (mounted) {
        ToastUtils.showSuccess('Product activated!');
        _fetchMyProducts();
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError('Failed to activate product: $e');
      }
    }
  }

  Future<void> _deactivateProduct(int productId) async {
    try {
      await _productService.deactivateProduct(productId);
      if (mounted) {
        ToastUtils.showSuccess('Product deactivated.');
        _fetchMyProducts();
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError('Failed to deactivate product: $e');
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Role check removed — all users can manage their own ads
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: "My Ads".text.color(AppTheme.textColor).xl2.bold.make(),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textColor),
            onPressed: _fetchMyProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchMyProducts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Stats Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: _buildStatCard('Total', _totalAds, Icons.inventory_2, AppTheme.primaryColor)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Active', _activeAds, Icons.check_circle, Colors.green)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Inactive', _inactiveAds, Icons.pause_circle, Colors.orange)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Sold', _soldAds, Icons.sell, Colors.grey)),
                        ],
                      ),
                    ),
                    
                    // Advanced Filters Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          // Search Bar
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          // Dropdowns and Date Picker Row
                          Row(
                            children: [
                              // Category Dropdown
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategory,
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() => _selectedCategory = newValue);
                                        }
                                      },
                                      items: _categories.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Date Range Picker Button
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                    initialDateRange: _selectedDateRange,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: AppTheme.primaryColor,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() => _selectedDateRange = picked);
                                  }
                                },
                                icon: const Icon(Icons.calendar_today, size: 18),
                                label: Text(_selectedDateRange == null ? 'Date' : 'Filtered'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  side: BorderSide(color: _selectedDateRange == null ? Colors.grey[300]! : AppTheme.primaryColor),
                                ),
                              ),
                              if (_selectedDateRange != null) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() => _selectedDateRange = null);
                                  },
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Filter Tabs (Status)
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterTab('All'),
                          const SizedBox(width: 8),
                          _buildFilterTab('Active'),
                          const SizedBox(width: 8),
                          _buildFilterTab('Inactive'),
                          const SizedBox(width: 8),
                          _buildFilterTab('Sold'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Product List
                    Expanded(
                      child: _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedFilter == 'All' ? 'No products yet' : 'No $_selectedFilter products',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap + to create your first product',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return _buildProductCard(product);
                            },
                          ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateProductScreen()),
          ).then((_) => _fetchMyProducts());
        },
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      key: ValueKey(product.id),
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shadowColor: Colors.black26, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SellerProductDetailScreen(productId: product.id, title: product.title),
            ),
          ).then((_) => _fetchMyProducts());
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[100],
                  child: product.firstImageUrl != null
                      ? Image.network(
                          product.firstImageUrl!.startsWith('http')
                              ? product.firstImageUrl!
                              : '${ApiConstants.baseUrl.replaceAll('/api', '')}${product.firstImageUrl}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 32, color: Colors.grey),
                        )
                      : const Icon(Icons.shopping_bag, size: 32, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.categoryName ?? 'Other',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    // Location
                    if ((product.cityName ?? product.locationName) != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 11, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              [product.cityName, product.stateName].where((s) => s != null && s.isNotEmpty).join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    // Price row
                    Row(
                      children: [
                        Text(
                          '₹ ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        if (product.condition.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.condition,
                              style: const TextStyle(fontSize: 10, color: Colors.blue),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Status + Date row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: product.isSold
                                ? Colors.grey.withAlpha(25)
                                : !product.isActive
                                    ? Colors.orange.withAlpha(25)
                                    : Colors.green.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: product.isSold
                                  ? Colors.grey.withAlpha(77)
                                  : !product.isActive
                                      ? Colors.orange.withAlpha(77)
                                      : Colors.green.withAlpha(77),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            product.isSold ? 'SOLD' : (!product.isActive ? 'INACTIVE' : 'ACTIVE'),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: product.isSold
                                  ? Colors.grey
                                  : !product.isActive
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (product.createdAt.isNotEmpty)
                          Text(
                            _formatDate(product.createdAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black), // Black 3-dot icon
                color: Colors.white,
                surfaceTintColor: Colors.white,
                 onSelected: (value) {
                  if (value == 'view') {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SellerProductDetailScreen(productId: product.id, title: product.title),
                      ),
                    ).then((_) => _fetchMyProducts());
                  } else if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
                    ).then((_) => _fetchMyProducts());
                  } else if (value == 'sold') {
                    _markAsSold(product.id);
                  } else if (value == 'relist') {
                    _relistProduct(product.id);
                  } else if (value == 'activate') {
                    _activateProduct(product.id);
                  } else if (value == 'deactivate') {
                    _deactivateProduct(product.id);
                  } else if (value == 'delete') {
                    _deleteProduct(product.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view', 
                    child: Text('View', style: TextStyle(color: Colors.black))
                  ),
                  if (!product.isSold)
                    const PopupMenuItem(
                      value: 'edit', 
                      child: Text('Edit', style: TextStyle(color: Colors.black))
                    ),
                  if (!product.isSold)
                    const PopupMenuItem(
                      value: 'sold', 
                      child: Text('Mark as Sold', style: TextStyle(color: Colors.black))
                    ),
                  if (product.isSold)
                    const PopupMenuItem(
                      value: 'relist',
                      child: Row(
                        children: [
                          Icon(Icons.replay, color: Colors.green, size: 18),
                          SizedBox(width: 8),
                          Text('Relist', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  if (product.isActive)
                    const PopupMenuItem(
                      value: 'deactivate', 
                      child: Text('Deactivate', style: TextStyle(color: Colors.black))
                    )
                  else if (!product.isSold)
                    const PopupMenuItem(
                      value: 'activate', 
                      child: Text('Activate', style: TextStyle(color: Colors.black))
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

