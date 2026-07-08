import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import 'edit_product_screen.dart';
import '../../widgets/products/full_screen_image_viewer.dart';

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
      final product = await _productService.getMyProductById(widget.productId);
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
      ToastUtils.showSuccess('Product marked as sold');
      _fetchProduct();
    } catch (e) {
      ToastUtils.showError('Failed to update status: $e');
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
          ToastUtils.showSuccess('Product deleted successfully');
          Navigator.pop(context); // Go back to My Ads
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError('Failed to delete: $e');
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
                      final String imageVal = (image['image']?.toString() ?? image['id']?.toString() ?? '').trim();
                      String imageUrl;
                      
                      if (imageVal.toLowerCase().startsWith('http')) {
                        imageUrl = imageVal;
                      } else {
                        // Relative path - assume local server
                        final String cleanVal = imageVal.startsWith('/') ? imageVal.substring(1) : imageVal;
                        imageUrl = '${ApiConstants.baseUrl.replaceAll('/api', '')}/api/images/product/$cleanVal?t=${DateTime.now().millisecondsSinceEpoch}';
                      }
                      
                      return GestureDetector(
                        onTap: () {
                          final urls = _product!.images!.map<String>((img) {
                            final String imageVal = (img['image']?.toString() ?? img['id']?.toString() ?? '').trim();
                            if (imageVal.toLowerCase().startsWith('http')) {
                              return imageVal;
                            } else {
                              final String cleanVal = imageVal.startsWith('/') ? imageVal.substring(1) : imageVal;
                              return '${ApiConstants.baseUrl.replaceAll('/api', '')}/api/images/product/$cleanVal';
                            }
                          }).toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageViewer(
                                imageUrls: urls,
                                initialIndex: _product!.images!.indexOf(image),
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
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
                      color: _product!.isSold 
                          ? Colors.grey 
                          : (!_product!.isActive ? Colors.orange : Colors.green),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _product!.isSold 
                          ? 'SOLD' 
                          : (!_product!.isActive ? 'INACTIVE' : 'ACTIVE'),
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
                        '₹ ${_product!.price.toStringAsFixed(0)}',
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
                        _buildAnalyticItem(Icons.favorite_outline, '0', 'Likes'),
                        Container(height: 30, width: 1, color: Colors.grey[300]),
                        _buildAnalyticItem(Icons.update, _getListedTime(), 'Listed'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_product!.description, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    _getSpecsTitle(_product!.categoryName ?? 'Other'), 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 12),
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

  String _getListedTime() {
    if (_product?.createdAt == null) return 'Recent';
    try {
      final created = DateTime.parse(_product!.createdAt!);
      final diff = DateTime.now().difference(created);
      if (diff.inDays > 0) return '${diff.inDays} days';
      if (diff.inHours > 0) return '${diff.inHours} hrs';
      return 'Recent';
    } catch (_) {
      return 'Recent';
    }
  }

  String _getSpecsTitle(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('education')) return 'Education Details';
    if (cat.contains('service')) return 'Service Details';
    if (cat.contains('job')) return 'Job Specifications';
    if (cat.contains('fashion')) return 'Product Details';
    if (cat.contains('pet')) return 'Pet Information';
    if (cat.contains('electronic')) return 'Technical Specs';
    return 'Specifications';
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
    final attrs = _product!.productAttributes ?? {};
    final cat = (_product!.categoryName ?? '').toLowerCase();

    // Keys that are always internal and should never be shown
    final alwaysExclude = {
      'termsAccepted', 'product_attributes', 'specs', 'details',
      'category_id', 'location_id', 'location_area', 'user_id',
    };

    // Build a list of {label, value} pairs based on category
    List<Map<String, String>> items = [];

    // Condition display string
    final condDisplay = _product!.condition == 'like_new'
        ? 'Used - Like New'
        : _product!.condition.toUpperCase();

    // Condition: only relevant for physical goods, not real estate, jobs, or pets
    if (!cat.contains('real estate') && !cat.contains('propert') && !cat.contains('job') && !cat.contains('education') && !cat.contains('learning') && !cat.contains('pet')) {
      items.add({'label': 'Condition', 'value': condDisplay});
    }

    if (cat.contains('education') || cat.contains('learning') || cat.contains('tutor')) {
      _addIfNotEmpty(items, 'Type', attrs['educationType']);
      _addIfNotEmpty(items, 'Subject', attrs['subject'] ?? attrs['course_name']);
      _addIfNotEmpty(items, 'Level', attrs['level']);
      _addIfNotEmpty(items, 'Institute', attrs['institute']);
      _addIfNotEmpty(items, 'Duration', attrs['duration']);
      _addIfNotEmpty(items, 'Experience', attrs['experience']);
      _addIfNotEmpty(items, 'Batch Size', attrs['batchSize'] ?? attrs['batch_size']);
      _addIfNotEmpty(items, 'Mode', attrs['mode']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else if (cat.contains('beauty') || cat.contains('wellness') || cat.contains('salon') || cat.contains('spa')) {
      _addIfNotEmpty(items, 'Category', attrs['beautyType']);
      _addIfNotEmpty(items, 'Product Type', attrs['productType'] ?? attrs['serviceType']);
      _addIfNotEmpty(items, 'Duration', attrs['duration']);
      _addIfNotEmpty(items, 'Gender Preference', attrs['genderPreference']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else if (cat.contains('service')) {
      _addIfNotEmpty(items, 'Product Type', attrs['productType'] ?? attrs['serviceSubtype'] ?? attrs['serviceType']);
      _addIfNotEmpty(items, 'Experience', attrs['experience']);
      _addIfNotEmpty(items, 'Availability', attrs['availability']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else if (cat.contains('job')) {
      _addIfNotEmpty(items, 'Company', attrs['companyName'] ?? attrs['company']);
      _addIfNotEmpty(items, 'Experience Level', attrs['experienceLevel']);
      _addIfNotEmpty(items, 'Work Mode', attrs['jobType'] ?? attrs['workMode']);
      _addIfNotEmpty(items, 'Qualification', attrs['qualification']);
      _addIfNotEmpty(items, 'Gender Preference', attrs['gender'] ?? attrs['genderPreference']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else if (cat.contains('event')) {
      _addIfNotEmpty(items, 'Event Type', attrs['eventType']);
      _addIfNotEmpty(items, 'Date', attrs['eventDate']);
      _addIfNotEmpty(items, 'Time', attrs['eventTime']);
      _addIfNotEmpty(items, 'Venue', attrs['venue']);
      _addIfNotEmpty(items, 'Organizer', attrs['organizer']);
      // Highlights — stored as a list, join them
      final highlights = attrs['highlights'];
      if (highlights != null) {
        String highlightStr = '';
        if (highlights is List) {
          highlightStr = highlights.join(', ');
        } else {
          highlightStr = highlights.toString();
        }
        _addIfNotEmpty(items, 'Highlights', highlightStr);
      }
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else if (cat.contains('pet')) {
      _addIfNotEmpty(items, 'Pet Type', attrs['petType']);
      _addIfNotEmpty(items, 'Breed', attrs['breed']);
      _addIfNotEmpty(items, 'Age', attrs['age']);
      _addIfNotEmpty(items, 'Gender', attrs['gender']);
      _addIfNotEmpty(items, 'Color', attrs['color']);
      _addIfNotEmpty(items, 'Vaccinated', attrs['vaccinated']);
      _addIfNotEmpty(items, 'KCI Registered', attrs['kci']);
      _addIfNotEmpty(items, 'Health Certificate', attrs['certificate']);
      _addIfNotEmpty(items, 'Dewormed', attrs['dewormed']);
      _addIfNotEmpty(items, 'Microchipped', attrs['microchipped']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else if (cat.contains('real estate') || cat.contains('propert') || cat.contains('rent') || cat.contains('pg')) {
      _addIfNotEmpty(items, 'Listing Type', attrs['listingType']);
      _addIfNotEmpty(items, 'Property Type', attrs['propertyType'] ?? attrs['type']);
      _addIfNotEmpty(items, 'Bedrooms', attrs['bedrooms']);
      _addIfNotEmpty(items, 'Bathrooms', attrs['bathrooms']);
      _addIfNotEmpty(items, 'Balcony', attrs['balcony']);
      _addIfNotEmpty(items, 'Area (sq ft)', attrs['area']);
      _addIfNotEmpty(items, 'Kitchen', attrs['kitchen']);
      _addIfNotEmpty(items, 'Attached Bath', attrs['attachedBathroom']);
      _addIfNotEmpty(items, 'Furnished', attrs['furnished'] ?? attrs['furnishedStatus']);
      _addIfNotEmpty(items, 'Tenant Preference', attrs['tenants'] ?? attrs['tenantPreference']);
      _addIfNotEmpty(items, 'Room Type', attrs['roomType']);
      _addIfNotEmpty(items, 'Security Deposit', attrs['securityDeposit']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
      // Amenities — stored as a list, join them
      final amenities = attrs['amenities'];
      if (amenities != null) {
        String amenityStr = '';
        if (amenities is List) {
          amenityStr = amenities.map((a) => a is Map ? a['name'] ?? '' : a.toString()).where((s) => s.isNotEmpty).join(', ');
        } else {
          amenityStr = amenities.toString();
        }
        _addIfNotEmpty(items, 'Amenities', amenityStr);
      }
    } else if (cat.contains('fashion')) {
      _addIfNotEmpty(items, 'Category', attrs['fashionType']);
      _addIfNotEmpty(items, 'Brand', attrs['brand']);
      _addIfNotEmpty(items, 'Size', attrs['size']);
      _addIfNotEmpty(items, 'Color', attrs['color']);
      _addIfNotEmpty(items, 'Material', attrs['material']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else if (cat.contains('automobile') || cat.contains('car') || cat.contains('bike') || cat.contains('vehicle')) {
      _addIfNotEmpty(items, 'Vehicle Type', attrs['vehicleType']);
      _addIfNotEmpty(items, 'Brand', attrs['brand']);
      _addIfNotEmpty(items, 'Model', attrs['model']);
      _addIfNotEmpty(items, 'Year', attrs['year']);
      _addIfNotEmpty(items, 'KM Driven', attrs['kmDriven']);
      _addIfNotEmpty(items, 'Owners', attrs['owners']);
      _addIfNotEmpty(items, 'Mileage', attrs['mileage']);
      _addIfNotEmpty(items, 'Fuel Type', attrs['fuelType']);
      _addIfNotEmpty(items, 'Transmission', attrs['transmission']);
      _addIfNotEmpty(items, 'Insurance', attrs['insurance']);
      _addIfNotEmpty(items, 'Warranty', attrs['warranty']);
      _addIfNotEmpty(items, 'Body Type', attrs['bodyType']);
      _addIfNotEmpty(items, 'Exterior Color', attrs['exteriorColor']);
      _addIfNotEmpty(items, 'Interior Color', attrs['interiorColor']);
      _addIfNotEmpty(items, 'Horsepower', attrs['horsepower']);
      _addIfNotEmpty(items, 'Engine Capacity', attrs['engineCapacity']);
      _addIfNotEmpty(items, 'Seater Capacity', attrs['seaterCapacity']);
      _addIfNotEmpty(items, 'Doors', attrs['doors']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else if (cat.contains('furniture')) {
      _addIfNotEmpty(items, 'Type', attrs['furnitureType']);
      _addIfNotEmpty(items, 'Material', attrs['material']);
      _addIfNotEmpty(items, 'Color', attrs['color']);
      _addIfNotEmpty(items, 'Dimensions', attrs['dimensions']);
      _addIfNotEmpty(items, 'Age', attrs['age']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else if (cat.contains('mobile') || cat.contains('tablet') || cat.contains('phone')) {
      _addIfNotEmpty(items, 'Type', attrs['mobileType']);
      _addIfNotEmpty(items, 'Brand', attrs['brand']);
      _addIfNotEmpty(items, 'Model', attrs['model']);
      _addIfNotEmpty(items, 'Storage', attrs['storage']);
      _addIfNotEmpty(items, 'RAM', attrs['ram']);
      _addIfNotEmpty(items, 'Battery Health', attrs['battery']);
      _addIfNotEmpty(items, 'OS Version', attrs['version']);
      _addIfNotEmpty(items, 'Physical Damage', attrs['damage']);
      _addIfNotEmpty(items, 'Age', attrs['age']);
      _addIfNotEmpty(items, 'Color', attrs['colour'] ?? attrs['color']);
      _addIfNotEmpty(items, 'Warranty', attrs['warranty']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else if (cat.contains('electronic') || cat.contains('gadget') || cat.contains('laptop') || cat.contains('camera')) {
      _addIfNotEmpty(items, 'Gadget Type', attrs['gadgetType']);
      _addIfNotEmpty(items, 'Brand', attrs['brand']);
      _addIfNotEmpty(items, 'Model', attrs['model']);
      _addIfNotEmpty(items, 'Warranty', attrs['warranty']);
      _addIfNotEmpty(items, 'Age', attrs['age']);
      _addIfNotEmpty(items, 'Color', attrs['color']);
      _addIfNotEmpty(items, 'Battery Life', attrs['batteryLife']);
      _addIfNotEmpty(items, 'Connectivity', attrs['connectivity']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    } else {
      // Generic fallback
      _addIfNotEmpty(items, 'Brand', attrs['brand']);
      _addIfNotEmpty(items, 'Model', attrs['model']);
      _addIfNotEmpty(items, 'Warranty', attrs['warranty']);
      _addIfNotEmpty(items, 'Color', attrs['color']);
      _addIfNotEmpty(items, 'Phone', attrs['phone']);
    }

    // If no category-specific fields found, show all non-excluded fields as fallback
    if (items.length <= 1) {
      for (final e in attrs.entries) {
        if (!alwaysExclude.contains(e.key) && e.value.toString().isNotEmpty) {
          items.add({'label': _formatKey(e.key), 'value': e.value.toString()});
        }
      }
    }

    // Build widget pairs (2 columns per row)
    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      if (i > 0) rows.add(const Divider(height: 20, thickness: 0.5));
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildSpecItem(items[i]['label']!, items[i]['value']!)),
          if (i + 1 < items.length) ...[
            Container(width: 1, height: 40, color: Colors.grey[300]),
            Expanded(child: _buildSpecItem(items[i+1]['label']!, items[i+1]['value']!)),
          ] else
            const Expanded(child: SizedBox.shrink()),
        ],
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  void _addIfNotEmpty(List<Map<String, String>> items, String label, dynamic value) {
    if (value == null) return;
    final str = value.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'false') return;
    items.add({'label': label, 'value': str});
  }

  String _formatKey(String key) {
    String result = key.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');
    result = result.replaceAll('_', ' ').trim();
    return result[0].toUpperCase() + result.substring(1);
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
