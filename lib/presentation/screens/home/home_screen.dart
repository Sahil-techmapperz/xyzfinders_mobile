import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../categories/real_estate/real_estate_list_screen.dart';
import '../categories/automobiles/automobile_list_screen.dart';
import '../categories/beauty/beauty_list_screen.dart';
import '../categories/electronics/electronics_list_screen.dart';
import '../categories/fashion/fashion_list_screen.dart';
import '../categories/furniture/furniture_list_screen.dart';
import '../categories/local_events/local_events_list_screen.dart';
import '../categories/education/education_list_screen.dart';
import '../categories/pets/pets_accessories_list_screen.dart';
import '../categories/services/services_list_screen.dart';
import '../categories/mobiles/mobiles_list_screen.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const HomeTab(),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: CustomFab(onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 1. Header with Logo and Location
        SliverToBoxAdapter(child: _buildHeader(context)),

        // 2. Search Section
        SliverToBoxAdapter(child: _buildSearchSection()),

        // 3. Category Grid
        SliverToBoxAdapter(child: _buildCategoryGrid()),

        // 4. Promo Banners
        SliverToBoxAdapter(child: _buildPromoBanners()),

        // 5. Popular Sections (Horizontal Lists)
        SliverList(
          delegate: SliverChildListDelegate([
            _buildHorizontalSection(
              title: "Popular in Home for Rent",
              items: _getMockProperties(),
            ),
            _buildHorizontalSection(
              title: "Popular in Car's",
              items: _getMockCars(),
            ),
            _buildHorizontalSection(
              title: "Popular in Computer & Networking",
              items: _getMockComputers(),
            ),
            _buildHorizontalSection(
              title: "Popular in Mobile & Tablets",
              items: _getMockMobiles(),
            ),
          ]),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 10,
      ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shopping_bag, color: AppTheme.secondaryColor, size: 20),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: "XYZFinders".text.xl.bold.color(AppTheme.secondaryColor).ellipsis.make(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Flexible(
                child: "Bidhannagar, Kolkata".text.semiBold.gray600.size(12).ellipsis.make(),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.business, color: AppTheme.secondaryColor, size: 20),
                  const SizedBox(width: 8),
                  "Search Anything...".text.gray400.size(12).make().expand(),
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.notifications_none, size: 24, color: Colors.grey),
          const SizedBox(width: 8),
          const Icon(Icons.favorite_border, size: 24, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Automobiles', 'icon': Icons.directions_car_filled_rounded, 'color': Colors.red},
      {'name': 'Beauty', 'icon': Icons.flare_rounded, 'color': Colors.pink},
      {'name': 'Electronics', 'icon': Icons.kitchen_rounded, 'color': Colors.blueGrey},
      {'name': 'Fashion & Accessories', 'icon': Icons.checkroom_rounded, 'color': Colors.deepPurple},
      {'name': 'Furniture', 'icon': Icons.chair_rounded, 'color': Colors.blue},
      {'name': 'Jobs', 'icon': Icons.work_rounded, 'color': Colors.brown},
      {'name': 'Learning & Education', 'icon': Icons.school_rounded, 'color': Colors.indigo},
      {'name': 'Local Events', 'icon': Icons.event_available_rounded, 'color': Colors.orange},
      {'name': 'Mobiles', 'icon': Icons.phone_iphone_rounded, 'color': Colors.teal},
      {'name': 'Pets & Animals Accessories', 'icon': Icons.pets_rounded, 'color': Colors.amber},
      {'name': 'Real Estate', 'icon': Icons.business_rounded, 'color': Colors.green},
      {'name': 'Services', 'icon': Icons.handyman_rounded, 'color': Colors.blueAccent},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: () {
            Widget? targetScreen;
            switch (cat['name']) {
              case 'Automobiles':
                targetScreen = const AutomobileListScreen();
                break;
              case 'Beauty':
                targetScreen = const BeautyListScreen();
                break;
              case 'Electronics':
                targetScreen = const ElectronicsListScreen();
                break;
              case 'Fashion & Accessories':
                targetScreen = const FashionListScreen();
                break;
              case 'Furniture':
                targetScreen = const FurnitureListScreen();
                break;
              case 'Real Estate':
                targetScreen = const RealEstateListScreen();
                break;
              case 'Local Events':
                targetScreen = const LocalEventsListScreen();
                break;
              case 'Learning & Education':
                targetScreen = const EducationListScreen();
                break;
              case 'Pets & Animals Accessories':
                targetScreen = const PetsAccessoriesListScreen();
                break;
              case 'Mobiles':
                targetScreen = const MobilesListScreen();
                break;
              case 'Services':
                targetScreen = const ServicesListScreen();
                break;
            }

            if (targetScreen != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => targetScreen!),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cat['icon'] as IconData, size: 32, color: cat['color'] as Color),
              const SizedBox(height: 8),
              Text(
                cat['name'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ).animate().scale(delay: (50 * index).ms, duration: 300.ms);
    },
    );
  }

  Widget _buildPromoBanners() {
    return SizedBox(
      height: 250, // Increased height for text below image
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildPromoCard(
            title: "Ready to List Your Home?",
            subtitle: "Reach Buyers and Rentals Fast.",
            tag: "PROPERTY",
            imageUrl: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=500&q=60",
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Ready to List Your Car?",
            subtitle: "Reach Buyers and Rentals Fast.",
            tag: "VEHICLES",
            imageUrl: "https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=500&q=60",
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Coming Soon - Fashion",
            subtitle: "Find the latest trends.",
            tag: "FASHION",
            imageUrl: "https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=500&q=60",
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({required String title, required String subtitle, required String tag, required String imageUrl}) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: tag.text.size(8).bold.make(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          title.text.lg.bold.make(),
          subtitle.text.gray500.sm.make(),
        ],
      ),
    );
  }

  Widget _buildHorizontalSection({required String title, required List<Map<String, dynamic>> items}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              title.text.lg.bold.make(),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
        SizedBox(
          height: 250, // Increased height slightly to accommodate content
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5), // Added vertical margin to avoid shadow clipping
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: DecorationImage(
                            image: NetworkImage(item['image'] as String),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "₹ ${item['price']}/-".text.lg.bold.red600.make(),
                            const SizedBox(height: 2),
                            Flexible(
                              child: (item['title'] as String)
                                  .text
                                  .semiBold
                                  .size(12)
                                  .maxLines(1)
                                  .ellipsis
                                  .make(),
                            ),
                            const SizedBox(height: 2),
                            Flexible(
                              child: (item['location'] as String)
                                  .text
                                  .gray500
                                  .size(9)
                                  .maxLines(1)
                                  .ellipsis
                                  .make(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Mock Data Generators
  List<Map<String, dynamic>> _getMockProperties() {
    return [
      {
        'title': '3 BHK Luxury Apartment',
        'price': '45,000',
        'location': 'Greater Kailash, New Delhi',
        'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=300&q=60'
      },
      {
        'title': 'Studio Flat Near Metro',
        'price': '15,000',
        'location': 'Sector 62, Noida',
        'image': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=300&q=60'
      },
    ];
  }

  List<Map<String, dynamic>> _getMockCars() {
    return [
      {
        'title': 'BMW M5 Competition',
        'price': '2,29,000',
        'location': 'Sector 62 Dwarka, New Delhi',
        'image': 'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=300&q=60'
      },
      {
        'title': 'Premium Hyundai i10',
        'price': '90,000',
        'location': 'Greater Kailash, New Delhi',
        'image': 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=300&q=60'
      },
    ];
  }

  List<Map<String, dynamic>> _getMockComputers() {
    return [
      {
        'title': 'Intel i9 14gen -High-end Processor',
        'price': '45,000',
        'location': 'Greater Kailash, New Delhi',
        'image': 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?auto=format&fit=crop&w=300&q=60'
      },
      {
        'title': 'Honor Tablet S9+ Ultra 12GB, 512GB',
        'price': '29,000',
        'location': 'Sector 62 Duarka, New Delhi',
        'image': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=300&q=60'
      },
    ];
  }

  List<Map<String, dynamic>> _getMockMobiles() {
    return [
      {
        'title': 'Honor Tab A4+ with Keypad, 12GB...',
        'price': '90,000',
        'location': 'Greater Kailash, New Delhi',
        'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=300&q=60'
      },
      {
        'title': 'iPhone 16 Pro Max 12GB 256GB,Go...',
        'price': '56,000',
        'location': 'Sector 62 Duarka, New Delhi',
        'image': 'https://images.unsplash.com/photo-1616348436168-de43ad0db179?auto=format&fit=crop&w=300&q=60'
      },
    ];
  }
}
