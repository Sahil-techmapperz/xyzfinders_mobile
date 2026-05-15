import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/report_model.dart';
import '../../../data/services/report_service.dart';
import '../seller/report_chat_screen.dart';

class BuyerReportedProductsScreen extends StatefulWidget {
  const BuyerReportedProductsScreen({super.key});

  @override
  State<BuyerReportedProductsScreen> createState() =>
      _BuyerReportedProductsScreenState();
}

class _BuyerReportedProductsScreenState
    extends State<BuyerReportedProductsScreen> {
  final ReportService _reportService = ReportService();
  List<ReportModel> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reports = await _reportService.getBuyerReports();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
      case 'in review':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'reviewed':
      case 'in review':
        return Icons.manage_search_rounded;
      case 'resolved':
        return Icons.check_circle_outline_rounded;
      case 'dismissed':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: 'My Reported Products'
            .text
            .color(AppTheme.textColor)
            .xl2
            .bold
            .make(),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchReports,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _reports.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _fetchReports,
                      color: AppTheme.secondaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) =>
                            _buildReportCard(_reports[index]),
                      ),
                    ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 72, color: Colors.red.shade300),
            const SizedBox(height: 16),
            'Failed to load reports'
                .text
                .xl
                .bold
                .color(const Color(0xFF1E293B))
                .make(),
            const SizedBox(height: 8),
            _error!.text.gray500.center.make(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchReports,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.flag_outlined,
                  size: 64, color: Colors.orange.shade300),
            ),
            const SizedBox(height: 24),
            'No Reports Submitted'
                .text
                .xl
                .bold
                .color(const Color(0xFF1E293B))
                .make(),
            const SizedBox(height: 8),
            'You haven\'t reported any products yet.\nIf you find suspicious listings, you can report them from the product page.'
                .text
                .gray500
                .center
                .make(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final statusColor = _getStatusColor(report.status);
    final statusIcon = _getStatusIcon(report.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flag Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.flag_rounded, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // Title + Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        report.productTitle.text.bold.color(const Color(0xFF1E293B)).maxLines(2).ellipsis.make(),
                        const SizedBox(height: 4),
                        '₹ ${report.productPrice.toStringAsFixed(0)}'.text.gray500.sm.make(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        report.status.toUpperCase().text
                            .color(statusColor)
                            .xs
                            .bold
                            .make(),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Reason Row
              Row(
                children: [
                  const Icon(Icons.label_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  'Reason: '.text.gray500.sm.make(),
                  report.reason.text.color(AppTheme.secondaryColor).sm.bold.make(),
                ],
              ),

              if (report.description != null &&
                  report.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: report.description!.text.gray500.sm.maxLines(2).ellipsis.make(),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      _formatDate(report.createdAt).text.gray400.xs.make(),
                    ],
                  ),
                  // Talk to admin CTA
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 14, color: AppTheme.secondaryColor),
                      const SizedBox(width: 4),
                      'Talk to Admin'
                          .text
                          .color(AppTheme.secondaryColor)
                          .xs
                          .bold
                          .make(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetails(ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(report.status),
                      size: 36,
                      color: _getStatusColor(report.status),
                    ),
                  ),
                  const SizedBox(height: 16),

                  'Report Details'.text.xl2.bold.color(const Color(0xFF1E293B)).make(),
                  const SizedBox(height: 6),
                  'Submitted on ${_formatDate(report.createdAt)}'.text.gray500.sm.make(),
                  const SizedBox(height: 24),

                  // Detail Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow('Product', report.productTitle),
                        const Divider(height: 20),
                        _detailRow('Price', '₹ ${report.productPrice.toStringAsFixed(0)}'),
                        const Divider(height: 20),
                        _detailRow('Reason', report.reason),
                        if (report.description != null && report.description!.isNotEmpty) ...[
                          const Divider(height: 20),
                          _detailRow('Description', report.description!),
                        ],
                        const Divider(height: 20),
                        _detailRow(
                          'Status',
                          report.status.toUpperCase(),
                          valueColor: _getStatusColor(report.status),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Chat with Admin Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportChatScreen(report: report),
                          ),
                        );
                      },
                      icon: const Icon(Icons.support_agent_rounded),
                      label: const Text('Open Support Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: 'Close'.text.gray500.make(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: label.text.gray500.sm.make(),
        ),
        Expanded(
          child: value.text
              .bold
              .sm
              .color(valueColor ?? const Color(0xFF1E293B))
              .make(),
        ),
      ],
    );
  }
}
