import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../providers/auth_provider.dart';
import '../products/product_detail_screen.dart';
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

  // Filtered products based on selected filter
  List<ProductModel> get _filteredProducts {
    if (_selectedFilter == 'All') return _products;
    if (_selectedFilter == 'Active') return _products.where((p) => !p.isSold).toList();
    if (_selectedFilter == 'Sold') return _products.where((p) => p.isSold).toList();
    return _products; // Pending - not implemented yet
  }

  // Stats
  int get _totalAds => _products.length;
  int get _activeAds => _products.where((p) => !p.isSold).length;
  int get _soldAds => _products.where((p) => p.isSold).length;
  int get _totalViews => 0; // Views not implemented yet


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
          ToastUtils.showSuccess(context, 'Product deleted successfully');
          _fetchMyProducts(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError(context, 'Failed to delete: $e');
        }
      }
    }
  }

  Future<void> _markAsSold(int productId) async {
    try {
      await _productService.markAsSold(productId);
      if (mounted) {
        ToastUtils.showSuccess(context, 'Product marked as sold');
        _fetchMyProducts(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Failed to mark as sold: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isSeller = authProvider.user?.role == 'seller';

    if (!isSeller) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
             title: "My Products".text.color(AppTheme.textColor).xl2.bold.make(),
             backgroundColor: AppTheme.backgroundColor,
             elevation: 0,
             centerTitle: true,
             iconTheme: const IconThemeData(color: AppTheme.textColor),
        ),
        body: const Center(
          child: Text('Only sellers can manage products'),
        ),
      );
    }

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
                          Expanded(child: _buildStatCard('Sold', _soldAds, Icons.sell, Colors.grey)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Views', _totalViews, Icons.visibility, AppTheme.secondaryColor)),
                        ],
                      ),
                    ),
                    
                    // Filter Tabs
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterTab('All'),
                          const SizedBox(width: 8),
                          _buildFilterTab('Active'),
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
                          '${ApiConstants.baseUrl.replaceAll('/api', '')}${product.firstImageUrl}',
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
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.isSold ? Colors.grey.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: product.isSold ? Colors.grey.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                          width: 0.5
                        ),
                      ),
                      child: Text(
                        product.isSold ? 'SOLD' : 'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: product.isSold ? Colors.grey : Colors.green,
                        ),
                      ),
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
                  } else if (value == 'activate' || value == 'deactivate') {
                    // TODO: Implement activate/deactivate functionality
                    ToastUtils.showSuccess(context, value == 'activate' ? 'Product activated' : 'Product deactivated');
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
                  if (product.isActive)
                    const PopupMenuItem(
                      value: 'deactivate', 
                      child: Text('Deactivate', style: TextStyle(color: Colors.black))
                    )
                  else
                    const PopupMenuItem(
                      value: 'activate', 
                      child: Text('Activate', style: TextStyle(color: Colors.black))
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)), // Keep delete red
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
