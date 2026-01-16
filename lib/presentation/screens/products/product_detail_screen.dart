import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
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

  void _contactSeller() {
    if (_product == null) return;
    ToastUtils.showInfo(context, 'Opening chat with seller...');
    // TODO: Navigate to messages
  }

  void _makeOffer() {
    if (_product == null || _product!.isSold) return;
    // Show make offer dialog
    ToastUtils.showInfo(context, 'Make offer implementation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
    
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

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
              icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
             Consumer<FavoriteProvider>(
               builder: (context, favProvider, _) {
                 final isFav = favProvider.isFavorite(widget.productId);
                 return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                      color: isFav ? Colors.red : AppTheme.textColor,
                      onPressed: () async {
                         await favProvider.toggleFavorite(widget.productId);
                      },
                    ),
                 );
               },
             ),
             Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, color: AppTheme.textColor),
                  onPressed: () {},
                ),
             ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (_product!.images != null && _product!.images!.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 500, // Covers full area
                      viewportFraction: 1.0,
                      enableInfiniteScroll: _product!.images!.length > 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                           _currentImageIndex = index;
                        });
                      },
                    ),
                    items: _product!.images!.map((image) {
                       final imageUrl = '$baseUrl/api/images/product/${image['id']}';
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
                    bottom: 30, // Above the curved sheet
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
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            // Negative margin to pull it up over the image bottom
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
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
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
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${_product!.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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
                  
                  
                  const Divider(height: 32),
                  
                  // Seller Info Card
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage('https://placehold.co/50x50.png'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rahul K.',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  
                  const SizedBox(height: 24),
                  _ExpandableDescription(description: _product!.description),
                  
                  const SizedBox(height: 24),
                  _buildSpecsGrid(),
                  
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ),
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
          // Row 1: Condition | Brand
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(
                  'Condition',
                  _product!.condition == 'LIKE_NEW'
                      ? 'Used - Like New'
                      : _product!.condition.toUpperCase(),
                  color: Colors.black,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.black),
              Expanded(
                child: _buildSpecItem(
                  'Brand',
                  'Studio 64',
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Divider(height: 24, color: Colors.grey[300]),
          // Row 2: Material | Dimensions
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(
                  'Material',
                  'Wood & Fabric',
                  color: Colors.black,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.black),
              Expanded(
                child: _buildSpecItem(
                  'Dimensions',
                  '32"W x 30"D',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpecItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color ?? Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
     if (_product == null || _product!.isSold) return const SizedBox.shrink();
     
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
              Expanded(
                child: OutlinedButton(
                  onPressed: _contactSeller,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _makeOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Call Seller'), // Changed to Call Seller as per design prompt
                ),
              ),
            ],
          ),
        ),
     );
  }
  
  Widget _buildDetailGrid() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildGridRow('Condition', _product!.condition.toUpperCase()),
            const Divider(),
            // _buildGridRow('Brand', _product!.brand ?? 'N/A'),
            const Divider(),
            _buildGridRow('Posted', '2 days ago'), // Mock
          ],
        ),
      );
  }
  
  Widget _buildGridRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Expandable Description Widget
class _ExpandableDescription extends StatefulWidget {
  final String description;
  
  const _ExpandableDescription({required this.description});
  
  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    const maxLines = 3;
    final text = widget.description;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: _isExpanded ? null : maxLines,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 15),
        ),
        if (text.length > 100) // Show Read More if text is long enough
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _isExpanded ? 'Read Less' : 'Read More',
                style: const TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
