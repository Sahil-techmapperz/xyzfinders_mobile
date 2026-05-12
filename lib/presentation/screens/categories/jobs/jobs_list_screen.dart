import 'dart:io' as io;
import '../../chats/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/product_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';
import '../../../widgets/category_search_header.dart';
import 'package:file_picker/file_picker.dart';
import '../../../widgets/favorite_toggle_button.dart';
import '../../../widgets/common/filter_bottom_sheet.dart';
import 'jobs_detail_screen.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/image_upload_service.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/auth/auth_modal.dart';
import '../../../../core/utils/date_utils.dart';

class JobsListScreen extends StatefulWidget {
  final int? categoryId;
  const JobsListScreen({super.key, this.categoryId});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  bool _isVerifiedOnly = false;
  int _currentNavIndex = 0;
  
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  // Filter State
  double? _minSalary;
  String? _selectedJobType;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _productService.getProducts(
        categoryId: widget.categoryId,
        verifiedOnly: _isVerifiedOnly,
        minSalary: _minSalary,
        jobType: _selectedJobType,
        locationSearch: _selectedLocation,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
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

  void _resetFilters() {
    setState(() {
      _isVerifiedOnly = false;
      _minSalary = null;
      _selectedJobType = null;
      _selectedLocation = null;
      _searchController.clear();
    });
    _fetchProducts();
  }

  void _showSalaryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        title: "Select Monthly Salary",
        options: const ["Under ₹10,000", "₹10,000 - ₹20,000", "₹20,000 - ₹50,000", "Above ₹50,000"],
        selectedValue: _minSalary == null ? null : (_minSalary == 10000 ? "₹10,000 - ₹20,000" : null),
        onSelected: (val) {
          setState(() {
            if (val == "Under ₹10,000") {
              _minSalary = 0;
            } else if (val == "₹10,000 - ₹20,000") {
              _minSalary = 1.2; // Backend expects LPA for min_salary? Let's check route.ts
            } else if (val == "₹20,000 - ₹50,000") {
              _minSalary = 2.4;
            } else if (val == "Above ₹50,000") {
              _minSalary = 6.0;
            } else {
              _minSalary = null;
            }
          });
          _fetchProducts();
        },
      ),
    );
  }

  void _showJobTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        title: "Select Job Type",
        options: const ["Full Time", "Part Time", "Contract", "Freelance"],
        selectedValue: _selectedJobType,
        onSelected: (val) {
          setState(() => _selectedJobType = val);
          _fetchProducts();
        },
      ),
    );
  }

  void _showLocationFilter() {
    // Simple location search for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location filter coming soon!")),
    );
  }

  void _showAllFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Advanced filters coming soon!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            CategorySearchHeader(
              prefixIcon: Icons.work_rounded,
              hintText: "Search Jobs...",
              onBack: () => Navigator.pop(context),
              controller: _searchController,
              onSubmitted: (val) => _fetchProducts(),
            ),
            _buildFilterBar(),
            _buildResultsSummary(),
            Expanded(
              child: Column(
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.user?.resumeUrl != null && auth.user!.resumeUrl!.isNotEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _buildUploadCVBanner().p16();
                    },
                  ),
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null 
                        ? Center(child: "Error: $_error".text.make())
                        : _products.isEmpty
                          ? Center(child: "No jobs found".text.make())
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                return _buildProductCard(context, _products[index]);
                              },
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          CustomBottomNavBar.handleGlobalNavigation(context, index, _currentNavIndex, false);
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
          _buildFilterChip(Icons.tune, "Filter", hasDropdown: false, isIconOnly: true).onTap(() => _showAllFilters()),
          _buildFilterChip(null, "Salary", hasDropdown: true).onTap(() => _showSalaryFilter()),
          _buildFilterChip(null, _selectedJobType ?? "Job Type", hasDropdown: true).onTap(() => _showJobTypeFilter()),
          _buildFilterChip(null, _selectedLocation ?? "Location", hasDropdown: true).onTap(() => _showLocationFilter()),
          const VerticalDivider(width: 20, indent: 8, endIndent: 8),
          "All Filters".text.semiBold.black.make().centered().px(8).onTap(() => _showAllFilters()),
          "Reset".text.gray500.make().centered().px(8).onTap(() => _resetFilters()),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData? icon, String label, {bool hasDropdown = false, bool isIconOnly = false}) {
    bool isActive = label != "Salary" && label != "Job Type" && label != "Location" && !isIconOnly;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.brown.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? Colors.brown.shade300 : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 16, color: Colors.brown).box.padding(EdgeInsets.only(right: isIconOnly ? 0 : 4)).make(),
          if (!isIconOnly) label.text.size(12).semiBold.color(isActive ? Colors.brown.shade900 : Colors.black).make(),
          if (hasDropdown) Icon(Icons.keyboard_arrow_down, size: 16, color: isActive ? Colors.brown.shade700 : Colors.grey).box.padding(const EdgeInsets.only(left: 4)).make(),
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
                  value: _isVerifiedOnly,
                  onChanged: (val) {
                    setState(() => _isVerifiedOnly = val);
                    _fetchProducts();
                  },
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

  bool _isUploadingCV = false;

  Future<void> _handleCVUpload() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 1. Check if logged in
    if (!authProvider.isAuthenticated) {
      VxToast.show(context, msg: "Please login to upload your CV", bgColor: Colors.orange);
      AuthModal.show(context);
      return;
    }

    // 2. Check if in Buyer mode
    if (authProvider.isSellerMode) {
      _showSwitchModeDialog(authProvider);
      return;
    }

    try {
        FilePickerResult? result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
        );

        if (result != null && result.files.single.path != null) {
          setState(() => _isUploadingCV = true);
          
          final file = io.File(result.files.single.path!);
          final uploadService = ImageUploadService();
          final authService = AuthService();

          // 1. Upload to ImageKit
          final resumeUrl = await uploadService.uploadToImageKit(file, prefix: 'resume');
          
          if (resumeUrl != null) {
            // 2. Update user profile
            await authService.updateResumeUrl(resumeUrl);
            
            // 3. Refresh user data in provider
            await authProvider.refreshUser();
            
            if (mounted) {
              VxToast.show(context, msg: "CV Uploaded Successfully!", bgColor: Colors.green, textColor: Colors.white);
            }
          } else {
            if (mounted) {
              VxToast.show(context, msg: "Failed to upload CV. Please try again.", bgColor: Colors.red, textColor: Colors.white);
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: "Cancel".text.color(Colors.grey).make(),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await authProvider.toggleMode();
              if (success) {
                if (mounted) {
                  VxToast.show(context, msg: "Switched to Buyer Mode", bgColor: Colors.green);
                  _handleCVUpload(); // Retry upload
                }
              } else {
                if (mounted) {
                  VxToast.show(context, msg: "Failed to switch mode", bgColor: Colors.red);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: "Switch Now".text.white.make(),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCVBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/CV-upload-img.png',
            height: 60,
            width: 60,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                "80% of the recruiters hire candidate with CV"
                    .text
                    .semiBold
                    .size(14)
                    .maxLines(2)
                    .make(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isUploadingCV ? null : _handleCVUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isUploadingCV 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : "Upload CV".text.size(12).bold.make(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel item) {
    // Extract attributes
    final attrs = item.productAttributes ?? {};
    final jobType = attrs['work_mode'] ?? attrs['job_type'] ?? 'Full-Time';
    final qualification = attrs['qualification'] ?? 'Any Degree';
    final experience = attrs['experience'] ?? '1-2 Years';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobsDetailScreen(
                productId: item.id,
                title: item.title,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (item.companyLogo != null || item.sellerAvatar != null)
                        ? CachedNetworkImage(
                            imageUrl: (item.companyLogo ?? item.sellerAvatar)!.startsWith('http')
                                ? (item.companyLogo ?? item.sellerAvatar)!
                                : (item.companyLogo != null)
                                    ? "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/product/${item.companyLogo}"
                                    : "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/user/${item.sellerAvatar}",
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(Icons.business, color: Colors.grey),
                          )
                        : const Icon(Icons.business, color: Colors.grey),
                  ),
                  const Spacer(),
                  if (item.sellerIsVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: Colors.green, size: 10),
                          const SizedBox(width: 4),
                          "VERIFIED USER".text.green700.bold.size(8).make(),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              item.title.text.bold.size(16).black.make(),
              const SizedBox(height: 2),
              (item.sellerName ?? "Company Name").text.color(Colors.blue.shade400).semiBold.size(13).make(),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  "₹ ${item.price} /Monthly".text.semiBold.size(13).gray700.make(),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _buildJobAttribute(Icons.access_time, jobType.toString()),
                  const SizedBox(width: 12),
                  _buildJobAttribute(Icons.school_outlined, qualification.toString()),
                  const SizedBox(width: 12),
                  _buildJobAttribute(Icons.business_center_outlined, experience.toString()),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.black87),
                  const SizedBox(width: 4),
                  (item.cityName ?? "New Delhi, India").text.size(12).gray600.make(),
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  AppDateUtils.timeAgo(item.createdAt).text.size(11).color(Colors.green.shade700).make(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobAttribute(IconData icon, String label) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: label.text.size(11).gray600.maxLines(1).ellipsis.make(),
          ),
        ],
      ),
    );
  }
}
