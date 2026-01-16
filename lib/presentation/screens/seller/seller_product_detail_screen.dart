import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import 'edit_product_screen.dart';

class SellerProductDetailScreen extends StatefulWidget {
  final int productId;
  final String? title;

  const SellerProductDetailScreen({
    super.key,
    required this.productId,
    this.title,
  });

  @override
  State<SellerProductDetailScreen> createState() => _SellerProductDetailScreenState();
}

class _SellerProductDetailScreenState extends State<SellerProductDetailScreen> {
  final ProductService _productService = ProductService();
  ProductModel? _product;
  bool _isLoading = true;
  String? _error;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final product = await _productService.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
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

  Future<void> _markAsSold() async {
    if (_product == null) return;
    try {
      await _productService.markAsSold(_product!.id);
      ToastUtils.showSuccess(context, 'Product marked as sold');
      _fetchProduct();
    } catch (e) {
      ToastUtils.showError(context, 'Failed to update status: $e');
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(_product!.id);
        if (mounted) {
          ToastUtils.showSuccess(context, 'Product deleted successfully');
          Navigator.pop(context); // Go back to My Ads
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError(context, 'Failed to delete: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_product == null) return const SizedBox.shrink();

    return CustomScrollView(
      slivers: [
        // App Bar with Image Carousel
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (_product!.images != null && _product!.images!.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 500,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: _product!.images!.length > 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                           _currentImageIndex = index;
                        });
                      },
                    ),
                    items: _product!.images!.map((image) {
                       final imageUrl = '${ApiConstants.baseUrl.replaceAll('/api', '')}/api/images/product/${image['id']}?t=${DateTime.now().millisecondsSinceEpoch}';
                       return Image.network(
                         imageUrl,
                         fit: BoxFit.cover,
                         width: double.infinity,
                         errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                       );
                    }).toList(),
                  )
                else
                  Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 64, color: Colors.grey)),
                  
                // Image Indicator
                if (_product!.images != null && _product!.images!.length > 1)
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _product!.images!.asMap().entries.map((entry) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(_currentImageIndex == entry.key ? 0.9 : 0.4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Status Overlay
                Positioned(
                  top: 50,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _product!.isSold ? Colors.grey : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _product!.isSold ? 'SOLD' : 'ACTIVE',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Product Details Sheet
        SliverToBoxAdapter(
          child: Container(
             decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
              ],
            ),
            transform: Matrix4.translationValues(0.0, -20.0, 0.0), 
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title & Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _product!.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${_product!.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location
                  if (_product!.location != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _product!.location!['name'] ?? 'Unknown Location',
                          style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Analytics Section (Seller Only)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAnalyticItem(Icons.visibility, '${_product!.viewsCount}', 'Views'),
                        Container(height: 30, width: 1, color: Colors.grey[300]),
                        _buildAnalyticItem(Icons.favorite, '0', 'Likes'), // Placeholder for likes
                        Container(height: 30, width: 1, color: Colors.grey[300]),
                        _buildAnalyticItem(Icons.calendar_today, '2 days', 'Listed'), // Placeholder
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_product!.description, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
                  
                  const SizedBox(height: 24),
                  _buildSpecsGrid(),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSpecsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
           Row(
            children: [
              Expanded(child: _buildSpecItem('Condition', _product!.condition == 'LIKE_NEW' ? 'Used - Like New' : _product!.condition.toUpperCase())),
              Container(width: 1, height: 40, color: Colors.black),
              Expanded(child: _buildSpecItem('Brand', 'Studio 64')), // Mock
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
     if (_product == null) return const SizedBox.shrink();
     
     return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Edit Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProductScreen(product: _product!),
                      ),
                    ).then((_) => _fetchProduct());
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 18, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Mark as Sold / Active Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _product!.isSold ? null : _markAsSold,
                   style: ElevatedButton.styleFrom(
                    backgroundColor: _product!.isSold ? Colors.grey : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _product!.isSold ? 'Sold' : 'Mark Sold', 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Delete Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _deleteProduct,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
     );
  }
}
