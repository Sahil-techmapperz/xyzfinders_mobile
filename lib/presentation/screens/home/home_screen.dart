import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:collection/collection.dart';
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
import '../categories/jobs/jobs_list_screen.dart';
import '../categories/automobiles/automobile_detail_screen.dart';
import '../categories/beauty/beauty_detail_screen.dart';
import '../categories/electronics/electronics_detail_screen.dart';
import '../categories/fashion/fashion_detail_screen.dart';
import '../categories/furniture/furniture_detail_screen.dart';
import '../categories/local_events/local_events_detail_screen.dart';
import '../categories/education/education_detail_screen.dart';
import '../categories/pets/pets_accessories_detail_screen.dart';
import '../categories/services/services_detail_screen.dart';
import '../categories/mobiles/mobiles_detail_screen.dart';
import '../categories/real_estate/real_estate_detail_screen.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../notifications/notification_screen.dart';
import '../chats/chat_list_screen.dart';
import '../products/product_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/api_service.dart';
import '../../../core/constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/product_service.dart';
import '../seller/seller_dashboard_screen.dart';
import '../seller/my_products_screen.dart';
import '../seller/create_product_screen.dart';
import '../seller/store_list_screen.dart';
import '../ads/post_ad_category_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/agency_provider.dart';
import '../agency/agency_login_screen.dart';
import '../agency/agency_registration_screen.dart';
import '../agency/agency_dashboard_screen.dart';
import '../../widgets/favorite_toggle_button.dart';
import '../wishlist/wishlist_screen.dart';
import '../../widgets/common/searchable_location_picker.dart';
import '../../widgets/common/location_search_sheet.dart';
import 'package:provider/provider.dart';
import '../categories/all_categories_screen.dart';
import '../../widgets/common/job_selection_sheet.dart';
import '../categories/jobs/find_jobs_screen.dart';
import '../ads/post_ad_form_screen.dart';
import '../../widgets/auth/auth_modal.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // List of screens corresponding to bottom nav bar indices
  List<Widget> get _buyerScreens => [
    const HomeTab(),
    const WishlistScreen(showAppBar: false),
    const SizedBox.shrink(), // FAB placeholder
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  List<Widget> get _sellerScreens => [
    SellerDashboardScreen(
      onInventoryTap: () {
        setState(() => _selectedIndex = 1);
      },
    ),
    MyProductsScreen(),
    const SizedBox.shrink(), // FAB placeholder
    const ChatListScreen(), // Use same chats for both roles
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final agencyProvider = Provider.of<AgencyProvider>(context);
    if (agencyProvider.isAuthenticated) {
      return const AgencyDashboardScreen();
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final isSellerMode = authProvider.isSellerMode;
    final screens = isSellerMode ? _sellerScreens : _buyerScreens;

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        key: ValueKey('${isSellerMode ? 'seller' : 'buyer'}_stack'),
        index: _selectedIndex, 
        children: screens,
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        isSellerMode: isSellerMode,
        onItemSelected: (index) {
          if (index != 2) {
            setState(() => _selectedIndex = index);
          }
        },
      ),
      floatingActionButton: CustomFab(
        onPressed: () {}, // speed-dial handles its own actions internally
        isSellerMode: isSellerMode,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedLocation = "Bidhannagar, Kolkata";
  int? _selectedLocationId;
  List<dynamic> _locations = [];
  bool _isLoadingLocations = false;
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoadingCategories = false;
  List<CategoryModel> _categories = [];
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();

  // Dynamic Product Lists
  List<ProductModel> _latestRealEstate = [];
  List<ProductModel> _latestCars = [];
  List<ProductModel> _latestElectronics = [];
  List<ProductModel> _latestMobiles = [];

  // Loading States for Sections
  bool _isRealEstateLoading = false;
  bool _isCarsLoading = false;
  bool _isElectronicsLoading = false;
  bool _isMobilesLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _fetchLocations();
    _fetchCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.read<FavoriteProvider>().loadFavorites();
        context.read<NotificationProvider>().fetchNotifications();
      }
    });
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categories = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
        _fetchDynamicHomeProducts(); // Fetch section data once categories are available
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _fetchDynamicHomeProducts() async {
    // 1. Identification: Find category IDs by keyword
    int? realEstateId, carsId, gadgetId, mobileId;

    for (var cat in _categories) {
      final name = cat.name.toLowerCase();
      if (name.contains('real estate') || name.contains('property') || name.contains('home')) realEstateId = cat.id;
      if (name.contains('automobile') || name.contains('car') || name.contains('vehicle')) carsId = cat.id;
      if (name.contains('electronic') || name.contains('gadget') || name.contains('laptop')) gadgetId = cat.id;
      if ((name.contains('mobile') && !name.contains('auto')) || name.contains('phone') || name.contains('tablet')) mobileId = cat.id;
    }
    
    debugPrint('Home Category Matching: RE:$realEstateId, Cars:$carsId, Electronics:$gadgetId, Mobiles:$mobileId');

    // 2. Fetch Data in Parallel/Sequence
    if (realEstateId != null) _fetchSection(realEstateId, (list) => _latestRealEstate = list, (val) => _isRealEstateLoading = val);
    if (carsId != null) _fetchSection(carsId, (list) => _latestCars = list, (val) => _isCarsLoading = val);
    if (gadgetId != null) _fetchSection(gadgetId, (list) => _latestElectronics = list, (val) => _isElectronicsLoading = val);
    if (mobileId != null) _fetchSection(mobileId, (list) => _latestMobiles = list, (val) => _isMobilesLoading = val);
  }

  Future<void> _fetchSection(int catId, Function(List<ProductModel>) onData, Function(bool) onLoading) async {
    if (mounted) setState(() => onLoading(true));
    try {
      final response = await _productService.getProducts(categoryId: catId, perPage: 6);
      final fetchedProducts = List<ProductModel>.from(response['products']);
      debugPrint('Home Section fetched for cat $catId: ${fetchedProducts.length} items');
      
      if (mounted) {
        setState(() {
          onData(fetchedProducts);
          onLoading(false);
        });
      }
    } catch (e) {
      debugPrint('Error fetching home section for cat $catId: $e');
      if (mounted) setState(() => onLoading(false));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(
          searchQuery: query.trim(),
        ),
      ),
    );
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedLocation = prefs.getString('selected_location_name') ?? "Bidhannagar, Kolkata";
      _selectedLocationId = prefs.getInt('selected_location_id');
    });
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoadingLocations = true);
    try {
      final response = await ApiService().get(ApiConstants.locations);
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _locations = response.data['data'];
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      if (mounted) setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _saveLocation(int? id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setInt('selected_location_id', id);
    } else {
      await prefs.remove('selected_location_id');
    }
    await prefs.setString('selected_location_name', name);
    if (!mounted) return;
    setState(() {
      _selectedLocation = name;
      _selectedLocationId = id;
    });

    // Redirect to All Categories with the selected location filter
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(
          categoryName: 'All Categories',
          locationId: id,
          locationName: name,
        ),
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (_isLoadingLocations) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        return LocationSearchSheet(
          locations: _locations,
          selectedLocationId: _selectedLocationId,
          selectedLocationName: _selectedLocation,
          onSelect: (id, name) {
            _saveLocation(id, name);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          _fetchLocations(),
          _fetchCategories(),
          context.read<FavoriteProvider>().loadFavorites(),
        ]);
      },
      color: AppTheme.primaryColor,
      edgeOffset: MediaQuery.of(context).padding.top + 20,
      child: CustomScrollView(
        slivers: [
          // 1. Header with Logo and Location
          SliverToBoxAdapter(child: _buildHeader(context)),
  
          // 2. Search Section
          SliverToBoxAdapter(child: _buildSearchSection(context)),
  
          // 3. Category Header
          SliverToBoxAdapter(child: _buildCategoryHeader(context)),

          // 4. Category Grid
          SliverToBoxAdapter(child: _buildCategoryGrid()),
  
          // 5. Promo Banners
          SliverToBoxAdapter(child: _buildPromoBanners()),
  
          // 5. Popular Sections (Horizontal Lists)
          SliverList(
            delegate: SliverChildListDelegate([
              _buildHorizontalSection(
                title: "Popular in Home for Rent",
                products: _latestRealEstate,
                isLoading: _isRealEstateLoading,
                onViewMore: () {
                  final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('real estate'));
                  if (cat != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RealEstateListScreen(categoryId: cat.id)));
                  }
                },
              ),
              _buildHorizontalSection(
                title: "Popular in Car's",
                products: _latestCars,
                isLoading: _isCarsLoading,
                onViewMore: () {
                  final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('automobile'));
                  if (cat != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AutomobileListScreen(categoryId: cat.id)));
                  }
                },
              ),
              _buildHorizontalSection(
                title: "Popular in Electronics",
                products: _latestElectronics,
                isLoading: _isElectronicsLoading,
                onViewMore: () {
                  final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('electronic'));
                  if (cat != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ElectronicsListScreen(categoryId: cat.id)));
                  }
                },
              ),
              _buildHorizontalSection(
                title: "Popular in Mobile & Tablets",
                products: _latestMobiles,
                isLoading: _isMobilesLoading,
                onViewMore: () {
                  final cat = _categories.firstWhereOrNull((c) => (c.name.toLowerCase().contains('mobile') && !c.name.toLowerCase().contains('auto')) || c.name.toLowerCase().contains('phone') || c.name.toLowerCase().contains('tablet'));
                  if (cat != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MobilesListScreen(categoryId: cat.id)));
                  }
                },
              ),
            ]),
          ),
  
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
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
                Flexible(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Location Picker Button
          InkWell(
            onTap: _showLocationPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 4),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: _selectedLocation.text.size(12).ellipsis.make(),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
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
              child: TextField(
                controller: _searchController,
                onSubmitted: _handleSearch,
                decoration: InputDecoration(
                  hintText: "Search Anything...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  prefixIcon: const Icon(
                    Icons.business,
                    color: AppTheme.secondaryColor,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    onPressed: () => _handleSearch(_searchController.text),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 24,
                        color: Colors.grey,
                      ),
                      if (provider.unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              provider.unreadCount > 99 ? '99+' : '${provider.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
            },
            child: const Icon(Icons.favorite_border, size: 24, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'automobiles': return Icons.directions_car_filled_rounded;
      case 'beauty': return Icons.flare_rounded;
      case 'electronics': return Icons.kitchen_rounded;
      case 'fashion & accessories': return Icons.checkroom_rounded;
      case 'furniture': return Icons.chair_rounded;
      case 'jobs': return Icons.work_rounded;
      case 'learning & education': return Icons.school_rounded;
      case 'local events': return Icons.event_available_rounded;
      case 'mobiles': return Icons.phone_iphone_rounded;
      case 'pets & animals accessories': return Icons.pets_rounded;
      case 'real estate': return Icons.business_rounded;
      case 'services': return Icons.handyman_rounded;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(String name) {
    switch (name.toLowerCase()) {
      case 'automobiles': return Colors.red;
      case 'beauty': return Colors.pink;
      case 'electronics': return Colors.blueGrey;
      case 'fashion & accessories': return Colors.deepPurple;
      case 'furniture': return Colors.blue;
      case 'jobs': return Colors.brown;
      case 'learning & education': return Colors.indigo;
      case 'local events': return Colors.orange;
      case 'mobiles': return Colors.teal;
      case 'pets & animals accessories': return Colors.amber;
      case 'real estate': return Colors.green;
      case 'services': return Colors.blueAccent;
      default: return AppTheme.primaryColor;
    }
  }

  Widget _buildCategoryHeader(BuildContext context) {
    if (_isLoadingCategories || _categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          "Categories".text.bold.xl2.make(),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListScreen(categoryName: 'All Categories'),
                ),
              );
            },
            child: "View All".text.color(AppTheme.primaryColor).make(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (_isLoadingCategories) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (_categories.isEmpty) {
      return const SizedBox(height: 100);
    }

    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    int categoryPriority(String name) {
      final lower = name.toLowerCase();
      if (lower.contains('real estate') || lower.contains('property')) return 0;
      if (lower.contains('automobile') || lower.contains('car')) return 1;
      if (lower.contains('service')) return 2;
      if (lower.contains('electronic') || lower.contains('gadget')) return 3;
      if (lower.contains('fashion')) return 4;
      if (lower.contains('job')) return 5;
      if (lower.contains('learning') || lower.contains('education')) return 6;
      if (lower.contains('event')) return 7;
      if (lower.contains('mobile') || lower.contains('phone')) return 8;
      if (lower.contains('beauty')) return 9;
      if (lower.contains('furniture')) return 10;
      if (lower.contains('pet') || lower.contains('animal')) return 11;
      return 99;
    }

    final displayCategories = List.of(_categories)
      ..sort((a, b) => categoryPriority(a.name).compareTo(categoryPriority(b.name)));

    // Build rows of 3 manually to avoid GridView shrinkWrap height issues
    Widget buildCategoryCard(CategoryModel cat, int index) {
      return InkWell(
        onTap: () {
          final catName = cat.name.toLowerCase();
          
          if (catName.contains('job')) {
            JobSelectionSheet.show(
              context,
              onGetHired: () {
                final auth = context.read<AuthProvider>();
                if (auth.isAuthenticated) {
                  if (!auth.isSellerMode) {
                    auth.toggleMode();
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PostAdFormScreen(category: 'Jobs')));
                } else {
                  AuthModal.show(context);
                }
              },
              onFindJobs: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FindJobsScreen(categoryId: cat.id))),
            );
            return;
          }

          Widget? targetScreen;
          if (catName.contains('automobile')) {
            targetScreen = AutomobileListScreen(categoryId: cat.id);
          } else if (catName.contains('beauty')) {
            targetScreen = BeautyListScreen(categoryId: cat.id);
          } else if (catName.contains('electronic') || catName.contains('gadget')) {
            targetScreen = ElectronicsListScreen(categoryId: cat.id);
          } else if (catName.contains('fashion')) {
            targetScreen = FashionListScreen(categoryId: cat.id);
          } else if (catName.contains('furniture')) {
            targetScreen = FurnitureListScreen(categoryId: cat.id);
          } else if (catName.contains('real estate') || catName.contains('property')) {
            targetScreen = RealEstateListScreen(categoryId: cat.id);
          } else if (catName.contains('event')) {
            targetScreen = LocalEventsListScreen(categoryId: cat.id);
          } else if (catName.contains('education') || catName.contains('learning')) {
            targetScreen = EducationListScreen(categoryId: cat.id);
          } else if (catName.contains('pet') || catName.contains('animal')) {
            targetScreen = PetsAccessoriesListScreen(categoryId: cat.id);
          } else if ((catName.contains('mobile') && !catName.contains('auto')) || catName.contains('phone')) {
            targetScreen = MobilesListScreen(categoryId: cat.id);
          } else if (catName.contains('service')) {
            targetScreen = ServicesListScreen(categoryId: cat.id);
          } else {
            targetScreen = ProductListScreen(searchQuery: '');
          }
          if (targetScreen != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen!));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (cat.iconUrl != null && cat.iconUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: cat.iconUrl!.startsWith('http') ? cat.iconUrl! : '$baseUrl${cat.iconUrl}',
                  height: 30,
                  width: 30,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => Icon(_getCategoryIcon(cat.name), size: 30, color: _getCategoryColor(cat.name)),
                )
              else
                Icon(_getCategoryIcon(cat.name), size: 30, color: _getCategoryColor(cat.name)),
              const SizedBox(height: 6),
              Text(
                cat.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ).animate().scale(delay: (50 * index).ms, duration: 300.ms);
    }

    // Group into rows of 3
    final rows = <List<CategoryModel>>[];
    for (var i = 0; i < displayCategories.length; i += 3) {
      final end = (i + 3 < displayCategories.length) ? i + 3 : displayCategories.length;
      rows.add(displayCategories.sublist(i, end));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category rows (3 per row)
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var c = 0; c < 3; c++) ...[
                    if (c > 0) const SizedBox(width: 12),
                    Expanded(
                      child: c < rows[r].length
                          ? buildCategoryCard(rows[r][c], r * 3 + c)
                          : const SizedBox.shrink(), // empty filler for incomplete last row
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Bottom row: Listed Stores + Store Setup ──
          Consumer<AgencyProvider>(
            builder: (context, agencyProvider, _) {
              return Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StoreListScreen()),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.store_rounded, size: 32, color: AppTheme.secondaryColor),
                            SizedBox(height: 8),
                            Text('Listed Stores', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ).animate().scale(duration: 300.ms),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (agencyProvider.isAuthenticated) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AgencyDashboardScreen()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AgencyRegistrationScreen()),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_business_rounded, size: 32, color: AppTheme.secondaryColor),
                            SizedBox(height: 8),
                            Text('Store Setup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ).animate().scale(delay: 50.ms, duration: 300.ms),
                  ),
                ],
              );
            },
          ),
        ],
      ),
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
            title: "Find Your Dream Home",
            subtitle: "Browse verified property listings.",
            tag: "PROPERTY",
            imageUrl:
                "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=500&q=60",
            onTap: () {
              final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('real estate') || c.name.toLowerCase().contains('property'));
              if (cat != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RealEstateListScreen(categoryId: cat.id)));
              }
            },
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Upgrade Your Ride",
            subtitle: "Best deals on new & used cars.",
            tag: "VEHICLES",
            imageUrl:
                "https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=500&q=60",
            onTap: () {
              final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('automobile') || c.name.toLowerCase().contains('car'));
              if (cat != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AutomobileListScreen(categoryId: cat.id)));
              }
            },
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Latest Fashion Trends",
            subtitle: "Shop the newest styles.",
            tag: "FASHION",
            imageUrl:
                "https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=500&q=60",
            onTap: () {
              final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('fashion'));
              if (cat != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FashionListScreen(categoryId: cat.id)));
              }
            },
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Top Gadgets & Tech",
            subtitle: "Laptops, Mobiles & more.",
            tag: "ELECTRONICS",
            imageUrl:
                "https://images.unsplash.com/photo-1498049794561-7780e7231661?auto=format&fit=crop&w=500&q=60",
            onTap: () {
              final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('electronic') || c.name.toLowerCase().contains('gadget'));
              if (cat != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ElectronicsListScreen(categoryId: cat.id)));
              }
            },
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Find Your Next Job",
            subtitle: "Top companies are hiring now.",
            tag: "JOBS",
            imageUrl:
                "https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?auto=format&fit=crop&w=500&q=60",
            onTap: () {
              final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('job'));
              if (cat != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => JobsListScreen(categoryId: cat.id)));
              }
            },
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Beauty & Personal Care",
            subtitle: "Best products for your glow.",
            tag: "BEAUTY",
            imageUrl:
                "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=500&q=60",
            onTap: () {
              final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('beauty'));
              if (cat != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => BeautyListScreen(categoryId: cat.id)));
              }
            },
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Style Your Space",
            subtitle: "Premium furniture for your home.",
            tag: "FURNITURE",
            imageUrl:
                "https://images.unsplash.com/photo-1524758631624-e2822e304c36?auto=format&fit=crop&w=500&q=60",
            onTap: () {
              final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('furniture'));
              if (cat != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FurnitureListScreen(categoryId: cat.id)));
              }
            },
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Home & Local Services",
            subtitle: "Top professionals at your service.",
            tag: "SERVICES",
            imageUrl:
                "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=500&q=60",
            onTap: () {
              final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('service'));
              if (cat != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ServicesListScreen(categoryId: cat.id)));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String subtitle,
    required String tag,
    required String imageUrl,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
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
              ),
            ),
            const SizedBox(height: 10),
            title.text.lg.bold.make(),
            subtitle.text.gray500.sm.make(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalSection({
    required String title,
    required List<ProductModel> products,
    required bool isLoading,
    VoidCallback? onViewMore,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              title.text.lg.bold.make(),
              InkWell(
                onTap: onViewMore,
                child: const Icon(Icons.arrow_forward, size: 20),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: isLoading 
            ? const Center(child: CircularProgressIndicator())
            : products.isEmpty
              ? Center(child: "No items available".text.gray400.make())
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
              
              return InkWell(
                onTap: () {
                  final catName = title.toLowerCase();
                  Widget target;

                  if (catName.contains('real estate') || catName.contains('property')) {
                    target = RealEstateDetailScreen(productId: item.id, title: item.title);
                  } else if (catName.contains('automobile') || catName.contains('car')) {
                    target = AutomobileDetailScreen(productId: item.id, title: item.title);
                  } else if (catName.contains('electronic') || catName.contains('gadget')) {
                    target = ElectronicsDetailScreen(productId: item.id, title: item.title);
                  } else if (catName.contains('mobile') || catName.contains('phone')) {
                    target = MobilesDetailScreen(productId: item.id, title: item.title);
                  } else {
                    target = RealEstateDetailScreen(productId: item.id, title: item.title); // Default fallback
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => target),
                  );
                },
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
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
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: item.resolveImageUrl(baseUrl) ?? '',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[100],
                                  child: const Icon(Icons.image_outlined, color: Colors.grey).centered(),
                                ),
                              ),
                              // Heart Icon
                              Positioned(
                                top: 8,
                                right: 8,
                                child: FavoriteToggleButton(
                                  product: item,
                                  iconSize: 16,
                                  padding: const EdgeInsets.all(6),
                                ),
                              ),
                            ],
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
                              "₹ ${item.price}/-".text.lg.bold.color(AppTheme.secondaryColor).make(),
                              const SizedBox(height: 2),
                              Flexible(
                                child: item.title.text.semiBold
                                    .size(12)
                                    .maxLines(1)
                                    .ellipsis
                                    .make(),
                              ),
                              const SizedBox(height: 2),
                              Flexible(
                                child: (item.cityName ?? item.locationName ?? 'N/A').toString().text.gray500
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
