import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/category_model.dart';
import '../products/product_list_screen.dart';

// Import all specific category screens
import 'automobiles/automobile_list_screen.dart';
import 'beauty/beauty_list_screen.dart';
import 'electronics/electronics_list_screen.dart';
import 'fashion/fashion_list_screen.dart';
import 'furniture/furniture_list_screen.dart';
import 'jobs/jobs_list_screen.dart';
import 'local_events/local_events_list_screen.dart';
import 'education/education_list_screen.dart';
import 'pets/pets_accessories_list_screen.dart';
import 'mobiles/mobiles_list_screen.dart';
import 'real_estate/real_estate_list_screen.dart';
import 'services/services_list_screen.dart';
import '../seller/store_list_screen.dart';
import '../../widgets/common/job_selection_sheet.dart';
import 'jobs/find_jobs_screen.dart';
import '../ads/post_ad_form_screen.dart';
import '../../widgets/auth/auth_modal.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AllCategoriesScreen extends StatelessWidget {
  final List<CategoryModel> categories;

  const AllCategoriesScreen({super.key, required this.categories});

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
      case 'pets & animals accessories':
      case 'pet & animal accessories': return Icons.pets_rounded;
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
      case 'pets & animals accessories':
      case 'pet & animal accessories': return Colors.amber;
      case 'real estate': return Colors.green;
      case 'services': return Colors.blueAccent;
      default: return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: "All Categories".text.make(),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StoreListScreen()),
                );
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
                    const Icon(
                      Icons.store_rounded,
                      size: 32,
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    "Stores".text.bold.size(11).make(),
                  ],
                ),
              ),
            );
          }

          final cat = categories[index - 1];
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
                      height: 38,
                      width: 38,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) => Icon(_getCategoryIcon(cat.name), size: 38, color: _getCategoryColor(cat.name)),
                    )
                  else
                    Icon(
                      _getCategoryIcon(cat.name),
                      size: 38,
                      color: _getCategoryColor(cat.name),
                    ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      cat.name == 'Pets & Animals Accessories' ? 'Pet & Animal Accessories' : (cat.name == 'Beauty' ? 'Beauty & Wellness' : cat.name),
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
          );
        },
      ),
    );
  }
}
