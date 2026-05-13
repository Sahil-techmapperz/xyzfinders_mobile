import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/product_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:xyzfinders_mobile/presentation/providers/notification_provider.dart';
import '../../notifications/notification_screen.dart';
import 'jobs_list_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import 'jobs_detail_screen.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../data/services/image_upload_service.dart';
import '../../../providers/auth_provider.dart';

class FindJobsScreen extends StatefulWidget {
  final int? categoryId;
  const FindJobsScreen({super.key, this.categoryId});

  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends State<FindJobsScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ProductModel> _popularJobs = [];
  bool _isLoadingPopular = false;

  @override
  void initState() {
    super.initState();
    _fetchPopularJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPopularJobs() async {
    setState(() => _isLoadingPopular = true);
    try {
      final response = await _productService.getProducts(
        categoryId: widget.categoryId,
        perPage: 5,
        sortBy: 'latest',
      );
      if (mounted) {
        setState(() {
          _popularJobs = List<ProductModel>.from(response['products']);
          _isLoadingPopular = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching popular jobs: $e');
      if (mounted) {
        setState(() => _isLoadingPopular = false);
      }
    }
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobsListScreen(
          categoryId: widget.categoryId,
          // You might need to update JobsListScreen to accept a search query
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF9),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _handleSearch,
                  decoration: InputDecoration(
                    hintText: "Search skills, Company or title..........",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontStyle: FontStyle.italic),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(bottom: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          _buildNotificationIcon(context),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPopularJobs,
        color: Colors.deepOrange,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: RichText(
                  text: const TextSpan(
                    text: 'Job hunting made easy with ',
                    style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
                    children: [
                      TextSpan(
                        text: 'XYZfinders',
                        style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              
              _buildSectionTitle("Popular Jobs"),
              _buildPopularJobsList(),
              
              Container(
                color: const Color(0xFFFFF9F5),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          "Job's by Category".text.xl.bold.make(),
                          InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobsListScreen(categoryId: widget.categoryId))),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: "View All".text.color(Colors.blue).size(12).semiBold.make(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildJobsByCategoryGrid(),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle("Jobs by Qualification in India"),
              _buildJobsByQualificationGrid(),
              
              const SizedBox(height: 24),
              _buildSectionTitle("Jobs by Type in India"),
              _buildJobsByTypeGrid(),
              
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.user?.resumeUrl != null && auth.user!.resumeUrl!.isNotEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _buildUploadCVBanner(auth);
                },
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: title.text.xl.bold.make(),
    );
  }

  Widget _buildPopularJobsList() {
    if (_isLoadingPopular) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_popularJobs.isEmpty) {
      // Fallback to dummy data if no jobs found
      return _buildDummyPopularJobs();
    }

    return SizedBox(
      height: 165,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _popularJobs.length,
        itemBuilder: (context, index) {
          final job = _popularJobs[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (job.companyLogo != null || job.sellerAvatar != null)
                          ? CachedNetworkImage(
                              imageUrl: (job.companyLogo ?? job.sellerAvatar)!.startsWith('http')
                                  ? (job.companyLogo ?? job.sellerAvatar)!
                                  : (job.companyLogo != null)
                                      ? "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/product/${job.companyLogo}"
                                      : "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/user/${job.sellerAvatar}",
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(Icons.business_center, color: Colors.blue, size: 24),
                            )
                          : const Icon(Icons.business_center, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (job.sellerName ?? "Company").text.color(Colors.blue).size(12).semiBold.make(),
                          const SizedBox(height: 2),
                          job.title.text.semiBold.size(15).maxLines(1).ellipsis.make(),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    "Full-time".text.color(Colors.grey.shade600).size(12).make(),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    "${CurrencyUtils.formatIndianCurrency(job.price)} / Monthly".text.color(AppTheme.secondaryColor).semiBold.size(12).make(),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    (job.cityName ?? "India").text.color(Colors.grey.shade600).size(12).make(),
                  ],
                ),
              ],
            ),
          ).onTap(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobsDetailScreen(
                  productId: job.id!,
                  title: job.title,
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildDummyPopularJobs() {
    final dummyJobs = [
      {"company": "Bluestech LLP", "title": "Sales Marketing Executive", "salary": "10,000 - 15,000/Monthly", "type": "Full-time"},
      {"company": "TCS", "title": "Sales Marketing Manager", "salary": "7.2 - 8.3 LPA", "type": "Full-time"},
      {"company": "Wipro", "title": "Business Development", "salary": "25,000 - 35,000/Monthly", "type": "Full-time"},
    ];

    return SizedBox(
      height: 165,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: dummyJobs.length,
        itemBuilder: (context, index) {
          final job = dummyJobs[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Colors.orange.shade50 : Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        index % 2 == 0 ? Icons.business_center : Icons.auto_awesome,
                        color: index % 2 == 0 ? Colors.orange : Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          job['company']!.text.color(Colors.blue).size(12).semiBold.make(),
                          const SizedBox(height: 2),
                          job['title']!.text.semiBold.size(15).make(),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    job['type']!.text.color(Colors.grey.shade600).size(12).make(),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    job['salary']!.text.color(Colors.grey.shade600).size(12).make(),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    "New Delhi, India".text.color(Colors.grey.shade600).size(12).make(),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobsByCategoryGrid() {
    final categories = [
      {
        "title": "Accounts/Finance Jobs", 
        "count": "+561", 
        "image": "https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&q=80", 
        "color": Colors.blue
      },
      {
        "title": "Real Estate Jobs", 
        "count": "+56", 
        "image": "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=400&q=80", 
        "color": Colors.green
      },
      {
        "title": "Full Stack Developer", 
        "count": "+856", 
        "image": "https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400&q=80", 
        "color": Colors.orange
      },
      {
        "title": "Sales Executive Jobs", 
        "count": "+561", 
        "image": "https://images.unsplash.com/photo-1557804506-669a67965ba0?w=400&q=80", 
        "color": Colors.purple
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => JobsListScreen(categoryId: widget.categoryId)));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(cat['image'] as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (index == 3) // Add a "Sales" badge as in screenshot
                          Positioned(
                            top: 8,
                            right: 8,
                            child: "SALES".text.white.size(10).bold.make().box.color(Colors.blue).px4.make(),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cat['title'].toString().text.semiBold.size(13).maxLines(2).ellipsis.make(),
                      const SizedBox(height: 4),
                      "(${cat['count']})".text.color(Colors.grey).size(11).make(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobsByQualificationGrid() {
    final qualifications = [
      {"title": "High School", "count": "+561 jobs", "icon": Icons.menu_book},
      {"title": "Bachelors Degree", "count": "+56", "icon": Icons.school},
      {"title": "Master's Degree", "count": "+856", "icon": Icons.workspace_premium},
      {"title": "PhD", "count": "+561", "icon": Icons.account_balance},
    ];

    return _buildIconGrid(qualifications, isQualification: true);
  }

  Widget _buildJobsByTypeGrid() {
    final types = [
      {"title": "Full-Time", "count": "+561 jobs", "icon": Icons.access_time},
      {"title": "Part-Time", "count": "+56", "icon": Icons.update},
      {"title": "Contract", "count": "+856", "icon": Icons.assignment},
      {"title": "Remote", "count": "+561", "icon": Icons.home_work},
    ];

    return _buildIconGrid(types, isQualification: false);
  }

  Widget _buildIconGrid(List<Map<String, dynamic>> items, {required bool isQualification}) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => JobsListScreen(categoryId: widget.categoryId)));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'] as IconData, color: Colors.deepOrange.shade400, size: 36),
                const SizedBox(height: 12),
                item['title'].toString().text.semiBold.size(14).make(),
                const SizedBox(height: 4),
                "(${item['count']})".text.color(Colors.grey).size(11).make(),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isUploadingCV = false;

  Future<void> _handleCVUpload(AuthProvider authProvider) async {
    // 1. Check if logged in
    if (!authProvider.isAuthenticated) {
      VxToast.show(context, msg: "Please login to upload your CV", bgColor: Colors.orange);
      // You might need to trigger login here
      return;
    }

    // 2. Check if in Buyer mode
    if (authProvider.isSellerMode) {
      _showSwitchModeDialog(authProvider);
      return;
    }

    try {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
        );

        if (result != null && result.files.single.path != null) {
          setState(() => _isUploadingCV = true);
          
          final file = File(result.files.single.path!);
          final uploadService = ImageUploadService();

          final resumeUrl = await uploadService.uploadToImageKit(file, prefix: 'resume');
          
          if (resumeUrl != null) {
            await authProvider.updateResumeUrl(resumeUrl);
            if (mounted) {
              VxToast.show(context, msg: "CV Uploaded Successfully!", bgColor: Colors.green, textColor: Colors.white);
            }
          }
        }
    } catch (e) {
      if (mounted) {
        VxToast.show(context, msg: "Error: ${e.toString()}", bgColor: Colors.red, textColor: Colors.white);
      }
    } finally {
      if (mounted) setState(() => _isUploadingCV = false);
    }
  }

  void _showSwitchModeDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: "Switch to Buyer Mode".text.bold.make(),
        content: "To upload your CV and apply for jobs, you need to be in Buyer Mode. Would you like to switch now?".text.make(),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: "Cancel".text.make()),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.toggleMode();
              _handleCVUpload(authProvider);
            },
            child: "Switch Now".text.white.make(),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCVBanner(AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/CV-upload-img.png',
            height: 50,
            width: 50,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: "80% of the recruiters hire candidate with CV"
                .text
                .semiBold
                .size(13)
                .maxLines(2)
                .make(),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isUploadingCV ? null : () => _handleCVUpload(authProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isUploadingCV 
              ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : "Upload CV".text.size(12).bold.make(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return InkWell(
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
                  size: 26,
                  color: Colors.black87,
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
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        provider.unreadCount > 9 ? '9+' : provider.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
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
    );
  }
}
