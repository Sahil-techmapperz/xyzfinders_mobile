import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import 'automobile_detail_screen.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';
import '../../../widgets/category_search_header.dart';

class AutomobileListScreen extends StatefulWidget {
  const AutomobileListScreen({super.key});

  @override
  State<AutomobileListScreen> createState() => _AutomobileListScreenState();
}

class _AutomobileListScreenState extends State<AutomobileListScreen> {
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
              hintText: "Search in Automobiles...",
              onBack: () => Navigator.pop(context),
            ),
            _buildFilterBar(),
            _buildResultsSummary(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Extra padding for bottom nav
                itemCount: _getMockCars().length,
                itemBuilder: (context, index) {
                  return _buildProductCard(context, _getMockCars()[index]);
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
          _buildFilterChip(null, "Price", hasDropdown: true),
          _buildFilterChip(null, "Year", hasDropdown: true),
          _buildFilterChip(null, "Kilometers", hasDropdown: true),
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          "Showing Results - 14,256".text.italic.gray600.size(12).make(),
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

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  car['image'],
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50).centered(),
                  ),
                ),
              ),
              // Verified Tag
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 10),
                      const SizedBox(width: 4),
                      "VERIFIED SELLER".text.white.bold.size(8).make(),
                    ],
                  ),
                ),
              ),
              // Favorite Icon
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                ),
              ),
              // Image Counter
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.image_outlined, color: Colors.white, size: 10),
                      const SizedBox(width: 4),
                      "1/10".text.white.size(9).make(),
                    ],
                  ),
                ),
              ),
              // DOTS indicator
              Positioned(
                bottom: 15,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 6,
                    width: 6,
                    decoration: BoxDecoration(
                      color: i == 0 ? Colors.white : Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  )),
                ),
              ),
            ],
          ),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    "₹ ${car['price']}".text.xl2.bold.color(AppTheme.secondaryColor).make(),
                    "/Monthly".text.gray700.semiBold.size(14).make(),
                  ],
                ),
                const SizedBox(height: 12),
                "Car  •  ${car['brand'] ?? 'Volvo'}  •  ${car['model'] ?? 'XL330'}".text.gray600.medium.size(13).make(),
                const SizedBox(height: 4),
                (car['title'] as String).text.semiBold.xl.black.make(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          "Year: ".text.gray500.size(13).make(),
                          "${car['year']}".text.gray700.bold.size(13).maxLines(1).ellipsis.make().expand(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          "Mileage: ".text.gray500.size(13).make(),
                          "${car['mileage']}".text.gray700.bold.size(13).maxLines(1).ellipsis.make().expand(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: (car['location'] as String).text.gray500.size(12).maxLines(2).ellipsis.make(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.call, color: Color(0xFFD81B60), size: 18),
                              const SizedBox(width: 8),
                              "Call".text.color(const Color(0xFFD81B60)).semiBold.make(),
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
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble, color: Color(0xFF1E88E5), size: 18),
                              const SizedBox(width: 8),
                              "Chat".text.color(const Color(0xFF1E88E5)).semiBold.make(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).onTap(() {
       Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AutomobileDetailScreen()),
        );
    });
  }

  List<Map<String, dynamic>> _getMockCars() {
    return [
      {
        'title': 'Volvo XC90 T6 Inscription Highline',
        'brand': 'Volvo',
        'model': 'XL330',
        'price': '11,000',
        'location': 'Kundeshwari Road, Kashipur, Udham Singh Nagar, Utta...',
        'image': 'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=800&q=80',
        'mileage': '54,000 kms',
        'year': '2016',
      },
      {
        'title': 'BMW M5 Competition 2023',
        'brand': 'BMW',
        'model': 'M5',
        'price': '45,000',
        'location': 'Dwarka, New Delhi, India',
        'image': 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=800&q=80',
        'mileage': '8,500 kms',
        'year': '2023',
      },
      {
        'title': 'Audi RS E-Tron GT 2024',
        'brand': 'Audi',
        'model': 'RS',
        'price': '65,000',
        'location': 'Worli, Mumbai, Maharashtra',
        'image': 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=800&q=80',
        'mileage': '1,200 kms',
        'year': '2024',
      },
      {
        'title': 'Mercedes-Benz G-Wagon G63',
        'brand': 'Mercedes',
        'model': 'G-Class',
        'price': '2,55,00,000',
        'location': 'Banjara Hills, Hyderabad',
        'image': 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?auto=format&fit=crop&w=800&q=80',
        'mileage': '6,200 kms',
        'year': '2022',
      },
    ];
  }
}
