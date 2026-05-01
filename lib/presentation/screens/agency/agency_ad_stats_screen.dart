import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/agency_provider.dart';
import '../../../data/models/agency_models.dart';
import '../../../core/theme/app_theme.dart';

class AgencyAdStatsScreen extends StatefulWidget {
  final AgencyAd ad;
  const AgencyAdStatsScreen({super.key, required this.ad});

  @override
  State<AgencyAdStatsScreen> createState() => _AgencyAdStatsScreenState();
}

class _AgencyAdStatsScreenState extends State<AgencyAdStatsScreen> {
  bool _isLoading = true;
  AgencyDashboardStats? _stats;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStats();
    });
  }

  Future<void> _fetchStats() async {
    final provider = context.read<AgencyProvider>();
    final stats = await provider.fetchAdAnalytics(widget.ad.id);
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: "Ad Performance".text.bold.make(),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF004D40)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAdSummary(),
                  const SizedBox(height: 24),
                  "Performance Overview".text.xl.bold.color(const Color(0xFF1E293B)).make(),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  "Engagement Trend".text.xl.bold.color(const Color(0xFF1E293B)).make(),
                  const SizedBox(height: 16),
                  _buildChart(),
                  const SizedBox(height: 24),
                  _buildRecentLeads(),
                ],
              ),
            ),
    );
  }

  Widget _buildAdSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              image: widget.ad.imageUrl != null
                  ? DecorationImage(image: NetworkImage(widget.ad.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: widget.ad.imageUrl == null ? const Icon(Icons.image_outlined, color: Colors.grey) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.ad.title.text.bold.lg.maxLines(1).ellipsis.make(),
                const SizedBox(height: 4),
                "Posted on ${widget.ad.createdAt.split('T').first}".text.sm.gray400.make(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.ad.status.toLowerCase() == 'active' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.ad.status.toUpperCase().text.xs.bold.color(widget.ad.status.toLowerCase() == 'active' ? Colors.green : Colors.orange).make(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard("Total Views", (_stats?.totalViews ?? widget.ad.views).toString(), Icons.visibility_outlined, Colors.blue),
        _buildStatCard("New Leads", (_stats?.pipelineLeads ?? 0).toString(), Icons.person_outline, Colors.orange),
        _buildStatCard("Click Rate", "4.2%", Icons.mouse_outlined, Colors.purple),
        _buildStatCard("Active Time", "12 Days", Icons.timer_outlined, Colors.teal),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              label.text.xs.gray500.make(),
            ],
          ),
          value.text.xl2.bold.make(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_stats == null || _stats!.chartData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text("No trend data available")),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _stats!.chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.views.toDouble())).toList(),
              isCurved: true,
              color: const Color(0xFF004D40),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF004D40).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLeads() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            "Recent Inquiries".text.xl.bold.color(const Color(0xFF1E293B)).make(),
            "View All".text.color(const Color(0xFF004D40)).bold.make(),
          ],
        ),
        const SizedBox(height: 16),
        if (_stats == null || _stats!.recentLeads.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: "No recent inquiries for this ad.".text.gray400.center.make().centered(),
          )
        else
          ..._stats!.recentLeads.take(3).map((lead) => _buildLeadTile(lead)),
      ],
    );
  }

  Widget _buildLeadTile(AgencyLead lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF004D40).withOpacity(0.1),
            child: lead.name[0].text.color(const Color(0xFF004D40)).bold.make(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                lead.name.text.bold.make(),
                lead.status.text.xs.gray500.make(),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
