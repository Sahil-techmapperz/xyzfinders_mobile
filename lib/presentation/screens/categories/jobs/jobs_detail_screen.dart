import '../../../widgets/share_button.dart';
import '../../chats/chat_screen.dart';
import '../../../widgets/auth/auth_modal.dart';
import 'job_apply_form_screen.dart';
import '../../../providers/auth_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../providers/product_provider.dart';
import '../../../../data/models/product_model.dart';
import '../../../widgets/favorite_toggle_button.dart';

class JobsDetailScreen extends StatefulWidget {
  final int productId;
  final String? title;

  const JobsDetailScreen({
    super.key,
    required this.productId,
    this.title,
  });

  @override
  State<JobsDetailScreen> createState() => _JobsDetailScreenState();
}

class _JobsDetailScreenState extends State<JobsDetailScreen> {
  int _activeImageIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showStickyButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProductDetail(widget.productId);
    });
  }

  void _scrollListener() {
    // Show sticky button only after scrolling past the first apply button (approx 420 pixels)
    if (_scrollController.offset > 420 && !_showStickyButton) {
      setState(() => _showStickyButton = true);
    } else if (_scrollController.offset <= 420 && _showStickyButton) {
      setState(() => _showStickyButton = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleApply(ProductModel product) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobApplyFormScreen(
            jobId: product.id,
            jobTitle: product.title,
          ),
        ),
      );
    } else {
      AuthModal.show(context);
    }
  }

  Widget _buildProductImage(String? imageVal, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    if (imageVal == null || imageVal.isEmpty) {
      return Container(
        height: height,
        width: width,
        color: Colors.grey.shade200,
        child: const Icon(Icons.work, color: Colors.grey),
      );
    }

    if (imageVal.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageVal,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Container(color: Colors.grey.shade100),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }

    try {
      return Image.memory(
        base64Decode(imageVal),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    } catch (e) {
      return const Icon(Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.selectedProduct == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final product = provider.selectedProduct;
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title ?? "Job Detail")),
            body: Center(child: (provider.error ?? "Job listing not found").text.make()),
          );
        }

        final attrs = product.productAttributes ?? {};
        final specs = attrs['specs'] as Map<String, dynamic>? ?? {};
        
        final jobType = attrs['work_mode'] ?? attrs['job_type'] ?? 'Full-Time';
        final qualification = attrs['qualification'] ?? 'Graduation/Post-Graduation';
        final experience = attrs['experience'] ?? '2-4 Years';
        final candidate = attrs['candidate_type'] ?? 'Any Candidate';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: "Job Profile".text.semiBold.black.make(),
            centerTitle: true,
            actions: [
              _buildNotificationIcon(context),
              const SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: (product.companyLogo != null || (product.agencyId != null && product.sellerAvatar != null))
                                      ? CachedNetworkImage(
                                          imageUrl: (product.companyLogo ?? product.sellerAvatar)!.startsWith('http')
                                              ? (product.companyLogo ?? product.sellerAvatar)!
                                              : (product.companyLogo != null)
                                                  ? "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/product/${product.companyLogo}"
                                                  : "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/user/${product.sellerAvatar}",
                                          fit: BoxFit.contain,
                                          errorWidget: (context, url, error) => const Icon(Icons.business, size: 40, color: Colors.grey),
                                        )
                                      : const Icon(Icons.business, size: 40, color: Colors.grey),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    FavoriteToggleButton(product: product, iconSize: 24),
                                    const SizedBox(width: 12),
                                    ShareButton(product: product, iconSize: 24),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            product.title.toUpperCase().text.xl.bold.black.make(),
                            const SizedBox(height: 4),
                            (product.sellerName ?? "Company Name").text.xl.color(Colors.blue.shade400).semiBold.make(),
                            const SizedBox(height: 24),
                            
                            _buildInfoRow(Icons.payments_outlined, "₹ ${product.price} - ${product.price + 5000}/-"),
                            _buildInfoRow(Icons.location_on_outlined, "${product.locationName ?? product.cityName ?? 'Gurgaon, Sector 62, New Delhi'}, India"),
                            _buildInfoRow(Icons.access_time, jobType.toString()),
                            _buildInfoRow(Icons.business_center_outlined, experience.toString()),
                            _buildInfoRow(Icons.person_outline, candidate.toString()),
                            _buildInfoRow(Icons.school_outlined, qualification.toString()),
                            
                            const SizedBox(height: 24),
                            if (!_showStickyButton)
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () => _handleApply(product),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFE8F5B),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: "APPLY".text.xl.bold.make(),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                "440 Applicants".text.size(11).semiBold.gray700.make(),
                                const SizedBox(width: 12),
                                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                "Posted On 3hr Ago".text.size(11).color(Colors.green.shade600).semiBold.make(),
                              ],
                            ),
                            
                            const Divider(height: 48),
                            "Job Details".text.xl.bold.make(),
                            const SizedBox(height: 12),
                            product.description.text.size(13).gray700.lineHeight(1.5).make(),
                            
                            const SizedBox(height: 24),
                            "Key Responsibilities".text.semiBold.make(),
                            const SizedBox(height: 8),
                            _buildBulletList([
                              "Plan, manage, and optimize social media marketing across LinkedIn, Instagram, and Facebook.",
                              "Support SEO and SEM activities, including keyword research and on-page optimisation.",
                              "Track, analyse, and report performance using Google Analytics and platform insights.",
                            ]),
                            
                            const SizedBox(height: 24),
                            "Benefits".text.semiBold.make(),
                            const SizedBox(height: 8),
                            _buildBulletList([
                              "Cell Phone Reimbursement",
                              "Commuter Assistance",
                              "Health Insurance",
                              "Internet Reimbursement",
                            ]),
                            
                            const SizedBox(height: 32),
                            _buildHiredFasterBox(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showStickyButton) _buildStickyBottomBar(product),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(width: 16),
          Expanded(
            child: label.text.size(15).gray700.medium.make(),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "• ".text.xl.make(),
            Expanded(
              child: item.text.size(13).gray700.make(),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildHiredFasterBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5FE).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.lightBlue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          "6 Step to get hired faster.".text.bold.size(15).make(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                "Add Basic Info....".text.size(13).medium.make(),
                const Spacer(),
                const Icon(Icons.add_circle_outline, color: Colors.blue, size: 24),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index == 0 ? Colors.grey.shade700 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.notifications_none, color: Colors.black87, size: 28),
          Positioned(
            right: 0,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: "6+".text.white.size(8).bold.make().centered(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => _handleApply(product),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE8F5B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: "APPLY NOW".text.xl.bold.make(),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
