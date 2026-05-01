import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';
import 'agency_post_ad_screen.dart';
import 'agency_post_ad_wizard_screen.dart';

class AgencyPostAdCategoryScreen extends StatefulWidget {
  const AgencyPostAdCategoryScreen({super.key});

  @override
  State<AgencyPostAdCategoryScreen> createState() => _AgencyPostAdCategoryScreenState();
}

class _AgencyPostAdCategoryScreenState extends State<AgencyPostAdCategoryScreen> {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();
  
  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _filteredCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          _allCategories = categories;
          _filteredCategories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching categories: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories
          .where((cat) => cat.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: "Choose Category".text.bold.make(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      
                      // Gradient Circle with Plus
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF334155), Color(0xFFEA580C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 40),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),
                      
                      "What Are You Listing Today?".text.bold.xl3.color(const Color(0xFF1E293B)).center.make(),
                      const SizedBox(height: 12),
                      "Choose a category below to start creating your ad. Reach millions of buyers across India."
                          .text.gray500.center.sm.make()
                          .pSymmetric(h: 40),
                      
                      const SizedBox(height: 32),
                      
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: "Search categories...",
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = _filteredCategories[index];
                        return _buildCategoryCard(cat, index);
                      },
                      childCount: _filteredCategories.length,
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    );
  }

  Widget _buildCategoryCard(CategoryModel cat, int index) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgencyPostAdWizardScreen(category: cat),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (cat.iconUrl != null && cat.iconUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: cat.iconUrl!.startsWith('http') 
                    ? cat.iconUrl! 
                    : '$baseUrl${cat.iconUrl}',
                height: 50,
                width: 50,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => Icon(Icons.category, size: 40, color: Colors.grey.shade300),
              )
            else
              Icon(Icons.category, size: 40, color: Colors.grey.shade300),
              
            const SizedBox(height: 16),
            cat.name.text.bold.sm.color(const Color(0xFF1E293B)).center.make().pSymmetric(h: 8),
          ],
        ),
      ).animate().fadeIn(delay: (100 * (index % 6)).ms).scale(duration: 300.ms, curve: Curves.easeOut),
    );
  }
}
