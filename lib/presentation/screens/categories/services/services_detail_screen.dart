import '../../../widgets/products/full_screen_image_viewer.dart';
import '../../../widgets/common/product_location_map.dart';
import '../../chats/chat_screen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../../data/models/product_model.dart';
import '../../../widgets/favorite_toggle_button.dart';
import '../../../providers/notification_provider.dart';
import '../../notifications/notification_screen.dart';
import '../../../widgets/share_button.dart';

class ServicesDetailScreen extends StatefulWidget {
  final int productId;
  final String? title;

  const ServicesDetailScreen({
    super.key,
    required this.productId,
    this.title,
  });

  @override
  State<ServicesDetailScreen> createState() => _ServicesDetailScreenState();
}

class _ServicesDetailScreenState extends State<ServicesDetailScreen> {
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProductDetail(widget.productId);
    });
  }

  Widget _buildProductImage(String? imageVal, {double? height, double? width, BoxFit fit = BoxFit.contain}) {
    if (imageVal == null || imageVal.isEmpty) {
      return Container(
        height: height,
        width: width,
        color: Colors.grey.shade200,
        child: const Icon(Icons.build, color: Colors.grey),
      );
    }

    if (imageVal.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageVal,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Container(color: Colors.grey.shade100),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }

    try {
      return Image.memory(
        base64Decode(imageVal),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    } catch (e) {
      return const Icon(Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.selectedProduct == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final product = provider.selectedProduct;
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title ?? "Service Detail")),
            body: Center(child: (provider.error ?? "Service not found").text.make()),
          );
        }

        final attrs = product.productAttributes ?? {};
        final Map<String, dynamic> specs = {};
        if (attrs.containsKey('specs') && attrs['specs'] is Map) {
          specs.addAll(attrs['specs'] as Map<String, dynamic>);
        } else if (attrs.containsKey('specifications') && attrs['specifications'] is Map) {
          specs.addAll(attrs['specifications'] as Map<String, dynamic>);
        } else {
          attrs.forEach((key, value) {
            if (!['specs', 'specifications', 'amenities', 'features', 'highlights', 'images', 'location'].contains(key) && value is! Map && value is! List) {
               specs[key] = value;
            }
          });
        }
        
        final List<Map<String, String>> specsList = [];
        const _phoneKeys = ['phone', 'mobile', 'seller_phone', 'number', 'contact', 'tel', 'telephone', 'whatsapp'];
        final _seenLabels = <String>{};
        specs.forEach((key, value) {
          final lowerKey = key.toLowerCase();
          if (value != null && value.toString().isNotEmpty && !_phoneKeys.any((p) => lowerKey.contains(p))) {
            final label = key.replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ').replaceAll('_', ' ').capitalizeFirstLetter();
            if (!_seenLabels.contains(label.toLowerCase())) {
              specsList.add({"label": label, "value": value.toString()});
              _seenLabels.add(label.toLowerCase());
            }
          }
        });

        if (specsList.isEmpty) {
          specsList.add({"label": "Product Type", "value": specs['type'] ?? attrs['type'] ?? specs['service_type'] ?? attrs['service_type'] ?? "Professional"});
          specsList.add({"label": "Experience", "value": specs['experience'] ?? attrs['experience'] ?? "Varies"});
          specsList.add({"label": "Availability", "value": specs['availability'] ?? attrs['availability'] ?? "Full-time"});
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildImageHeader(product),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPriceSection(product),
                          const SizedBox(height: 12),
                          product.title.text.xl.bold.make(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              "${product.locationName ?? product.cityName ?? 'N/A'}, ${product.stateName ?? ''}".text.gray500.size(12).ellipsis.make().expand(),
                            ],
                          ),
                          const Divider(height: 32),
                          (attrs['highlights']?.toString() ?? "Trusted Experts | Quality Service | Customer Satisfaction").text.bold.size(13).make(),
                          const SizedBox(height: 20),
                          "Service Highlights".text.bold.size(15).make(),
                          const SizedBox(height: 16),
                          _buildSpecsTable(specsList),
                          const Divider(height: 40),
                          "About Service".text.bold.size(15).make(),
                          const SizedBox(height: 8),
                          product.description.text.gray600.size(13).lineHeight(1.5).make(),
                          const SizedBox(height: 16),
                          "Posted on : ${product.createdAt.split('T')[0]}".text.gray500.size(13).make(),
                          const Divider(height: 48),
                          "Service Features".text.bold.size(15).make(),
                          const SizedBox(height: 16),
                          _buildAmenities(attrs['amenities'] ?? attrs['features']),
                          const SizedBox(height: 32),
                          _buildMapView(product),
                          const SizedBox(height: 32),
                          _buildSellerCard(product),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildBackButton(),
              _buildActionButtons(product),
            ],
          ),
          bottomNavigationBar: _buildStickyBottomBar(product),
        );
      },
    );
  }

  Widget _buildImageHeader(ProductModel product) {
    final images = product.allImageUrls;
    return SliverAppBar(
      expandedHeight: 350,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (images.isEmpty)
              Container(color: Colors.grey.shade100, child: const Icon(Icons.room_service, size: 50, color: Colors.grey))
            else
              PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) => setState(() => _activeImageIndex = index),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          imageUrls: images,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: _buildProductImage(images[index]),
                ),
              ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined, color: Colors.white, size: 10),
                    const SizedBox(width: 4),
                    "${_activeImageIndex + 1}/${images.length > 0 ? images.length : 1}".text.white.size(8).bold.make(),
                  ],
                ),
              ),
            ),
            if (images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _activeImageIndex ? Colors.white : Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ProductModel product) {
    const double _iconSize = 22;
    const EdgeInsets _btnPadding = EdgeInsets.all(8);
    const BoxDecoration _btnDecoration = BoxDecoration(color: Colors.white, shape: BoxShape.circle);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 16,
      child: Row(
        children: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    ),
                    child: Container(
                      padding: _btnPadding,
                      decoration: _btnDecoration,
                      child: const Icon(Icons.notifications_none, color: Colors.black87, size: _iconSize),
                    ),
                  ),
                  if (provider.unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                        child: (provider.unreadCount > 9 ? "9+" : provider.unreadCount.toString())
                            .text.white.size(7).bold.make().centered(),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 10),
          Container(
            padding: _btnPadding,
            decoration: _btnDecoration,
            child: ShareButton(product: product, iconSize: _iconSize),
          ),
          const SizedBox(width: 10),
          FavoriteToggleButton(
            product: product,
            iconSize: _iconSize,
            padding: _btnPadding,
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              )
            ],
          ),
          child: const Icon(Icons.close, color: Colors.black, size: 20),
        ),
      ),
    );
  }

  Widget _buildPriceSection(ProductModel product) {
    if (product.price == 0) {
      return "Price on Request".text.xl2.bold.orange600.make();
    }
    return Row(
      children: [
        CurrencyUtils.formatIndianCurrency(product.price).text.xl3.bold.color(AppTheme.secondaryColor).make(),
        "/-".text.xl2.bold.color(AppTheme.secondaryColor).make(),
      ],
    );
  }

  Widget _buildSpecsTable(List<Map<String, String>> specsList) {
    return Column(
      children: specsList.map((spec) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            spec['label']!.text.gray500.size(14).make(),
            spec['value']!.text.bold.size(14).make(),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildAmenities(dynamic amenitiesData) {
    final List<Map<String, dynamic>> allAmenities = [];
    if (amenitiesData is List) {
      for (var item in amenitiesData) {
         allAmenities.add({"icon": Icons.check_circle_outline, "label": item.toString()});
      }
    } else if (amenitiesData is Map) {
      amenitiesData.forEach((key, value) {
        if (value == true || value == 1) {
          allAmenities.add({"icon": Icons.check_circle_outline, "label": key.replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ').replaceAll('_', ' ').capitalizeFirstLetter()});
        }
      });
    }

    if (allAmenities.isEmpty) {
      return "Professional service standards maintained.".text.gray500.size(13).make();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...allAmenities.take(3).map((item) => _buildAmenityCircle(item)).toList(),
          if (allAmenities.length > 3)
            _buildMoreCircle(allAmenities.length - 3, allAmenities),
        ],
      ),
    );
  }

  Widget _buildAmenityCircle(Map<String, dynamic> item) {
    return Container(
      height: 60,
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.0),
      ),
      child: Icon(item['icon'] as IconData, size: 28, color: Colors.black87).centered(),
    );
  }

  Widget _buildMoreCircle(int count, List<Map<String, dynamic>> allAmenities) {
    return InkWell(
      onTap: () => _showAllAmenitiesModal(allAmenities),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "+$count".text.bold.gray800.size(12).make(),
            "More".text.bold.gray800.size(10).make(),
          ],
        ),
      ),
    );
  }

  void _showAllAmenitiesModal(List<Map<String, dynamic>> allAmenities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "Service Features".text.xl.bold.make(),
                const CloseButton(),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: allAmenities.map((item) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.withOpacity(0.05),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Icon(item['icon'] as IconData, color: Colors.orange, size: 24),
                      ),
                      const SizedBox(height: 8),
                      (item['label'] as String).text.gray700.size(10).make(),
                    ],
                  ).box.width(70).make()).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "Service Area / Office".text.bold.size(15).make(),
        const SizedBox(height: 12),
        ProductLocationMap(
          locationName: product.locationName,
          cityName: product.cityName,
          stateName: product.stateName,
          postalCode: product.postalCode,
        ),
        const SizedBox(height: 12),
        "${product.locationName ?? product.cityName ?? 'Location N/A'}".text.gray600.size(12).make(),
      ],
    );
  }

  Widget _buildSellerCard(ProductModel product) {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 35,
            backgroundImage: product.sellerAvatar != null 
                ? (product.sellerAvatar!.startsWith('http') 
                    ? NetworkImage(product.sellerAvatar!) 
                    : MemoryImage(base64Decode(product.sellerAvatar!)) as ImageProvider)
                : const NetworkImage("https://randomuser.me/api/portraits/men/32.jpg"),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (product.sellerName ?? "Professional").text.bold.size(18).make(),
            if (product.sellerIsVerified) ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: Colors.blue, size: 22),
            ]
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Member Since ${product.sellerCreatedAt != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(product.sellerCreatedAt!)) : 'Recently'}".text.gray600.size(12).make(),
          ],
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(ProductModel product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatData: {
                        'rawId': null,
                        'otherUserId': product.userId.toString(),
                        'name': product.sellerName ?? 'Seller',
                        'productId': product.id,
                        'productTitle': product.title,
                        'productPrice': product.price,
                        'productImage': product.allImageUrls.isNotEmpty ? product.allImageUrls.first : null,
                        'avatarUrl': product.sellerAvatar,
                        'isAgencyChat': false,
                        'agencyIdResolved': null,
                      },
                    ),
                  ),
                );
              },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble, color: Color(0xFF1E88E5), size: 20),
                    const SizedBox(width: 8),
                    "Chat".text.color(const Color(0xFF1E88E5)).lg.bold.make(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () {
                _showBookingBottomSheet(context, product);
              },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B0FF), Color(0xFF0091EA)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B0FF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: "Book Now".text.white.lg.bold.make(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingBottomSheet(BuildContext context, ProductModel product) {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first to book this service.")),
      );
      return;
    }

    final nameController = TextEditingController(text: authProvider.user?.name ?? '');
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      "Book Service".text.xl2.bold.gray800.make(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  "Your Name".text.gray700.bold.size(14).make(),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00B0FF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "Preferred Date".text.gray700.bold.size(14).make(),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF00B0FF),
                                          onPrimary: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    (selectedDate == null 
                                        ? "Select Date" 
                                        : DateFormat('yyyy-MM-dd').format(selectedDate!))
                                        .text
                                        .color(selectedDate == null ? Colors.grey : Colors.black87)
                                        .make(),
                                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "Preferred Time".text.gray700.bold.size(14).make(),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF00B0FF),
                                          onPrimary: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedTime = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    (selectedTime == null 
                                        ? "Select Time" 
                                        : selectedTime!.format(context))
                                        .text
                                        .color(selectedTime == null ? Colors.grey : Colors.black87)
                                        .make(),
                                    const Icon(Icons.access_time_outlined, size: 18, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B0FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter your name")),
                          );
                          return;
                        }
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select preferred date")),
                          );
                          return;
                        }
                        if (selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select preferred time")),
                          );
                          return;
                        }

                        final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
                        final formattedTime = selectedTime!.format(context);
                        final message = "Hi my name is $name and I want to book this service (${product.title}) in this date: $formattedDate, time: $formattedTime. Is this slot available?";

                        final chatProvider = context.read<ChatProvider>();
                        
                        Navigator.pop(context);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(color: Color(0xFF00B0FF)),
                          ),
                        );

                        final success = await chatProvider.sendMessage(
                          productId: product.id,
                          receiverId: product.userId.toString(),
                          message: message,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                        }

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Booking request sent successfully!")),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatData: {
                                  'rawId': null,
                                  'otherUserId': product.userId.toString(),
                                  'name': product.sellerName ?? 'Seller',
                                  'productId': product.id,
                                  'productTitle': product.title,
                                  'productPrice': product.price,
                                  'productImage': product.allImageUrls.isNotEmpty ? product.allImageUrls.first : null,
                                  'avatarUrl': product.sellerAvatar,
                                  'isAgencyChat': false,
                                  'agencyIdResolved': null,
                                },
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(chatProvider.error ?? "Failed to send booking request")),
                          );
                        }
                      },
                      child: "Send Booking Request".text.white.bold.make(),
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
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
