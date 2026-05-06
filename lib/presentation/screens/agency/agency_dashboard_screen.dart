import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/agency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/agency_models.dart';
import 'agency_leads_screen.dart';
import 'agency_agents_screen.dart';
import 'agency_my_ads_screen.dart';
import 'agency_profile_screen.dart';
import 'agency_messages_screen.dart';
import 'agency_support_screen.dart';
import 'agency_login_screen.dart';
import 'agency_post_ad_category_screen.dart';
import '../auth/login_screen.dart';
import '../../providers/auth_provider.dart';

class AgencyDashboardScreen extends StatefulWidget {
  const AgencyDashboardScreen({super.key});

  @override
  State<AgencyDashboardScreen> createState() => _AgencyDashboardScreenState();
}

class _AgencyDashboardScreenState extends State<AgencyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgencyProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgencyProvider>();
    final user = provider.agencyUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildDrawer(context, provider),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchDashboard(),
        color: AppTheme.secondaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context, user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.isLoading && provider.stats == null)
                      const Center(child: CircularProgressIndicator()).pSymmetric(v: 40)
                    else if (provider.error != null && provider.stats == null)
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(provider.error!, textAlign: TextAlign.center),
                            TextButton(onPressed: () => provider.fetchDashboard(), child: const Text('Retry')),
                          ],
                        ),
                      ).pSymmetric(v: 40)
                    else if (provider.stats != null) ...[
                      _buildStatsGrid(provider.stats!),
                      const SizedBox(height: 32),
                      _buildQuickActions(context),
                      const SizedBox(height: 32),
                      _buildEngagementChart(provider.stats!),
                      const SizedBox(height: 32),
                      _buildRecentLeads(context, provider.stats!),
                      const SizedBox(height: 40),
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

  Widget _buildAppBar(BuildContext context, AgencyUser? user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF111827),
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "Agency Portal".text.xs.color(AppTheme.secondaryColor).make(),
            (user?.agencyName ?? 'Agency').text.bold.lg.white.make(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(AgencyDashboardStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Active Ads', stats.activeAds.toString(), Icons.campaign_rounded, Colors.blue),
        _buildStatCard('Total Views', stats.totalViews.toString(), Icons.visibility_rounded, Colors.orange),
        _buildStatCard('Pipeline Leads', stats.pipelineLeads.toString(), Icons.analytics_rounded, Colors.purple),
        _buildStatCard('Team Agents', stats.teamAgents.toString(), Icons.group_rounded, Colors.green),
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
            color: color.withOpacity(0.08),
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
              color: color.withOpacity(0.1),
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
        "Agency Management".text.bold.lg.color(const Color(0xFF1E293B)).make(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem('My Ads', Icons.list_alt_rounded, Colors.blue, () => _navTo(context, const AgencyMyAdsScreen())),
            _buildActionItem('Leads', Icons.trending_up_rounded, Colors.orange, () => _navTo(context, const AgencyLeadsScreen())),
            _buildActionItem('Agents', Icons.people_outline_rounded, Colors.green, () => _navTo(context, const AgencyAgentsScreen())),
            _buildActionItem('Support', Icons.headset_mic_outlined, Colors.purple, () => _navTo(context, const AgencySupportScreen())),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          title.text.bold.xs.gray600.make(),
        ],
      ),
    );
  }

  Widget _buildEngagementChart(AgencyDashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "Engagement Over Time".text.bold.lg.color(const Color(0xFF1E293B)).make(),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 20,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < stats.chartData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            stats.chartData[value.toInt()].name.substring(0, 3),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: stats.chartData.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.leads.toDouble(),
                      color: AppTheme.secondaryColor,
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: entry.value.views.toDouble() / 10, // Scale views down for visibility
                      color: Colors.blue.shade200,
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Leads', AppTheme.secondaryColor),
            const SizedBox(width: 24),
            _buildLegendItem('Views (x10)', Colors.blue.shade200),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        label.text.xs.gray500.make(),
      ],
    );
  }

  Widget _buildRecentLeads(BuildContext context, AgencyDashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            "Recent Leads".text.bold.lg.color(const Color(0xFF1E293B)).make(),
            TextButton(
              onPressed: () => _navTo(context, const AgencyLeadsScreen()),
              child: "View Pipeline".text.color(AppTheme.secondaryColor).bold.sm.make(),
            ),
          ],
        ),
        if (stats.recentLeads.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: "No recent leads found.".text.gray400.center.make().centered(),
          )
        else
          ...stats.recentLeads.map((lead) => _buildLeadTile(lead)),
      ],
    );
  }

  Widget _buildLeadTile(AgencyLead lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
            child: lead.name.isNotEmpty 
              ? lead.name.substring(0, 1).toUpperCase().text.color(AppTheme.secondaryColor).bold.make()
              : const Icon(Icons.person, color: AppTheme.secondaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                lead.name.text.bold.make(),
                lead.property.text.xs.gray500.ellipsis.make(),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(lead.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: lead.status.text.xs.bold.color(_getStatusColor(lead.status)).make(),
              ),
              const SizedBox(height: 4),
              lead.time.text.xs.gray400.make(),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new': return Colors.blue;
      case 'contacted': return Colors.orange;
      case 'closed': return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildDrawer(BuildContext context, AgencyProvider provider) {
    final user = provider.agencyUser;
    final profile = provider.profile;
    final logoUrl = profile?.logoUrl;

    return Drawer(
      backgroundColor: const Color(0xFF111827),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1F2937)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.secondaryColor,
              backgroundImage: (logoUrl != null && logoUrl.isNotEmpty)
                  ? CachedNetworkImageProvider(logoUrl)
                  : null,
              child: (logoUrl == null || logoUrl.isEmpty)
                  ? (user?.agencyName ?? 'A').substring(0, 1).toUpperCase().text.white.bold.xl.make()
                  : null,
            ),
            accountName: (user?.agencyName ?? 'Agency Account').text.bold.make(),
            accountEmail: (user?.email ?? '').text.xs.make(),
          ),
          _buildDrawerItem(Icons.dashboard_rounded, 'Dashboard', () => Navigator.pop(context)),
          _buildDrawerItem(Icons.list_alt_rounded, 'My Ads', () => _navTo(context, const AgencyMyAdsScreen())),
          _buildDrawerItem(Icons.add_circle_outline_rounded, 'Post Ad', () => _navTo(context, const AgencyPostAdCategoryScreen())),
          _buildDrawerItem(Icons.trending_up_rounded, 'Leads Pipeline', () => _navTo(context, const AgencyLeadsScreen())),
          _buildDrawerItem(Icons.forum_outlined, 'Messages', () => _navTo(context, const AgencyMessagesScreen())),
          _buildDrawerItem(Icons.people_outline_rounded, 'Team Agents', () => _navTo(context, const AgencyAgentsScreen())),
          _buildDrawerItem(Icons.settings_outlined, 'Settings', () => _navTo(context, const AgencyProfileScreen())),
          _buildDrawerItem(Icons.headset_mic_outlined, 'Support', () => _navTo(context, const AgencySupportScreen())),
          const Spacer(),
          const Divider(color: Colors.white24),
          _buildDrawerItem(Icons.logout_rounded, 'Logout', () {
            context.read<AgencyProvider>().logout();
            context.read<AuthProvider>().logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AgencyLoginScreen()),
              (route) => false,
            );
          }, color: Colors.redAccent),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color.withOpacity(0.7)),
      title: title.text.color(color).make(),
      onTap: onTap,
    );
  }

  void _navTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer if open
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
