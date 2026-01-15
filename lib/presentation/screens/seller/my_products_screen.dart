import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../providers/auth_provider.dart';
import '../products/product_detail_screen.dart';
import '../../../core/utils/toast_utils.dart';
import 'create_product_screen.dart';
import 'edit_product_screen.dart';

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
        appBar: AppBar(title: const Text('My Products')),
        body: const Center(
          child: Text('Only sellers can manage products'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No products yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
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
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.shopping_bag),
                            ),
                            title: Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      product.isActive
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 16,
                                      color: product.isActive
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: product.isActive
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text('${product.viewsCount}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'view') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                        productId: product.id,
                                      ),
                                    ),
                                  );
                                } else if (value == 'edit') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProductScreen(
                                        product: product,
                                      ),
                                    ),
                                  );
                                  _fetchMyProducts();
                                } else if (value == 'sold') {
                                  _markAsSold(product.id);
                                } else if (value == 'delete') {
                                  _deleteProduct(product.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility),
                                      SizedBox(width: 8),
                                      Text('View'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                if (product.isActive)
                                  const PopupMenuItem(
                                    value: 'sold',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check),
                                        SizedBox(width: 8),
                                        Text('Mark as Sold'),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    productId: product.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateProductScreen()),
          );
          _fetchMyProducts(); // Refresh after creating product
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
