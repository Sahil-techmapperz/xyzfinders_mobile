import 'agency_post_ad_screen.dart';
import 'agency_post_ad_category_screen.dart';
import 'agency_post_ad_wizard_screen.dart';
import 'agency_ad_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/agency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/agency_models.dart';
import '../../../data/models/category_model.dart';

class AgencyMyAdsScreen extends StatefulWidget {
  const AgencyMyAdsScreen({super.key});

  @override
  State<AgencyMyAdsScreen> createState() => _AgencyMyAdsScreenState();
}

class _AgencyMyAdsScreenState extends State<AgencyMyAdsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgencyProvider>().fetchAds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgencyProvider>();
    final ads = provider.ads;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: "My Listings".text.bold.make(),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgencyPostAdCategoryScreen())),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          ),
        ],
      ),
      body: provider.isLoading && ads.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
          : RefreshIndicator(
              onRefresh: () => provider.fetchAds(),
              child: ads.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ads.length,
                    itemBuilder: (context, index) {
                      final ad = ads[index];
                      return _buildAdCard(ad);
                    },
                  ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        "No listings found.".text.gray400.make().centered(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgencyPostAdCategoryScreen())),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
          child: "Post New Ad".text.bold.make(),
        ),
      ],
    );
  }

  Widget _buildAdCard(AgencyAd ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: ad.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: ad.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(color: Colors.grey.shade100, child: const Icon(Icons.image_outlined, color: Colors.grey)),
                      )
                    : Container(color: Colors.grey.shade100, child: const Icon(Icons.image_outlined, color: Colors.grey)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => _handleStatusToggle(ad),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(ad.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ad.status.toUpperCase().text.xs.bold.color(_getStatusColor(ad.status)).make(),
                            ),
                          ),
                          "₹ ${ad.price ?? 'N/A'}".text.bold.color(AppTheme.secondaryColor).make(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ad.title.text.bold.sm.maxLines(2).ellipsis.make().expand(),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: (ad.categoryName ?? 'Other').text.xs.gray500.make(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.visibility_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          "${ad.views} Views".text.xs.gray400.make(),
                          const Spacer(),
                          ad.createdAt.text.xs.gray400.make(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCardAction(Icons.edit_outlined, 'Edit', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AgencyPostAdWizardScreen(
                    category: CategoryModel(
                      id: ad.categoryId ?? 0,
                      name: ad.categoryName ?? 'Other',
                      isFeatured: false,
                      isActive: true,
                    ),
                    ad: ad,
                  )));
                }),
                _buildCardAction(Icons.analytics_outlined, 'Stats', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AgencyAdStatsScreen(ad: ad)));
                }),
                _buildCardAction(Icons.delete_outline, 'Delete', () => _handleDelete(ad)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleStatusToggle(AgencyAd ad) async {
    final newStatus = ad.status.toLowerCase() == 'active' ? 'inactive' : 'active';
    final success = await context.read<AgencyProvider>().updateAdStatus(ad.id, newStatus);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status updated to $newStatus"), backgroundColor: Colors.green));
    }
  }

  void _handleDelete(AgencyAd ad) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Ad?"),
        content: const Text("Are you sure you want to delete this listing?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF004D40))),
      );

      final provider = context.read<AgencyProvider>();
      final success = await provider.deleteAd(ad.id);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ad deleted"), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? "Failed to delete ad"), backgroundColor: Colors.red));
        }
      }
    }
  }

  Widget _buildCardAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            label.text.xs.gray600.medium.make(),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }
}
