import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/seller_dashboard_stats.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/seller_service.dart';
import '../seller/my_products_screen.dart';
import '../seller/seller_reports_screen.dart';
import '../seller/my_job_posts_screen.dart';
import '../ads/post_ad_category_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final SellerService _sellerService = SellerService();
  SellerDashboardStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _sellerService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context, user?.name ?? 'Seller'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                            Text(_error!, textAlign: TextAlign.center),
                            TextButton(onPressed: _loadDashboardData, child: const Text('Retry')),
                          ],
                        ),
                      ).pSymmetric(v: 40)
                    else if (_stats != null) ...[
                      _buildStatsGrid(),
                      const SizedBox(height: 32),
                      _buildQuickActions(context),
                      const SizedBox(height: 32),
                      _buildRecentPerformance(),
                      const SizedBox(height: 32),
                      _buildRecentAds(),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "Welcome back,".text.xs.white.make(),
            name.text.bold.xl.white.make(),
          ],
        ),
        background: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Active Ads', _stats!.activeAds.toString(), Icons.campaign_rounded, Colors.blue),
        _buildStatCard('Total Views', _stats!.totalViews.toString(), Icons.visibility_rounded, Colors.purple),
        _buildStatCard('Job Applicants', _stats!.totalApplicants.toString(), Icons.people_alt_rounded, Colors.green),
        _buildStatCard('Unread Chats', _stats!.unreadMessages.toString(), Icons.chat_bubble_rounded, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              value.text.bold.xl2.color(const Color(0xFF1E293B)).make(),
              title.text.xs.gray500.make(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "Business Tools".text.bold.lg.color(const Color(0xFF1E293B)).make(),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionItem(
                'Post Ad', 
                Icons.add_circle_outline, 
                AppTheme.primaryColor,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostAdCategoryScreen())),
              ),
              _buildActionItem(
                'Inventory', 
                Icons.inventory_2_outlined, 
                Colors.indigo,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProductsScreen())),
              ),
              _buildActionItem(
                'Reports', 
                Icons.report_gmailerrorred_outlined, 
                Colors.redAccent,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerReportsScreen())),
              ),
              _buildActionItem(
                'Jobs', 
                Icons.work_outline, 
                Colors.teal,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyJobPostsScreen())),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            title.text.bold.xs.make(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            "Recent Performance".text.bold.lg.color(const Color(0xFF1E293B)).make(),
            "Last 7 Days".text.xs.gray400.make(),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50.withValues(alpha: 0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('Views', '+12%', true),
                  _buildMiniStat('Leads', '+5%', true),
                  _buildMiniStat('Conversion', '-2%', false),
                ],
              ),
              const SizedBox(height: 20),
              // Simulating a simple bar chart with Containers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(30), _buildBar(50), _buildBar(40), _buildBar(80), 
                  _buildBar(60), _buildBar(90), _buildBar(70),
                ],
              ).h(100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String change, bool isPositive) {
    return Column(
      children: [
        label.text.xs.gray500.make(),
        change.text.bold.sm.color(isPositive ? Colors.green : Colors.red).make(),
      ],
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: height / 100),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildRecentAds() {
    if (_stats!.recentProducts.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            "Latest Listings".text.bold.lg.color(const Color(0xFF1E293B)).make(),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProductsScreen())),
              child: "See All".text.color(AppTheme.primaryColor).bold.sm.make(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._stats!.recentProducts.map((product) => _buildRecentAdCard(product)),
      ],
    );
  }

  Widget _buildRecentAdCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                product.title.toString().text.bold.sm.maxLines(1).ellipsis.make(),
                "${product.viewsCount} views".text.xs.gray400.make(),
              ],
            ),
          ),
          "\$${product.price}".text.bold.color(AppTheme.primaryColor).make(),
        ],
      ),
    );
  }
}
