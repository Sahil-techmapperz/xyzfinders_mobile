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
import '../../../data/services/category_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens corresponding to bottom nav bar indices
  List<Widget> get _screens => [
    const HomeTab(),
    const WishlistScreen(),
    const SizedBox.shrink(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          // Prevent switching to the FAB index natively
          if (index != 2) {
            setState(() => _selectedIndex = index);
          }
        },
      ),
      floatingActionButton: CustomFab(onPressed: () {}),
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
      if (name.contains('mobile') || name.contains('phone') || name.contains('tablet')) mobileId = cat.id;
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
        setState(() {
          _locations = response.data['data'];
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _saveLocation(int id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_location_id', id);
    await prefs.setString('selected_location_name', name);
    setState(() {
      _selectedLocation = name;
      _selectedLocationId = id;
    });
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Select Location".text.xl2.bold.make(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isLoadingLocations)
                const Center(child: CircularProgressIndicator())
              else if (_locations.isEmpty)
                "No locations available".text.make().centered().p20()
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _locations.length,
                    itemBuilder: (context, index) {
                      final loc = _locations[index];
                      final name = "${loc['name']}, ${loc['city_name']}";
                      final isSelected = loc['id'] == _selectedLocationId;

                      return ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: isSelected ? AppTheme.primaryColor : Colors.grey,
                        ),
                        title: name.text.semiBold.color(isSelected ? AppTheme.primaryColor : Colors.black).make(),
                        subtitle: "${loc['state_name']}".text.xs.make(),
                        onTap: () {
                          _saveLocation(loc['id'], name);
                          Navigator.pop(context);
                        },
                        trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 1. Header with Logo and Location
        SliverToBoxAdapter(child: _buildHeader(context)),

        // 2. Search Section
        SliverToBoxAdapter(child: _buildSearchSection(context)),

        // 3. Category Grid
        SliverToBoxAdapter(child: _buildCategoryGrid()),

        // 4. Promo Banners
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
                final cat = _categories.firstWhereOrNull((c) => c.name.toLowerCase().contains('mobile'));
                if (cat != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MobilesListScreen(categoryId: cat.id)));
                }
              },
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
          Flexible(
            child: InkWell(
              onTap: _showLocationPicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: _selectedLocation.text.semiBold.gray600
                        .size(12)
                        .ellipsis
                        .make(),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 16),
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
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.notifications_none,
                size: 24,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.favorite_border, size: 24, color: Colors.grey),
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

    // Process backend URL to remove /api if iconUrl already has it
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

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
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        return InkWell(
          onTap: () {
            Widget? targetScreen;
            final catName = cat.name.toLowerCase();
            
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
            } else if (catName.contains('job')) {
              targetScreen = JobsListScreen(categoryId: cat.id);
            } else if (catName.contains('real estate') || catName.contains('property')) {
              targetScreen = RealEstateListScreen(categoryId: cat.id);
            } else if (catName.contains('event')) {
              targetScreen = LocalEventsListScreen(categoryId: cat.id);
            } else if (catName.contains('education') || catName.contains('learning')) {
              targetScreen = EducationListScreen(categoryId: cat.id);
            } else if (catName.contains('pet') || catName.contains('animal')) {
              targetScreen = PetsAccessoriesListScreen(categoryId: cat.id);
            } else if (catName.contains('mobile') || catName.contains('phone')) {
              targetScreen = MobilesListScreen(categoryId: cat.id);
            } else if (catName.contains('service')) {
              targetScreen = ServicesListScreen(categoryId: cat.id);
            } else {
              targetScreen = ProductListScreen(searchQuery: '', /*categoryId: cat.id*/);
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
                if (cat.iconUrl != null && cat.iconUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: cat.iconUrl?.startsWith('http') == true 
                        ? cat.iconUrl! 
                        : '$baseUrl${cat.iconUrl}',
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                    // Remove color filter as it tints the entire image (making icons look like solid squares)
                    // color: _getCategoryColor(cat.name),
                    errorWidget: (context, url, error) => Icon(_getCategoryIcon(cat.name), size: 32, color: _getCategoryColor(cat.name)),
                  )
                else
                  Icon(
                    _getCategoryIcon(cat.name),
                    size: 32,
                    color: _getCategoryColor(cat.name),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    cat.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
            imageUrl:
                "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=500&q=60",
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Ready to List Your Car?",
            subtitle: "Reach Buyers and Rentals Fast.",
            tag: "VEHICLES",
            imageUrl:
                "https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=500&q=60",
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            title: "Coming Soon - Fashion",
            subtitle: "Find the latest trends.",
            tag: "FASHION",
            imageUrl:
                "https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=500&q=60",
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
  }) {
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
          const SizedBox(height: 10),
          title.text.lg.bold.make(),
          subtitle.text.gray500.sm.make(),
        ],
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
                          child: CachedNetworkImage(
                            imageUrl: item.resolveImageUrl(baseUrl) ?? '',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.image_outlined, color: Colors.grey).centered(),
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
                                child: (item.location?['name'] ?? 'Unknown').toString().text.gray500
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
