import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../providers/agency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/agency_models.dart';

class AgencySupportScreen extends StatefulWidget {
  const AgencySupportScreen({super.key});

  @override
  State<AgencySupportScreen> createState() => _AgencySupportScreenState();
}

class _AgencySupportScreenState extends State<AgencySupportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgencyProvider>().fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgencyProvider>();
    final tickets = provider.tickets;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: "Agency Support".text.bold.make(),
        backgroundColor: AppTheme.primaryColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketDialog(context),
        backgroundColor: AppTheme.secondaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: "New Ticket".text.white.bold.make(),
      ),
      body: provider.isLoading && tickets.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
          : RefreshIndicator(
              onRefresh: () => provider.fetchTickets(),
              child: tickets.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return _buildTicketCard(ticket);
                    },
                  ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.support_agent_rounded, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        "Need help? Create a support ticket.".text.gray400.make().centered(),
      ],
    );
  }

  Widget _buildTicketCard(AgencySupportTicket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ticket.title.text.bold.make(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(ticket.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ticket.status.toUpperCase().text.xs.bold.color(_getStatusColor(ticket.status)).make(),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ticket.description.text.xs.gray500.maxLines(2).ellipsis.make(),
            const SizedBox(height: 12),
            ticket.createdAt.text.xs.gray400.make(),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.blue;
      case 'in progress': return Colors.orange;
      case 'resolved': return Colors.green;
      case 'closed': return Colors.grey;
      default: return Colors.blue;
    }
  }

  void _showCreateTicketDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

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
            "Create Support Ticket".text.bold.xl2.make(),
            "Describe the issue you're facing.".text.xs.gray500.make().pOnly(bottom: 24),
            
            TextField(controller: titleController, decoration: const InputDecoration(hintText: "Ticket Title")),
            const SizedBox(height: 16),
            TextField(controller: descController, maxLines: 4, decoration: const InputDecoration(hintText: "Description")),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty || descController.text.isEmpty) return;
                  final success = await context.read<AgencyProvider>().createTicket(titleController.text, descController.text);
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: "Ticket created successfully".text.make(), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
                child: "Submit Ticket".text.bold.make(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
