import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/product_service.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'real_estate_detail_screen.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';
import '../../../widgets/category_search_header.dart';

class RealEstateListScreen extends StatefulWidget {
  final int? categoryId;
  const RealEstateListScreen({super.key, this.categoryId});

  @override
  State<RealEstateListScreen> createState() => _RealEstateListScreenState();
}

class _RealEstateListScreenState extends State<RealEstateListScreen> {
  bool _showVerifiedOnly = false;
  String _selectedPropertyType = "Residential";
  String _selectedFurnishing = "All";
  int _selectedBedrooms = 3;
  int _selectedBathrooms = 2;

  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _productService.getProducts(categoryId: widget.categoryId);
      if (mounted) {
        setState(() {
          _products = List<ProductModel>.from(response['products']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CategorySearchHeader(
              prefixIcon: Icons.location_on_outlined,
              hintText: "Search Location...",
              onBack: () => Navigator.pop(context),
            ),
            _buildFilterBar(),
            _buildResultsSummary(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _error != null 
                  ? Center(child: "Error: $_error".text.make())
                  : _products.isEmpty
                    ? Center(child: "No properties found".text.make())
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: _products.length,
                        itemBuilder: (context, index) => _buildPropertyCard(context, _products[index]),
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 0,
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
    final filters = ["Rent", "Residential", "Price Range", "Bedrooms", "Bathrooms"];
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        children: [
          InkWell(
            onTap: () => _showAdvancedFilter(context),
            child: Row(
              children: [
                const Icon(Icons.tune, size: 20, color: AppTheme.secondaryColor),
                const SizedBox(width: 8),
                "Filter".text.bold.size(13).make(),
                const SizedBox(width: 12),
              ],
            ),
          ),
          ...filters.map((filter) => Container(
                margin: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => _showAdvancedFilter(context),
                  child: Chip(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 1,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    label: Row(
                      children: [
                        Text(filter, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showAdvancedFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Location"),
                      _buildFilterInput(Icons.location_on_outlined, "Enter your location........"),
                      const SizedBox(height: 20),
                      _sectionTitle("Property Type"),
                      Row(
                        children: [
                          _buildSelectableTile("Residential", _selectedPropertyType == "Residential", (val) => setModalState(() => _selectedPropertyType = val)),
                          const SizedBox(width: 15),
                          _buildSelectableTile("Commercial", _selectedPropertyType == "Commercial", (val) => setModalState(() => _selectedPropertyType = val)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle("Price"),
                      Row(
                        children: [
                          Expanded(child: _buildPriceInput("Min. ₹")),
                          const SizedBox(width: 15),
                          Expanded(child: _buildPriceInput("Max. ₹")),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle("Bedrooms"),
                      _buildNumberSelector(10, _selectedBedrooms, (val) => setModalState(() => _selectedBedrooms = val)),
                      const SizedBox(height: 20),
                      _sectionTitle("Bathrooms"),
                      _buildNumberSelector(6, _selectedBathrooms, (val) => setModalState(() => _selectedBathrooms = val), isBathroom: true),
                      const SizedBox(height: 20),
                      _sectionTitle("Furnishing Type"),
                      _buildFurnishingTabs(setModalState),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildFilterBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: title.text.bold.size(16).make(),
    );
  }

  Widget _buildFilterInput(IconData icon, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildSelectableTile(String title, bool isSelected, Function(String) onTap) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(title),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppTheme.secondaryColor : Colors.grey.shade200),
          ),
          child: Center(
            child: title.text.bold.size(12).color(isSelected ? AppTheme.secondaryColor : Colors.black87).make(),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberSelector(int count, int selected, Function(int) onTap, {bool isBathroom = false}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(count, (index) {
          int val = index + 1;
          bool isSelected = selected == val;
          String label = isBathroom && val == count ? "$val+" : "$val";
          return InkWell(
            onTap: () => onTap(val),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.secondaryColor.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isSelected ? AppTheme.secondaryColor : Colors.grey.shade200),
              ),
              child: Center(
                child: label.text.bold.size(12).color(isSelected ? AppTheme.secondaryColor : Colors.black87).make(),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFurnishingTabs(StateSetter setModalState) {
    final types = ["All", "Unfurnished", "Semi-Furnished", "Full-Furnished"];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: types.map((type) {
            bool isSelected = _selectedFurnishing == type;
            return InkWell(
              onTap: () => setModalState(() => _selectedFurnishing = type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                child: type.text.size(12).bold.color(isSelected ? Colors.black : Colors.grey).make(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              "Showing Results".text.gray500.size(10).make(),
              "14,256".text.xl.bold.make(),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 180,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: "Search Now".text.white.bold.make(),
            ),
          ),
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
          "Showing Results - ${_products.length}".text.italic.gray600.size(12).make(),
          Row(
            children: [
              "Verified Only".text.semiBold.size(12).make(),
              const SizedBox(width: 8),
              SizedBox(
                height: 24,
                width: 40,
                child: Switch(
                  value: _showVerifiedOnly,
                  onChanged: (val) => setState(() => _showVerifiedOnly = val),
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

  Widget _buildPropertyCard(BuildContext context, ProductModel item) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RealEstateDetailScreen(
            productId: item.id,
            title: item.title,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  child: item.firstImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.resolveImageUrl(baseUrl) ?? '',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          height: 220,
                          color: Colors.grey[100],
                          width: double.infinity,
                          child: const Icon(Icons.home_work_outlined, color: Colors.grey, size: 50).centered(),
                        ),
                      )
                    : Container(
                        height: 220,
                        color: Colors.grey[100],
                        width: double.infinity,
                        child: const Icon(Icons.home_work_outlined, color: Colors.grey, size: 50).centered(),
                      ),
                ),
                if (item.isFeatured)
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
              ],
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      "₹ ${item.price}".text.xl2.bold.color(AppTheme.secondaryColor).make(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  item.title.text.lg.bold.make(),
                  "Category ID: ${item.categoryId}  •  ${item.condition}".text.gray500.size(12).make(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      "Views: ${item.viewsCount}".text.gray500.size(12).make(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
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
                                "Chat Now".text.color(const Color(0xFF1E88E5)).semiBold.make(),
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
      ),
    );
  }
}
