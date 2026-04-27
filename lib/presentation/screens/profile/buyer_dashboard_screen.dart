import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/buyer_dashboard_stats.dart';
import '../../../data/services/buyer_service.dart';
import '../wishlist/wishlist_screen.dart';
import 'job_applications_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../chats/chat_list_screen.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  final BuyerService _buyerService = BuyerService();
  BuyerDashboardStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _buyerService.getDashboardStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(user?.name ?? 'Buyer'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()).pSymmetric(v: 40)
                    else if (_error != null)
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            _error!.text.center.make(),
                            TextButton(onPressed: _loadDashboardData, child: "Retry".text.make()),
                          ],
                        ),
                      ).pSymmetric(v: 40)
                    else if (_stats != null) ...[
                      _buildWelcomeCard(user?.name ?? 'Buyer'),
                      const SizedBox(height: 24),
                      _buildStatsGrid(),
                      const SizedBox(height: 32),
                      _buildRecentActivity(),
                      const SizedBox(height: 32),
                      _buildQuickActions(),
                      const SizedBox(height: 32),
                      _buildRecommendedSection(),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 4, // Profile/Menu index
        isSellerMode: auth.isSellerMode,
        onItemSelected: (index) {
          if (index == 4) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      floatingActionButton: CustomFab(
        isSellerMode: auth.isSellerMode,
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppBar(String name) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: "My Dashboard".text.bold.color(const Color(0xFF1E293B)).make(),
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "Welcome back,".text.color(Colors.white.withValues(alpha: 0.8)).make(),
                  name.text.white.bold.xl2.make(),
                ],
              ),
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleInfo("Wishlist Value", "₹ ${_stats!.wishlistValue.toStringAsFixed(0)}"),
              _buildSimpleInfo("Price Drops", "${_stats!.priceDrops} Items"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.text.color(Colors.white.withValues(alpha: 0.7)).xs.make(),
        value.text.white.bold.lg.make(),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Wishlist', _stats!.wishlistCount.toString(), Icons.favorite, Colors.pink)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Price Drop', _stats!.priceDrops.toString(), Icons.trending_down, Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Applied', _stats!.applicationsCount.toString(), Icons.work, Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Chats', _stats!.unreadMessages.toString(), Icons.forum, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          value.text.bold.xl.color(const Color(0xFF1E293B)).make(),
          title.text.xs.gray400.make(),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            "Recent Activity".text.bold.lg.make(),
            "View Timeline".text.xs.color(AppTheme.primaryColor).make(),
          ],
        ),
        const SizedBox(height: 16),
        if (_stats!.recentActivity.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: "No recent activity found.".text.gray400.italic.center.make().wFull(context),
          )
        else
          ..._stats!.recentActivity.map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildActivityItem(BuyerActivity activity) {
    IconData icon;
    Color color;

    switch (activity.type) {
      case 'application':
        icon = Icons.work_outline;
        color = Colors.blue;
        break;
      case 'wishlist':
        icon = Icons.favorite_border;
        color = Colors.pink;
        break;
      default:
        icon = Icons.notifications_none;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                activity.itemTitle.text.bold.sm.maxLines(1).ellipsis.make(),
                activity.detail.text.xs.gray500.make(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _formatTime(activity.createdAt).text.xs.gray400.make(),
        ],
      ),
    );
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return "";
    }
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "Jump To".text.bold.lg.make(),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionTile('My Wishlist', Icons.favorite_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()))),
              _buildActionTile('Job Center', Icons.business_center_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobApplicationsScreen()))),
              _buildActionTile('Messages', Icons.forum_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()))),
              _buildActionTile('Search', Icons.search_rounded, () => {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            title.text.bold.xs.make(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "Handpicked for You".text.bold.lg.make(),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _stats!.recommendedProducts.length,
            itemBuilder: (context, index) {
              final product = _stats!.recommendedProducts[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: product.thumbnail != null
                            ? CachedNetworkImage(
                                imageUrl: product.thumbnail!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade50,
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade50,
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade50,
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          product.title.text.bold.xs.maxLines(2).ellipsis.make().h(30),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              "₹ ${product.price}".text.bold.color(AppTheme.primaryColor).sm.make(),
                              const Icon(Icons.favorite_border, size: 14, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
