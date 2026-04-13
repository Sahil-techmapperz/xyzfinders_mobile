import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';

class MobilesDetailScreen extends StatefulWidget {
  final int productId;
  final String? title;

  const MobilesDetailScreen({
    super.key,
    required this.productId,
    this.title,
  });

  @override
  State<MobilesDetailScreen> createState() => _MobilesDetailScreenState();
}

class _MobilesDetailScreenState extends State<MobilesDetailScreen> {
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
                      "iPhone 15 Pro Max - 256GB - Blue Titanium".text.xl.bold.make(),
                      const SizedBox(height: 16),
                      _buildMetaInfoLine(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          "Salt Lake, Kolkata, West Bengal..".text.gray500.size(12).ellipsis.make().expand(),
                        ],
                      ),
                      const Divider(height: 32),
                      "Specification".text.bold.size(15).make(),
                      const SizedBox(height: 16),
                      _buildSpecsTable(),
                      const Divider(height: 40),
                      "Description".text.bold.size(15).make(),
                      const SizedBox(height: 12),
                      "Selling my iPhone 15 Pro Max, 256GB variant in Blue Titanium. The phone is in pristine condition, like new, with no scratches or dents. Comes with original box and all accessories. Battery health is 100%."
                          .text.gray600.size(13).lineHeight(1.5).maxLines(4).ellipsis.make(),
                      const SizedBox(height: 8),
                      "Read More".text.orange500.bold.make(),
                      const SizedBox(height: 16),
                      "Posted on : 15-Mar-2024".text.gray500.size(13).make(),
                      const Divider(height: 48),
                      "Features".text.bold.size(15).make(),
                      const SizedBox(height: 16),
                      _buildFeatureList(),
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
              "https://images.unsplash.com/photo-1696446701796-da61225697cc?auto=format&fit=crop&w=800&q=80",
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
                    "1/5".text.white.size(8).bold.make(),
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
                  5,
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
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        "₹ 1,15,000".text.xl3.bold.color(AppTheme.secondaryColor).make(),
        const Icon(Icons.share_outlined, color: Colors.grey),
      ],
    );
  }

  Widget _buildMetaInfoLine() {
    return Row(
      children: [
        _buildMetaItem(Icons.history_rounded, "Like New"),
        _buildMetaDivider(),
        _buildMetaItem(Icons.inventory_2_outlined, "Retail Box"),
        _buildMetaDivider(),
        _buildMetaItem(Icons.verified_user_outlined, "Warranty"),
      ],
    );
  }

  Widget _buildMetaItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        label.text.gray600.size(11).make(),
      ],
    );
  }

  Widget _buildMetaDivider() {
    return Container(
      height: 12,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _buildSpecsTable() {
    final specs = [
      {"label": "Brand", "value": "Apple"},
      {"label": "Model", "value": "iPhone 15 Pro Max"},
      {"label": "Storage", "value": "256 GB"},
      {"label": "RAM", "value": "8 GB"},
      {"label": "Screen Size", "value": "6.7 inches"},
      {"label": "Battery", "value": "4441 mAh"},
      {"label": "Processor", "value": "A17 Pro"},
    ];

    return Column(
      children: specs.map((spec) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildFeatureList() {
    final features = ["Face ID", "Dynamic Island", "Action Button", "ProMotion", "Night Mode", "OLED Display"];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: features.map((f) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: f.text.orange800.size(12).semiBold.make(),
      )).toList(),
    );
  }

  Widget _buildMapView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "Location Map".text.bold.size(15).make(),
        const SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(22.5726, 88.3639), zoom: 14),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/45.jpg")),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "Rahul Sharma".text.bold.size(16).make(),
              "Verified individual".text.gray500.size(12).make(),
            ],
          ).expand(),
          const Icon(Icons.verified, color: Colors.blue, size: 20),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Container(
                height: 50,
                decoration: BoxDecoration(color: const Color(0xFFFFE8F0), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call, color: Color(0xFFD81B60), size: 20),
                    const SizedBox(width: 8),
                    "Call Seller".text.color(const Color(0xFFD81B60)).bold.make(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Container(
                height: 50,
                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble, color: Color(0xFF1E88E5), size: 20),
                    const SizedBox(width: 8),
                    "Chat Now".text.color(const Color(0xFF1E88E5)).bold.make(),
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
