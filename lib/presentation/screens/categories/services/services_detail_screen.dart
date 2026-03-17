import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';

class ServicesDetailScreen extends StatefulWidget {
  final int serviceId;
  final String? title;

  const ServicesDetailScreen({
    super.key,
    required this.serviceId,
    this.title,
  });

  @override
  State<ServicesDetailScreen> createState() => _ServicesDetailScreenState();
}

class _ServicesDetailScreenState extends State<ServicesDetailScreen> {
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
                      (widget.title ?? "Professional Home Cleaning Service").text.xl.bold.make(),
                      const SizedBox(height: 16),
                      _buildMetaInfoLine(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          "Sector 1, Kashipur, Uttarakhand..".text.gray500.size(12).ellipsis.make().expand(),
                        ],
                      ),
                      const Divider(height: 32),
                      "Eco-friendly Chemicals | Trained Staff | Satisfaction Guaranteed".text.bold.size(13).make(),
                      const SizedBox(height: 20),
                      "Service Details".text.bold.size(15).make(),
                      const SizedBox(height: 16),
                      _buildOverviewTable(),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: "See More Details".text.orange500.semiBold.make(),
                        ),
                      ),
                      const Divider(height: 32),
                      "About the Service".text.bold.size(15).make(),
                      const SizedBox(height: 12),
                      "We provide top-notch home cleaning services using advanced equipment and safe cleaning agents. Our team is fully verified and experienced in handling all types of residential cleaning needs."
                          .text.gray600.size(13).lineHeight(1.5).maxLines(3).ellipsis.make(),
                      const SizedBox(height: 8),
                      "Read More".text.orange500.bold.make(),
                      const SizedBox(height: 16),
                      "Posted on : 14-Mar-2026".text.gray500.size(13).make(),
                      const Divider(height: 48),
                      "Service Benefits".text.bold.size(15).make(),
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
              "https://images.unsplash.com/photo-1581578731548-c64695cc6954?auto=format&fit=crop&w=800&q=80",
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
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    "4.8 (250 Reviews)".text.white.size(10).bold.make(),
                  ],
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
        "₹ 1,999".text.xl3.bold.color(AppTheme.secondaryColor).make(),
        "/- starting".text.xl2.bold.color(AppTheme.secondaryColor).make(),
      ],
    );
  }

  Widget _buildMetaInfoLine() {
    return Row(
      children: [
        _buildMetaItem(Icons.verified_outlined, "Verified Expert"),
        const SizedBox(width: 24),
        _buildMetaItem(Icons.history_outlined, "10+ Years Exp"),
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

  Widget _buildOverviewTable() {
    final specs = [
      {"label": "Duration", "value": "2-4 Hours"},
      {"label": "Warranty", "value": "7 Days"},
      {"label": "Staff Member", "value": "2 Professionals"},
      {"label": "Equipments", "value": "Company Provided"},
      {"label": "Availability", "value": "08:00 AM - 08:00 PM"},
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

  Widget _buildAmenities() {
    final List<Map<String, dynamic>> features = [
      {"icon": Icons.cleaning_services_outlined, "label": "Deep Cleaning"},
      {"icon": Icons.eco_outlined, "label": "Eco-Friendly"},
      {"icon": Icons.timer_outlined, "label": "Tunctual"},
      {"icon": Icons.shield_outlined, "label": "Insured"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: features.map((item) => Container(
          height: 60,
          width: 60,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3), width: 1.0),
          ),
          child: Icon(item['icon'] as IconData, size: 28, color: Colors.black87).centered(),
        )).toList(),
      ),
    );
  }

  Widget _buildMapView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "Store/Office Location".text.bold.size(15).make(),
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
            child: const GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(29.2104, 78.9619),
                zoom: 15,
              ),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 12),
        "Sector 1, Kashipur, Uttarakhand 244713, India".text.gray600.size(12).make(),
      ],
    );
  }

  Widget _buildSellerCard() {
    return Column(
      children: [
        const Center(
          child: CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/33.jpg"),
          ),
        ),
        const SizedBox(height: 12),
        "QuickClean Home Services".text.bold.size(16).center.make(),
        "Certified Service Provider".text.gray500.size(14).make(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Top Rated Choice".text.gray600.size(12).make(),
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ),
      ],
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
                    "Call Expert".text.color(const Color(0xFFD81B60)).xl.bold.make(),
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
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: "Book Service".text.white.xl.bold.make().centered(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
