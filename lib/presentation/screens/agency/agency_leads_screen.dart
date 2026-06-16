import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../providers/agency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/agency_models.dart';

class AgencyLeadsScreen extends StatefulWidget {
  const AgencyLeadsScreen({super.key});

  @override
  State<AgencyLeadsScreen> createState() => _AgencyLeadsScreenState();
}

class _AgencyLeadsScreenState extends State<AgencyLeadsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgencyProvider>().fetchLeads();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgencyProvider>();
    final List<AgencyLead> leads = provider.leads;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: "Lead Pipeline".text.bold.make(),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.secondaryColor,
          labelColor: AppTheme.secondaryColor,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Contacted'),
            Tab(text: 'Closed'),
          ],
        ),
      ),
      body: provider.isLoading && leads.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeadList(leads.where((l) => l.status.toLowerCase() == 'new').toList()),
                _buildLeadList(leads.where((l) => l.status.toLowerCase() == 'contacted' || l.status.toLowerCase() == 'negotiating').toList()),
                _buildLeadList(leads.where((l) => l.status.toLowerCase() == 'closed' || l.status.toLowerCase() == 'rejected').toList()),
              ],
            ),
    );
  }

  Widget _buildLeadList(List<AgencyLead> leads) {
    if (leads.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          "No leads in this category.".text.gray400.make(),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return _buildLeadCard(lead);
      },
    );
  }

  Widget _buildLeadCard(AgencyLead lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                  child: lead.name.substring(0, 1).toUpperCase().text.bold.color(AppTheme.secondaryColor).make(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      lead.name.text.bold.lg.make(),
                      lead.property.text.sm.gray500.ellipsis.make(),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () => _showStatusPicker(lead),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    lead.time.text.xs.gray500.make(),
                  ],
                ),
                Row(
                  children: [
                    _buildActionButton(Icons.call_outlined, Colors.green, () {}),
                    const SizedBox(width: 12),
                    _buildActionButton(Icons.message_outlined, Colors.blue, () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _showStatusPicker(AgencyLead lead) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              "Update Status".text.bold.lg.make().pOnly(bottom: 16),
              _statusTile(lead, 'New', Icons.fiber_new_outlined, Colors.blue),
              _statusTile(lead, 'Contacted', Icons.phone_callback_outlined, Colors.orange),
              _statusTile(lead, 'Negotiating', Icons.handshake_outlined, Colors.purple),
              _statusTile(lead, 'Closed', Icons.check_circle_outline, Colors.green),
              _statusTile(lead, 'Rejected', Icons.cancel_outlined, Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _statusTile(AgencyLead lead, String status, IconData icon, Color color) {
    final isSelected = lead.status.toLowerCase() == status.toLowerCase();
    return ListTile(
      leading: Icon(icon, color: isSelected ? color : Colors.grey),
      title: status.text.color(isSelected ? color : Colors.black).medium.make(),
      trailing: isSelected ? Icon(Icons.check, color: color) : null,
      onTap: () async {
        Navigator.pop(context);
        final success = await context.read<AgencyProvider>().updateLeadStatus(lead.id, status);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: "Lead updated to $status".text.make(), backgroundColor: Colors.green),
          );
        }
      },
    );
  }
}
