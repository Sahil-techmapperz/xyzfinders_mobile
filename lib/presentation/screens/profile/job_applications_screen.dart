import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/job_application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/job_application_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/image_upload_service.dart';
import '../categories/jobs/jobs_detail_screen.dart';

class JobApplicationsScreen extends StatefulWidget {
  const JobApplicationsScreen({super.key});

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobApplicationProvider>().loadApplications();
      context.read<AuthProvider>().refreshUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Career Center',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppTheme.secondaryColor,
            labelColor: AppTheme.secondaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Applications'),
              Tab(text: 'My CVs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildApplicationsTab(),
            _buildCVsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return Consumer<JobApplicationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor));
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        if (provider.applications.isEmpty) {
          return _buildEmptyState('No applications found', 'You haven\'t applied for any jobs yet.');
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadApplications(),
          color: AppTheme.secondaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.applications.length,
            itemBuilder: (context, index) {
              return _buildApplicationCard(provider.applications[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildCVsTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final resumes = authProvider.user?.resumes ?? [];

        return Column(
          children: [
            Expanded(
              child: resumes.isEmpty
                  ? _buildEmptyState('No CVs uploaded', 'Upload your CV to apply for jobs easily.')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: resumes.length,
                      itemBuilder: (context, index) {
                        return _buildCVCard(resumes[index], authProvider);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _handleCVUpload(context, authProvider),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload New CV', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCVCard(ResumeModel resume, AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: resume.isDefault ? AppTheme.secondaryColor : Colors.grey.shade200,
          width: resume.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.description, color: AppTheme.secondaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (resume.isDefault)
                        const Text(
                          'Default CV',
                          style: TextStyle(color: AppTheme.secondaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                if (!resume.isDefault)
                  TextButton(
                    onPressed: () => authProvider.setDefaultResume(resume.id),
                    child: const Text('Set Default'),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewCV(resume.url),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.secondaryColor,
                      side: const BorderSide(color: AppTheme.secondaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _confirmDeleteCV(context, authProvider, resume.id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(JobApplicationModel app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    app.jobTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                _buildStatusChip(app.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  app.companyName ?? 'Unknown Company',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  (app.city != null && app.state != null) 
                    ? '${app.city}, ${app.state}' 
                    : app.city ?? app.state ?? 'Remote',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Applied on: ${_formatDate(app.createdAt)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobsDetailScreen(productId: app.jobId),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color bgColor;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'rejected':
        color = Colors.red;
        bgColor = Colors.red.shade50;
        break;
      case 'reviewed':
        color = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      default:
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Future<void> _viewCV(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } else {
        // Force launch for ImageKit URLs if canLaunchUrl fails
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open CV: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteCV(BuildContext context, AuthProvider authProvider, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete CV"),
        content: const Text("Are you sure you want to delete this CV?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.removeResume(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CV deleted successfully")),
        );
      }
    }
  }

  Future<void> _handleCVUpload(BuildContext context, AuthProvider authProvider) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath == null) {
          throw Exception("Could not get file path. Please try another file.");
        }
        final file = File(filePath);
        final uploadService = ImageUploadService();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Uploading CV...")),
          );
        }
        
        final fileName = result.files.single.name;
        final resumeUrl = await uploadService.uploadToImageKit(file, prefix: 'resume');
        
        if (resumeUrl != null) {
          await authProvider.addResume(fileName, resumeUrl);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("CV uploaded successfully"), backgroundColor: Colors.green),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to upload CV. Please try again."), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
}
