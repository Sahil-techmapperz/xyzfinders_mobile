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
import '../../../../core/constants/api_constants.dart';
import '../../../providers/product_provider.dart';
import '../../../../data/models/product_model.dart';
import '../../../widgets/favorite_toggle_button.dart';

class ElectronicsDetailScreen extends StatefulWidget {
  final int productId;
  final String? title;

  const ElectronicsDetailScreen({
    super.key,
    required this.productId,
    this.title,
  });

  @override
  State<ElectronicsDetailScreen> createState() => _ElectronicsDetailScreenState();
}

class _ElectronicsDetailScreenState extends State<ElectronicsDetailScreen> {
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProductDetail(widget.productId);
    });
  }

  Widget _buildProductImage(String? imageVal, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    if (imageVal == null || imageVal.isEmpty) {
      return Container(
        height: height,
        width: width,
        color: Colors.grey.shade200,
        child: const Icon(Icons.devices, color: Colors.grey),
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
            appBar: AppBar(title: Text(widget.title ?? "Electronics Detail")),
            body: Center(child: (provider.error ?? "Electronic item not found").text.make()),
          );
        }

        final attrs = product.productAttributes ?? {};
        final specs = attrs['specs'] as Map<String, dynamic>? ?? {};
        
        final List<Map<String, String>> specsList = [];
        specs.forEach((key, value) {
          specsList.add({"label": key.replaceAll('_', ' ').capitalizeFirstLetter(), "value": value.toString()});
        });

        if (specsList.isEmpty) {
          specsList.add({"label": "Brand", "value": specs['brand'] ?? "Generic"});
          specsList.add({"label": "Model", "value": specs['model'] ?? "N/A"});
          specsList.add({"label": "Warranty", "value": specs['warranty'] ?? "No Warranty"});
          specsList.add({"label": "Condition", "value": product.condition.capitalizeFirstLetter()});
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
                          (attrs['highlights']?.toString() ?? "Latest Technology | Energy Efficient | Durable Build").text.bold.size(13).make(),
                          const SizedBox(height: 20),
                          "Specification".text.bold.size(15).make(),
                          const SizedBox(height: 16),
                          _buildSpecsTable(specsList),
                          const Divider(height: 40),
                          "Description".text.bold.size(15).make(),
                          const SizedBox(height: 8),
                          product.description.text.gray600.size(13).lineHeight(1.5).make(),
                          const SizedBox(height: 16),
                          "Posted on : ${product.createdAt.split('T')[0]}".text.gray500.size(13).make(),
                          const Divider(height: 48),
                          "Features & Options".text.bold.size(15).make(),
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
              _buildFavoriteButton(product),
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
              Container(color: Colors.grey.shade200, child: const Icon(Icons.devices, size: 50))
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

  Widget _buildFavoriteButton(ProductModel product) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 16,
      child: FavoriteToggleButton(product: product),
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
    return Row(
      children: [
        "₹ ${NumberFormat('#,##,###').format(product.price)}".text.xl3.bold.red600.make(),
        "/-".text.xl2.bold.red600.make(),
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
          allAmenities.add({"icon": Icons.check_circle_outline, "label": key.replaceAll('_', ' ').capitalizeFirstLetter()});
        }
      });
    }

    if (allAmenities.isEmpty) {
      return "Certified electronic appliance features.".text.gray500.size(13).make();
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
        "Pick-up Location".text.bold.size(15).make(),
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
                  markerId: const MarkerId("electronics_location"),
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
        (product.sellerName ?? "Professional").text.bold.size(16).center.make(),
        "Verified Electronics Dealer".text.gray500.size(14).make(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Member Since ${product.sellerCreatedAt ?? 'Recently'}".text.gray600.size(12).make(),
            if (product.sellerIsVerified) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified, color: Colors.blue, size: 16),
            ]
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
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
