import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/job_application_service.dart';
import '../../../../data/services/image_upload_service.dart';
import '../../../providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JobApplyFormScreen extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const JobApplyFormScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobApplyFormScreen> createState() => _JobApplyFormScreenState();
}

class _JobApplyFormScreenState extends State<JobApplyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _coverLetterController = TextEditingController();
  
  String? _resumeUrl;
  String? _resumeName;
  bool _isUploading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill user data
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _fullNameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _resumeUrl = user.resumeUrl;
      if (_resumeUrl != null && _resumeUrl!.isNotEmpty) {
        _resumeName = "My Saved Resume.pdf";
      }
    }
  }

  Future<void> _pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isUploading = true;
          _resumeName = result.files.single.name;
        });

        final file = File(result.files.single.path!);
        final uploadService = ImageUploadService();
        
        final uploadedUrl = await uploadService.uploadToImageKit(file, prefix: 'resume');
        
        setState(() {
          _resumeUrl = uploadedUrl;
          _isUploading = false;
        });

        if (uploadedUrl == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload resume. Please try again."), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking file: $e")),
        );
      }
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_resumeUrl == null || _resumeUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload your resume/CV"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = JobApplicationService();
      final result = await service.applyToJob(
        jobId: widget.jobId,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        coverLetter: _coverLetterController.text.trim(),
        resumeUrl: _resumeUrl!,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        
        if (result['success']) {
          _showSuccessDialog(result['message']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An unexpected error occurred"), backgroundColor: Colors.red),
        );
      }
    }
  }


  void _showSuccessDialog(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Success",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).shake(delay: 400.ms),
              const SizedBox(height: 24),
              "Application Sent!".text.xl2.bold.make(),
              const SizedBox(height: 12),
              message.text.center.gray600.size(14).make(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to job details
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: "Back to Job Details".text.bold.make(),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Apply for Job".text.semiBold.black.make(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "Applying for:".text.red400.semiBold.size(11).make(),
                      const SizedBox(height: 4),
                      widget.jobTitle.toUpperCase().text.lg.bold.black.make(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildTextField(
                  label: "Full Name",
                  controller: _fullNameController,
                  hint: "Enter your full name",
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),
                
                _buildTextField(
                  label: "Email Address",
                  controller: _emailController,
                  hint: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? "Invalid email" : null,
                ),
                const SizedBox(height: 20),
                
                _buildTextField(
                  label: "Phone Number",
                  controller: _phoneController,
                  hint: "Enter phone number",
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 24),
                
                "Resume / CV".text.bold.make(),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _isUploading ? null : _pickResume,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.description_outlined, color: _resumeUrl != null ? Colors.green : Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (_resumeName ?? "Upload your resume (PDF, DOC)").text.size(13).ellipsis.make(),
                              if (_isUploading) 
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: LinearProgressIndicator(),
                                )
                              else if (_resumeUrl != null)
                                "Upload complete".text.green600.size(11).make()
                            ],
                          ),
                        ),
                        if (!_isUploading)
                          Icon(_resumeUrl != null ? Icons.check_circle : Icons.upload_file, 
                               color: _resumeUrl != null ? Colors.green : const Color(0xFFFE824C)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildTextField(
                  label: "Cover Letter (Optional)",
                  controller: _coverLetterController,
                  hint: "Tell the recruiter why you're a good fit...",
                  maxLines: 5,
                ),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting || _isUploading ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE824C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting 
                        ? Transform.scale(
                            scale: 0.7,
                            child: const CircularProgressIndicator(color: Colors.white),
                          )
                        : "SUBMIT APPLICATION".text.bold.size(16).make(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.text.bold.make(),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFE824C)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
