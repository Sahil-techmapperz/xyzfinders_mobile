import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../providers/agency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/agency_models.dart';

class AgencyAgentsScreen extends StatefulWidget {
  const AgencyAgentsScreen({super.key});

  @override
  State<AgencyAgentsScreen> createState() => _AgencyAgentsScreenState();
}

class _AgencyAgentsScreenState extends State<AgencyAgentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgencyProvider>().fetchAgents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgencyProvider>();
    final agents = provider.agents;
    final isOwner = provider.agencyUser?.isOwner ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: "Team Management".text.bold.make(),
        backgroundColor: AppTheme.primaryColor,
      ),
      floatingActionButton: isOwner ? FloatingActionButton(
        onPressed: () => _showAddAgentDialog(context),
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ) : null,
      body: provider.isLoading && agents.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
          : RefreshIndicator(
              onRefresh: () => provider.fetchAgents(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  final agent = agents[index];
                  return _buildAgentCard(context, agent, isOwner);
                },
              ),
            ),
    );
  }

  Widget _buildAgentCard(BuildContext context, AgencyAgent agent, bool isOwner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: agent.name.substring(0, 1).toUpperCase().text.bold.color(AppTheme.primaryColor).make(),
        ),
        title: agent.name.text.bold.make(),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            agent.email.text.xs.gray500.make(),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: agent.role.text.xs.blue500.bold.make(),
                ),
                const SizedBox(width: 8),
                "${agent.activeListings} Active Listings".text.xs.gray400.make(),
              ],
            ),
          ],
        ),
        trailing: isOwner ? IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmDelete(context, agent),
        ) : null,
      ),
    );
  }

  void _confirmDelete(BuildContext context, AgencyAgent agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: "Remove Agent?".text.bold.make(),
        content: "Are you sure you want to remove ${agent.name} from your team? This action cannot be undone.".text.make(),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: "Cancel".text.make()),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<AgencyProvider>().deleteAgent(agent.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: "Agent removed".text.make(), backgroundColor: Colors.redAccent),
                );
              }
            },
            child: "Remove".text.color(Colors.redAccent).bold.make(),
          ),
        ],
      ),
    );
  }

  void _showAddAgentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String role = 'Agent';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "Invite Team Member".text.bold.xl2.make(),
            "They will receive an email to join your agency.".text.xs.gray500.make().pOnly(bottom: 24),
            
            TextField(controller: nameController, decoration: const InputDecoration(hintText: "Full Name")),
            const SizedBox(height: 16),
            TextField(controller: emailController, decoration: const InputDecoration(hintText: "Email Address")),
            const SizedBox(height: 16),
            TextField(controller: passwordController, decoration: const InputDecoration(hintText: "Temporary Password")),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(hintText: "Role"),
              items: ['Agent', 'Manager'].map((r) => DropdownMenuItem(value: r, child: r.text.make())).toList(),
              onChanged: (v) => role = v!,
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await context.read<AgencyProvider>().addAgent({
                    'name': nameController.text,
                    'email': emailController.text,
                    'password': passwordController.text,
                    'role': role,
                  });
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: "Invitation sent!".text.make(), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
                child: "Send Invitation".text.bold.make(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
