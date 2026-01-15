import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final String? title;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.title,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  ProductModel? _product;
  bool _isLoading = true;
  String? _error;

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

  void _contactSeller() {
    if (_product == null) return;
    
    ToastUtils.showInfo(context, 'Opening chat with seller...');
    // TODO: Navigate to messages screen
  }

  void _makeOffer() {
    if (_product == null || _product!.isSold) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make an Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${_product!.title}'),
            const SizedBox(height: 8),
            Text(
              'Listed Price: \$${_product!.price.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your Offer',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtils.showSuccess(context, 'Offer sent to seller!');
            },
            child: const Text('Send Offer'),
          ),
        ],
      ),
    );
  }
  
  void _shareProduct() {
      if (_product == null) return;
      ToastUtils.showInfo(context, 'Sharing product: ${_product!.title}');
      // Implement share functionality
  }

  @override
  Widget build(BuildContext context) {
    // Access FavoriteProvider to check status
    // Note: In a real app we'd need to resolve favorite status for this product
    // For now, we'll assume the provider has a way to check or we just show the toggle
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(widget.productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Product Details'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? Colors.red : null,
            onPressed: () async {
                try {
                  await favoriteProvider.toggleFavorite(widget.productId);
                  if (mounted) {
                    // Check status after toggle if we want precise message, 
                    // or just rely on the toggle action result if it returned status
                    // Simply showing opposite of previous state for message:
                    if (!isFavorite) {
                      ToastUtils.showSuccess(context, 'Added to favorites');
                    } else {
                      ToastUtils.showInfo(context, 'Removed from favorites');
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ToastUtils.showError(context, 'Failed to update favorites');
                  }
                }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
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
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchProduct,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildProductContent(),
      bottomNavigationBar: _product != null && !_product!.isSold
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _contactSeller,
                      icon: const Icon(Icons.message),
                      label: const Text('Contact'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _makeOffer,
                      icon: const Icon(Icons.local_offer),
                      label: const Text('Make Offer'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildProductContent() {
    if (_product == null) return const SizedBox();

    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Carousel
          Stack(
             children: [
               if (_product!.images != null && _product!.images!.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 350.0,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: _product!.images!.length > 1,
                    autoPlay: _product!.images!.length > 1,
                  ),
                  items: _product!.images!.map((image) {
                    final imageId = image['id'];
                    final imageUrl = '$baseUrl/api/images/product/$imageId';
                    
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (_, child, progress) => progress == null 
                          ? child 
                          : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    );
                  }).toList(),
                )
              else
                _buildPlaceholder(),

              // Back Button Overlay
              SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ).box.color(Colors.black.withOpacity(0.3)).roundedFull.make().p16(),
              ),
            ],
          ),

          VStack([
            // Title & Price
            HStack([
               _product!.title.text.xl2.bold.make().expand(),
               "\$${_product!.price.toStringAsFixed(0)}".text.xl3.bold.color(context.theme.primaryColor).make(),
            ], crossAlignment: CrossAxisAlignment.start),
            
            if (_product!.hasDiscount)
               "\$${_product!.originalPrice!.toStringAsFixed(0)}".text.lg.lineThrough.gray500.make().objectCenterRight(),
            
            16.heightBox,

            // Sold Status
            if (_product!.isSold)
              "This item is SOLD".text.white.bold.make()
                  .p12()
                  .box.red500.rounded.make()
                  .w(double.infinity),

            24.heightBox,

            // Description Section
            "Description".text.xl.bold.make(),
            8.heightBox,
            _product!.description.text.lg.color(Vx.gray700).heightRelaxed.make(),
            
            24.heightBox,
            
            // Details Grid (Using existing method but wrapped)
            "Details".text.xl.bold.make(),
            16.heightBox,
            _buildDetailRow('Condition', _product!.condition.toUpperCase()),
            _buildDetailRow('Category', _product!.category?['name'] ?? 'N/A'),
            _buildDetailRow('Location', _product!.location?['name'] ?? 'N/A'),
            _buildDetailRow('Views', _product!.viewsCount.toString()),

            100.heightBox, // Bottom padding
          ]).p24(),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 350,
      color: Vx.gray200,
      child: const Center(child: Icon(Icons.image, size: 64, color: Vx.gray400)),
    );
  }


  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
