import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RealEstateDetailScreen extends StatefulWidget {
  final int productId;
  final String? title;

  const RealEstateDetailScreen({
    super.key,
    required this.productId,
    this.title,
  });

  @override
  State<RealEstateDetailScreen> createState() => _RealEstateDetailScreenState();
}

class _RealEstateDetailScreenState extends State<RealEstateDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildImageHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPriceSection(),
                      const SizedBox(height: 12),
                      (widget.title ?? "Premium 4BHK Apartment for Rent").text.xl.bold.make(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          "Kundeshwari Rd, Kundeshwari, Kashipur, Uttarakhand..".text.gray500.size(12).ellipsis.make().expand(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildBasicSpecs(),
                      const Divider(height: 32),
                      "Brand New | Ready to Move | Master Room".text.bold.size(13).make(),
                      const SizedBox(height: 20),
                      "Specification".text.bold.size(15).make(),
                      const SizedBox(height: 16),
                      _buildSpecsTable(),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: "See More Details".text.orange500.semiBold.make(),
                        ),
                      ),
                      const Divider(height: 40),
                      "Description".text.bold.size(15).make(),
                      const SizedBox(height: 8),
                      "This premium 4BHK apartment offers a perfect blend of luxury and comfort. Located in the heart of Kashipur, it features spacious rooms, modern amenities, and a state-of-the-art kitchen. Perfect for families looking for a ready-to-move-in home."
                          .text.gray600.size(13).lineHeight(1.5).maxLines(3).ellipsis.make(),
                      const SizedBox(height: 12),
                      "Read More".text.orange500.bold.make(),
                      const SizedBox(height: 16),
                      "Posted on : 13-Jan-2026".text.gray500.size(13).make(),
                      const Divider(height: 48),
                      "Amenities".text.bold.size(15).make(),
                      const SizedBox(height: 16),
                      _buildAmenities(),
                      const SizedBox(height: 32),
                      _buildMapView(),
                      const SizedBox(height: 32),
                      _buildSellerCard(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBackButton(),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomBar(),
    );
  }

  Widget _buildImageHeader() {
    return SliverAppBar(
      expandedHeight: 350,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80",
              fit: BoxFit.cover,
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
                    "1/10".text.white.size(8).bold.make(),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == 0 ? Colors.white : Colors.white.withOpacity(0.5),
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

  Widget _buildPriceSection() {
    return Row(
      children: [
        "₹ 24,000".text.xl2.bold.red600.make(),
        "/Monthly".text.gray500.size(15).make(),
      ],
    );
  }

  Widget _buildBasicSpecs() {
    return Row(
      children: [
        _buildSpecItem(Icons.king_bed_outlined, "4 Bedrooms"),
        const SizedBox(width: 20),
        _buildSpecItem(Icons.kitchen_outlined, "1 Kitchen"),
        const SizedBox(width: 20),
        _buildSpecItem(Icons.bathtub_outlined, "3 Baths"),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.grey),
        const SizedBox(width: 6),
        label.text.gray600.size(13).make(),
      ],
    );
  }

  Widget _buildSpecsTable() {
    final specs = [
      {"label": "Type -", "value": "Apartment"},
      {"label": "Security Deposit -", "value": "25,000"},
      {"label": "Balcony -", "value": "Yes"},
      {"label": "Purpose -", "value": "Rent"},
      {"label": "Property Age -", "value": "Private Room"},
      {"label": "Furnishing -", "value": "Un-Furnished"},
      {"label": "Updated -", "value": "25-December-2025"},
    ];

    return Column(
      children: specs.map((spec) => Padding(
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

  Widget _buildStickyBottomBar() {
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
              onTap: () {},
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call, color: Color(0xFFD81B60), size: 24),
                    const SizedBox(width: 10),
                    "Call".text.color(const Color(0xFFD81B60)).xl.bold.make(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: InkWell(
              onTap: () {},
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

  Widget _buildAmenities() {
    final List<Map<String, dynamic>> allAmenities = [
      {"icon": Icons.wifi, "label": "Free Wifi"},
      {"icon": Icons.build_outlined, "label": "Free Maintenance"},
      {"icon": Icons.domain, "label": "Balcony"},
      {"icon": Icons.security, "label": "Security"},
      {"icon": Icons.pool, "label": "Pool"},
      {"icon": Icons.fitness_center, "label": "Gym"},
      {"icon": Icons.park, "label": "Garden"},
      {"icon": Icons.garage, "label": "Parking"},
    ];

    final displayItems = allAmenities.take(3).toList();
    final remainingCount = allAmenities.length - 3;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...displayItems.map((item) => _buildAmenityCircle(item)),
          if (remainingCount > 0) _buildMoreCircle(remainingCount, allAmenities),
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
                "All Amenities".text.xl.bold.make(),
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

  Widget _buildMapView() {
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
                  markerId: const MarkerId("property_location"),
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
        "Kundeshwari Rd, Kundeshwari, Kashipur, Uttarakhand 244713, India".text.gray600.size(12).make(),
      ],
    );
  }

  Widget _buildSellerCard() {
    return Column(
      children: [
        const Center(
          child: CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/32.jpg"),
          ),
        ),
        const SizedBox(height: 12),
        "Manish Kumar shri sidheshawar Mahto".text.bold.size(16).center.make(),
        "Dealer".text.gray500.size(14).make(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Member Since from December 2025".text.gray600.size(12).make(),
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ),
      ],
    );
  }
}
