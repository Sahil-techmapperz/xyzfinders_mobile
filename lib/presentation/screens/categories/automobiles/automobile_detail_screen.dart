import '../../../widgets/share_button.dart';
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
import '../../../../data/models/product_model.dart';
import '../../../widgets/favorite_toggle_button.dart';
import '../../../providers/auth_provider.dart';
import 'package:xyzfinders_mobile/presentation/providers/notification_provider.dart';
import '../../notifications/notification_screen.dart';

class AutomobileDetailScreen extends StatefulWidget {
  final int productId;
  final String? title;

  const AutomobileDetailScreen({
    super.key,
    required this.productId,
    this.title,
  });

  @override
  State<AutomobileDetailScreen> createState() => _AutomobileDetailScreenState();
}

class _AutomobileDetailScreenState extends State<AutomobileDetailScreen> {
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
        child: const Icon(Icons.image, color: Colors.grey),
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
            appBar: AppBar(title: Text(widget.title ?? "Detail")),
            body: Center(child: (provider.error ?? "Product not found").text.make()),
          );
        }

        final attrs = product.productAttributes ?? {};
        
        // Try to get specs Map, if not found use attrs themselves as specs
        final specs = attrs['specs'] is Map 
            ? Map<String, dynamic>.from(attrs['specs']) 
            : Map<String, dynamic>.from(attrs);
        
        // Automobile specific meta info with robust key checking
        final year = specs['year']?.toString() ?? attrs['year']?.toString() ?? "N/A";
        final mileage = specs['km_driven']?.toString() ?? 
                       specs['kmDriven']?.toString() ?? 
                       specs['mileage']?.toString() ?? 
                       attrs['km_driven']?.toString() ?? 
                       attrs['mileage']?.toString() ?? "N/A";

        final List<Map<String, String>> specsList = [];
        
        // Helper to add if present
        void addSpec(String label, List<String> keys) {
          for (var key in keys) {
            final val = specs[key] ?? attrs[key];
            if (val != null && val.toString().isNotEmpty) {
              specsList.add({"label": label, "value": val.toString()});
              return;
            }
          }
          specsList.add({"label": label, "value": "N/A"});
        }

        addSpec("Brand", ["brand", "make", "company"]);
        addSpec("Model", ["model"]);
        addSpec("Fuel Type", ["fuel_type", "fuelType", "fuel"]);
        addSpec("Transmission", ["transmission"]);
        
        // Add other dynamic specs that aren't already included
        specs.forEach((key, value) {
          if (!['year', 'mileage', 'km_driven', 'kmDriven', 'brand', 'make', 'model', 'fuel_type', 'fuelType', 'fuel', 'transmission', 'specs', 'location', 'city', 'state', 'address'].contains(key.toLowerCase())) {
            if (value != null && value.toString().isNotEmpty && value is! Map && value is! List) {
              specsList.add({"label": key.replaceAll('_', ' ').capitalizeFirstLetter(), "value": value.toString()});
            }
          }
        });

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
                          _buildMetaInfoLine(year, mileage),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              "${product.locationName ?? product.cityName ?? 'N/A'}, ${product.stateName ?? ''}".text.gray500.size(12).ellipsis.make().expand(),
                            ],
                          ),
                          const Divider(height: 32),
                          (attrs['highlights']?.toString() ?? "Certified Dealer | Service Warranty | Fully Inspected").text.bold.size(13).make(),
                          const SizedBox(height: 20),
                          "Specification".text.bold.size(15).make(),
                          const SizedBox(height: 16),
                          _buildSpecsTable(specsList),
                          const Divider(height: 32),
                          "Description".text.bold.size(15).make(),
                          const SizedBox(height: 12),
                          (product.description.isNotEmpty ? product.description : (attrs['description']?.toString() ?? "No description provided.")).text.gray600.size(13).lineHeight(1.5).make(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              "Posted on : ${product.createdAt.split('T')[0]}".text.gray500.size(13).make(),
                               if (context.read<AuthProvider>().isAuthenticated && context.read<AuthProvider>().user?.id != product.userId)
                                TextButton.icon(
                                  onPressed: () => _showReportModal(product),
                                  icon: const Icon(Icons.report_problem_outlined, size: 16, color: Colors.red),
                                  label: "Report".text.red600.size(13).semiBold.make(),
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                ),
                            ],
                          ),
                          const Divider(height: 48),
                          "Amenities / Features".text.bold.size(15).make(),
                          const SizedBox(height: 16),
                          _buildAmenities(attrs['amenities'] ?? attrs['features'] ?? attrs['product_features'] ?? attrs['highlights']),
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
              Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 50))
            else
              PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) => setState(() => _activeImageIndex = index),
                itemBuilder: (context, index) => _buildProductImage(images[index]),
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
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.black87, size: 22),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: ShareButton(product: product, iconSize: 22),
          ),
          const SizedBox(width: 10),
          FavoriteToggleButton(product: product),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
        ),
      ),
    );
  }

  Widget _buildPriceSection(ProductModel product) {
    return Row(
      children: [
        CurrencyUtils.formatIndianCurrency(product.price).text.xl3.bold.color(AppTheme.secondaryColor).make(),
        "/-".text.xl2.bold.color(AppTheme.secondaryColor).make(),
      ],
    );
  }

  Widget _buildMetaInfoLine(String year, String mileage) {
    return Row(
      children: [
        _buildMetaItem(Icons.calendar_month_outlined, year),
        const SizedBox(width: 24),
        _buildMetaItem(Icons.speed_outlined, "${mileage} Km"),
      ],
    );
  }

  Widget _buildMetaItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 6),
        label.text.gray700.size(14).bold.make(),
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
            const SizedBox(width: 16),
            spec['value']!.text.bold.size(14).align(TextAlign.right).make().expand(),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildAmenities(dynamic amenitiesData) {
    final List<Map<String, dynamic>> allAmenities = [];
    
    if (amenitiesData is String && amenitiesData.isNotEmpty) {
      if (amenitiesData.contains(',')) {
        for (var item in amenitiesData.split(',')) {
          if (item.trim().isNotEmpty) {
            allAmenities.add({"icon": Icons.check_circle_outline, "label": item.trim().capitalizeFirstLetter()});
          }
        }
      } else if (amenitiesData.contains('|')) {
        for (var item in amenitiesData.split('|')) {
          if (item.trim().isNotEmpty) {
            allAmenities.add({"icon": Icons.check_circle_outline, "label": item.trim().capitalizeFirstLetter()});
          }
        }
      } else {
        allAmenities.add({"icon": Icons.check_circle_outline, "label": amenitiesData.capitalizeFirstLetter()});
      }
    } else if (amenitiesData is List) {
      for (var item in amenitiesData) {
         allAmenities.add({"icon": Icons.check_circle_outline, "label": item.toString().capitalizeFirstLetter()});
      }
    } else if (amenitiesData is Map) {
      amenitiesData.forEach((key, value) {
        if (value == true || value == 1 || value.toString().toLowerCase() == 'yes') {
          allAmenities.add({"icon": Icons.check_circle_outline, "label": key.replaceAll('_', ' ').capitalizeFirstLetter()});
        }
      });
    }

    if (allAmenities.isEmpty) {
      return "Safety standard features and accessories included.".text.gray500.size(13).make();
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
                "Features & Options".text.xl.bold.make(),
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
        "Map View".text.bold.size(15).make(),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(29.2104, 78.9619),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("automobile_location"),
                  position: const LatLng(29.2104, 78.9619),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
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
            (product.sellerName ?? "Dealer").text.bold.size(18).make(),
            if (product.sellerIsVerified) ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: Colors.blue, size: 22),
            ]
          ],
        ),
        "Certified Dealer".text.gray500.size(14).make(),
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
            child: InkWell(
              onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatData: {
                                  'rawId': null,
                                  'otherUserId': product.userId?.toString() ?? '',
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
                    const Icon(Icons.chat_bubble, color: Color(0xFF1E88E5), size: 24),
                    const SizedBox(width: 10),
                    "Chat".text.color(const Color(0xFF1E88E5)).xl.bold.make(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportModal(ProductModel product) {
    String selectedReason = 'Spam';
    final List<String> reasons = ['Spam', 'Fraud', 'Inappropriate', 'Misleading', 'Counterfeit Product', 'Duplicate', 'Other'];
    final TextEditingController descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "Report this Ad".text.xl.bold.make(),
              const SizedBox(height: 16),
              "Why are you reporting this?".text.gray600.make(),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedReason,
                    isExpanded: true,
                    items: reasons.map((r) => DropdownMenuItem(
                      value: r,
                      child: r.text.make(),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedReason = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              "Additional Details (Optional)".text.gray600.make(),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Describe the issue...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final apiService = context.read<ProductProvider>().apiService;
                      final response = await apiService.post('/reports', data: {
                        'product_id': product.id,
                        'reason': selectedReason.toLowerCase(),
                        'description': descriptionController.text,
                      });
                      
                      Navigator.pop(context);
                      VxToast.show(context, msg: response.data['message'] ?? "Report submitted successfully");
                    } catch (e) {
                      VxToast.show(context, msg: "Failed to submit report. Please try again.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: "Submit Report".text.white.bold.make(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
