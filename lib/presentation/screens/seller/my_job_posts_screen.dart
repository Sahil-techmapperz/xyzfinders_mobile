import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/job_application_model.dart';
import '../../../data/services/job_application_service.dart';
import 'package:velocity_x/velocity_x.dart';

class MyJobPostsScreen extends StatefulWidget {
  const MyJobPostsScreen({super.key});

  @override
  State<MyJobPostsScreen> createState() => _MyJobPostsScreenState();
}

class _MyJobPostsScreenState extends State<MyJobPostsScreen> {
  final JobApplicationService _jobService = JobApplicationService();
  List<SellerJobPostModel> _jobs = [];
  List<JobApplicationModel> _allApplicants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _jobService.getApplicantsForMyJobs();
      setState(() {
        _jobs = data['jobs'];
        _allApplicants = data['applicants'];
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: "My Job Posts".text.color(AppTheme.textColor).xl2.bold.make(),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _jobs.isEmpty
                  ? Center(child: "No job posts yet".text.gray500.make())
                  : DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: AppTheme.primaryColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: AppTheme.primaryColor,
                            tabs: [
                              Tab(text: "Jobs"),
                              Tab(text: "All Applicants"),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildJobsList(),
                                _buildApplicantsList(_allApplicants),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildJobsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jobs.length,
      itemBuilder: (context, index) {
        final job = _jobs[index];
        final applicantCount = _allApplicants.where((a) => a.jobId == job.id).length;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: job.title.text.bold.lg.make(),
            subtitle: "$applicantCount Applicants".text.color(AppTheme.primaryColor).bold.make().pOnly(top: 8),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobApplicantsScreen(job: job),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildApplicantsList(List<JobApplicationModel> applicants) {
    if (applicants.isEmpty) {
      return Center(child: "No applicants yet".text.gray500.make());
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: applicants.length,
      itemBuilder: (context, index) {
        final applicant = applicants[index];
        return _buildApplicantCard(applicant);
      },
    );
  }

  Widget _buildApplicantCard(JobApplicationModel applicant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          _showApplicantDetails(applicant);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: (applicant.applicantName?.isNotEmpty == true 
                      ? applicant.applicantName![0] 
                      : "?").text.color(AppTheme.primaryColor).bold.make(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        applicant.applicantName?.text.bold.lg.make() ?? "Anonymous".text.make(),
                        applicant.jobTitle.text.gray500.sm.make(),
                      ],
                    ),
                  ),
                  _buildStatusBadge(applicant.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  "Applied: ${_formatDate(applicant.createdAt)}".text.gray500.xs.make(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'reviewed': color = Colors.blue; break;
      case 'shortlisted': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: status.toUpperCase().text.color(color).xs.bold.make(),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  void _showApplicantDetails(JobApplicationModel applicant) {
    // Navigate to detail screen or show modal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobApplicationDetailScreen(application: applicant, onUpdate: _fetchData),
      ),
    );
  }
}

class JobApplicantsScreen extends StatefulWidget {
  final SellerJobPostModel job;
  const JobApplicantsScreen({super.key, required this.job});

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  final JobApplicationService _jobService = JobApplicationService();
  List<JobApplicationModel> _applicants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  Future<void> _fetchApplicants() async {
    setState(() => _isLoading = true);
    try {
      final data = await _jobService.getApplicantsForMyJobs(jobId: widget.job.id);
      setState(() {
        _applicants = data['applicants'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: widget.job.title.text.color(AppTheme.textColor).lg.bold.make(),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applicants.isEmpty
              ? Center(child: "No applicants for this job yet".text.gray500.make())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _applicants.length,
                  itemBuilder: (context, index) {
                    final applicant = _applicants[index];
                    return _buildApplicantCard(applicant);
                  },
                ),
    );
  }

  Widget _buildApplicantCard(JobApplicationModel applicant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobApplicationDetailScreen(application: applicant, onUpdate: _fetchApplicants),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: (applicant.applicantName?.isNotEmpty == true ? applicant.applicantName![0] : "?").text.color(AppTheme.primaryColor).bold.make(),
        ),
        title: (applicant.applicantName ?? "Anonymous").text.bold.make(),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            applicant.applicantEmail?.text.sm.gray500.make() ?? const SizedBox(),
            _buildStatusBadge(applicant.status).pOnly(top: 4),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'reviewed': color = Colors.blue; break;
      case 'shortlisted': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: status.toUpperCase().text.color(color).xs.bold.make(),
    );
  }
}

class JobApplicationDetailScreen extends StatefulWidget {
  final JobApplicationModel application;
  final VoidCallback? onUpdate;
  const JobApplicationDetailScreen({super.key, required this.application, this.onUpdate});

  @override
  State<JobApplicationDetailScreen> createState() => _JobApplicationDetailScreenState();
}

class _JobApplicationDetailScreenState extends State<JobApplicationDetailScreen> {
  final JobApplicationService _jobService = JobApplicationService();
  bool _isUpdating = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    final success = await _jobService.updateApplicationStatus(widget.application.id, status);
    setState(() => _isUpdating = false);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $status'))
        );
        widget.onUpdate?.call();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: "Application Details".text.color(AppTheme.textColor).make(),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: (app.applicantName?.isNotEmpty == true ? app.applicantName![0] : "?").text.xl2.color(AppTheme.primaryColor).bold.make(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (app.applicantName ?? "Anonymous").text.xl.bold.make(),
                      app.jobTitle.text.color(AppTheme.primaryColor).bold.make(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.email, "Email", app.applicantEmail ?? "N/A"),
            _buildInfoRow(Icons.phone, "Phone", app.applicantPhone ?? "N/A"),
            _buildInfoRow(Icons.location_on, "Location", app.applicantLocation ?? "N/A"),
            const Divider(height: 40),
            "Cover Letter".text.bold.lg.make(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: (app.coverLetter ?? "No cover letter provided").text.gray700.make(),
            ),
            const SizedBox(height: 24),
            if (app.resumeUrl != null) ...[
              "Resume".text.bold.lg.make(),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Open resume URL
                },
                icon: const Icon(Icons.description),
                label: const Text("View Resume"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            const Divider(height: 40),
            "Update Status".text.bold.lg.make(),
            const SizedBox(height: 16),
            if (_isUpdating)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatusButton('Reviewed', Colors.blue, 'reviewed'),
                  _buildStatusButton('Shortlist', Colors.green, 'shortlisted'),
                  _buildStatusButton('Reject', Colors.red, 'rejected'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              label.text.gray500.xs.make(),
              value.text.bold.make(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, Color color, String status) {
    return ElevatedButton(
      onPressed: () => _updateStatus(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: label.text.make(),
    );
  }
}
