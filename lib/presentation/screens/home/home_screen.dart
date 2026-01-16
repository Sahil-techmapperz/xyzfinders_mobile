import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../products/product_list_screen.dart';
import '../products/product_detail_screen.dart';
import '../seller/my_products_screen.dart';
import '../seller/create_product_screen.dart';
import '../../../core/utils/toast_utils.dart';
import '../auth/login_screen.dart';
import '../../widgets/featured_carousel.dart';
import '../../widgets/products/product_card.dart';
import '../../../data/services/image_upload_service.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const ProductListScreen(),
    const SizedBox.shrink(), // Placeholder for center button index
    const Center(child: Text('Inbox')),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
       Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateProductScreen()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Green Status Strip
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4, 
              bottom: 8
            ),
            color: AppTheme.primaryColor,
            child: const Text(
              '25,000 Active Ads | Verified Sellers | Secure Payments',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ),
          
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      
      // Floating "Post Ad" Button
      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: AppTheme.secondaryColor,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(1, Icons.grid_view_outlined, Icons.grid_view, 'Categories'),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(3, Icons.chat_bubble_outline, Icons.chat_bubble, 'Inbox'),
            _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppTheme.primaryColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// NEW: Custom Home Tab
// ---------------------------

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _selectedCategoryIndex = 0; // Default to 'All'
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps},
    {'name': 'Property', 'icon': Icons.home_work_outlined},
    {'name': 'Furniture', 'icon': Icons.chair_outlined},
    {'name': 'Mobile', 'icon': Icons.phone_android_outlined},
    {'name': 'Gadgets', 'icon': Icons.headphones_outlined},
    {'name': 'Electronics', 'icon': Icons.devices_outlined},
    {'name': 'Fashion', 'icon': Icons.checkroom_outlined},
    {'name': 'Vehicles', 'icon': Icons.directions_car_outlined},
    {'name': 'Books', 'icon': Icons.menu_book_outlined},
    {'name': 'Sports', 'icon': Icons.sports_basketball_outlined},
    {'name': 'Pets', 'icon': Icons.pets_outlined},
    {'name': 'Jobs', 'icon': Icons.work_outline},
    {'name': 'Services', 'icon': Icons.build_outlined},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header & Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // Logo Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/logo.png', height: 40, width: 200), // Adjust sizing
                          const SizedBox(width: 8),
                        ],
                      ),
                      const Icon(Icons.notifications_none_outlined, size: 28, color: AppTheme.primaryColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 4, 6, 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: false,
                              fillColor: Colors.transparent,
                              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                              suffixIcon: const Icon(Icons.mic, color: AppTheme.primaryColor),
                              hintText: 'Search Anything...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(14), // Square-ish rounded
                          ),
                          child: const Icon(Icons.search, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Container(
              height: 110,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                              border: isSelected ? Border.all(color: AppTheme.secondaryColor, width: 2) : null,
                            ),
                            child: Icon(
                              _categories[index]['icon'] as IconData,
                              color: isSelected ? AppTheme.secondaryColor : const Color(0xFF455A64),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _categories[index]['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppTheme.secondaryColor : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Hero Carousel
          SliverToBoxAdapter(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.products.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: FeaturedCarousel(products: provider.products),
                );
              },
            ),
          ),

          // Fresh Recommendations Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Fresh Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Product Grid
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              // Show mock products if empty to demonstrate UI (since image is static) or use real data
              // For now, sticking to provider data
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = provider.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                           Navigator.push(
                             context, 
                             MaterialPageRoute(
                               builder: (_) => ProductDetailScreen(
                                 productId: product.id,
                                 title: product.title,
                               ),
                             ),
                           );
                        },
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                      .slideY(begin: 0.1);
                    },
                    childCount: provider.products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                ),
              );
            },
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding for FAB
        ],
      ),
    );
  }
}

// ---------------------------
// Refactored Profile Tab
// ---------------------------
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isSeller = authProvider.user!.role == 'seller';

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Curved Background
                    Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    // Profile Info
                    Column(
                      children: [
                        const SizedBox(height: 60),
                        Center(
                          child: GestureDetector(
                            onTap: () => _showImagePickerOptions(context, authProvider),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                  ),
                                  child: CircleAvatar(
                                    key: ValueKey('profile_${authProvider.user?.id}_${DateTime.now().millisecondsSinceEpoch}'),
                                    radius: 50,
                                    backgroundImage: authProvider.user?.id != null
                                        ? NetworkImage(
                                            '${ImageUploadService().getProfileImageUrl(authProvider.user!.id)}?t=${DateTime.now().millisecondsSinceEpoch}',
                                          ) as ImageProvider
                                        : const NetworkImage('https://placehold.co/100x100.png'),
                                    backgroundColor: Colors.grey[200],
                                    onBackgroundImageError: (_, __) {},
                                    child: authProvider.user?.id == null
                                        ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          authProvider.user!.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        Text(
                          'Member since 2024',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatCard('Ads Posted', '12'),
                            const SizedBox(width: 12),
                            _buildStatCard('Views', '1.2k'),
                            const SizedBox(width: 12),
                            _buildStatCard('Sold', '5'),
                          ],
                        ),
                        
                         const SizedBox(height: 24),
                         
                         // Menu Items
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 20),
                           child: Column(
                             children: [
                               if (isSeller)
                                 _buildMenuItem(
                                   icon: Icons.inventory_2_outlined,
                                   title: 'My Ads',
                                   onTap: () {
                                     Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const MyProductsScreen()),
                                    );
                                   },
                                 ),
                               _buildMenuItem(icon: Icons.favorite_border, title: 'Favorites', onTap: () {}),
                               _buildMenuItem(
                                 icon: Icons.star_border, 
                                 title: 'Membership Plan', 
                                 trailing: Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                   decoration: BoxDecoration(
                                     color: AppTheme.secondaryColor,
                                     borderRadius: BorderRadius.circular(10),
                                   ),
                                   child: const Text('Upgrade', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                 ),
                                 onTap: () {},
                               ),
                               _buildMenuItem(icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
                               _buildMenuItem(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),
                               
                               const SizedBox(height: 20),
                               
                               // Logout
                               TextButton.icon(
                                 onPressed: () async {
                                    await authProvider.logout();
                                    if (context.mounted) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      );
                                    }
                                 },
                                 icon: const Icon(Icons.logout, color: Colors.red),
                                 label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                               ),
                               const SizedBox(height: 40),
                             ],
                           ),
                         ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
    
    Widget _buildStatCard(String label, String value) {
      return Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.bar_chart, color: AppTheme.primaryColor, size: 20), // Placeholder icon
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
            Text(label, style: const TextStyle(color: Colors.black87, fontSize: 10)),
          ],
        ),
      );
    }
    
    Widget _buildMenuItem({required IconData icon, required String title, Widget? trailing, required VoidCallback onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black))),
              if (trailing != null) trailing else const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      );
    }

    void _showImagePickerOptions(BuildContext context, AuthProvider authProvider) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.camera, authProvider);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.gallery, authProvider);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteProfileImage(authProvider);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> _pickAndUploadImage(ImageSource source, AuthProvider authProvider) async {
      try {
        final ImagePicker picker = ImagePicker();
        // Add imageQuality AND maxWidth to force JPEG conversion (HEIC not supported by backend)
        final XFile? image = await picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 2048, // Force conversion to JPEG and reduce size
          maxHeight: 2048,
        );

        if (image != null) {
          final File imageFile = File(image.path);
          print('Uploading image: ${imageFile.path}');
          
          try {
            final result = await ImageUploadService().uploadProfileImage(imageFile);
            print('Image uploaded successfully: $result');
            
            // Refresh user data to get updated profile
            await authProvider.refreshUser();
            
            if (context.mounted) {
              ToastUtils.showSuccess(context, 'Profile image updated successfully');
            }
          } catch (uploadError) {
            print('Upload error details: $uploadError');
            if (context.mounted) {
              ToastUtils.showError(context, 'Failed to upload image. Please try again');
            }
          }
        }
      } catch (e) {
        print('Pick image error: $e');
        if (context.mounted) {
          ToastUtils.showError(context, 'Failed to pick image');
        }
      }
    }

    Future<void> _deleteProfileImage(AuthProvider authProvider) async {
      try {
        await ImageUploadService().deleteProfileImage();
        
        // Refresh user data
        await authProvider.refreshUser();
        
        if (context.mounted) {
          ToastUtils.showSuccess(context, 'Profile image removed');
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showError(context, 'Failed to remove image: ${e.toString()}');
        }
      }
    }
}
