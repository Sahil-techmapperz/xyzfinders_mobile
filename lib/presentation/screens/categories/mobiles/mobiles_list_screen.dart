import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../../core/theme/app_theme.dart';
import 'mobiles_detail_screen.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';
import '../../../widgets/category_search_header.dart';

class MobilesListScreen extends StatefulWidget {
  const MobilesListScreen({super.key});

  @override
  State<MobilesListScreen> createState() => _MobilesListScreenState();
}

class _MobilesListScreenState extends State<MobilesListScreen> {
  bool _isVerifiedOnly = false;
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            CategorySearchHeader(
              prefixIcon: Icons.search_rounded,
              hintText: "Search Mobiles & Tablets...",
              onBack: () => Navigator.pop(context),
            ),
            _buildFilterBar(),
            _buildResultsSummary(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _getMockMobiles().length,
                itemBuilder: (context, index) {
                  return _buildProductCard(context, _getMockMobiles()[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          if (index != 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
      ),
      floatingActionButton: CustomFab(onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(Icons.tune, "Filter", hasDropdown: false, isIconOnly: true),
          _buildFilterChip(null, "Brand", hasDropdown: true),
          _buildFilterChip(null, "Storage", hasDropdown: true),
          _buildFilterChip(null, "RAM", hasDropdown: true),
          _buildFilterChip(null, "Price", hasDropdown: true),
          const VerticalDivider(width: 20, indent: 8, endIndent: 8),
          "All Filters".text.semiBold.black.make().centered().px(8),
          "Reset".text.gray500.make().centered().px(8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData? icon, String label, {bool hasDropdown = false, bool isIconOnly = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 16, color: Colors.orange.shade700).box.padding(EdgeInsets.only(right: isIconOnly ? 0 : 4)).make(),
          if (!isIconOnly) label.text.size(12).semiBold.make(),
          if (hasDropdown) const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey).box.padding(const EdgeInsets.only(left: 4)).make(),
        ],
      ),
    );
  }

  Widget _buildResultsSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          "Showing Results - ${_getMockMobiles().length}".text.italic.gray600.size(12).make(),
          Row(
            children: [
              "Verified Only".text.semiBold.size(12).make(),
              const SizedBox(width: 8),
              SizedBox(
                height: 24,
                width: 40,
                child: Switch(
                  value: _isVerifiedOnly,
                  onChanged: (val) => setState(() => _isVerifiedOnly = val),
                  activeColor: AppTheme.secondaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> mobile) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MobilesDetailScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    mobile['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 10),
                        const SizedBox(width: 4),
                        "VERIFIED SELLER".text.white.size(8).bold.make(),
                      ],
                    ),
                  ),
                ),
                 Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
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
                        "1/5".text.white.size(8).bold.make(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      "₹ ${mobile['price']}".text.xl2.bold.color(AppTheme.secondaryColor).make(),
                      mobile['condition'].toString().text.gray500.size(12).semiBold.make(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  mobile['title'].toString().text.lg.bold.make(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSpec(Icons.memory_rounded, mobile['storage']),
                      _buildSpec(Icons.speed_rounded, mobile['ram']),
                      _buildSpec(Icons.phone_android_rounded, mobile['brand']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: mobile['location'].toString().text.gray500.size(11).ellipsis.make(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpec(IconData icon, String label) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Flexible(child: label.text.gray600.size(11).ellipsis.make()),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockMobiles() {
    return [
      {
        'title': 'iPhone 15 Pro Max - 256GB - Blue Titanium',
        'price': '1,15,000',
        'condition': 'Like New',
        'storage': '256 GB',
        'ram': '8 GB',
        'brand': 'Apple',
        'location': 'Salt Lake, Kolkata',
        'image': 'https://images.unsplash.com/photo-1696446701796-da61225697cc?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Samsung Galaxy S24 Ultra - 512GB - Gray',
        'price': '1,05,000',
        'condition': 'Brand New',
        'storage': '512 GB',
        'ram': '12 GB',
        'brand': 'Samsung',
        'location': 'Whitefield, Bangalore',
        'image': 'https://images.unsplash.com/photo-1707231494002-8636ba906757?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Google Pixel 8 Pro - 128GB - Bay Blue',
        'price': '75,000',
        'condition': 'Slightly Used',
        'storage': '128 GB',
        'ram': '12 GB',
        'brand': 'Google',
        'location': 'Indiranagar, Bangalore',
        'image': 'https://images.unsplash.com/photo-1621330396173-e41b1cafd17f?auto=format&fit=crop&w=800&q=80',
      },
    ];
  }
}
