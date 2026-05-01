import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../providers/agency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/agency_models.dart';
import '../../../data/services/agency_service.dart';

class AgencyProfileScreen extends StatefulWidget {
  const AgencyProfileScreen({super.key});

  @override
  State<AgencyProfileScreen> createState() => _AgencyProfileScreenState();
}

class _AgencyProfileScreenState extends State<AgencyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  AgencyProfile? _profile;
  bool _isFetching = true;
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _agencyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  File? _logoFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isFetching = true);
    try {
      final profile = await AgencyService().getProfile();
      setState(() {
        _profile = profile;
        _nameController.text = profile.name;
        _agencyNameController.text = profile.agencyName;
        _phoneController.text = profile.phone ?? '';
        _locationController.text = profile.location ?? '';
        _isFetching = false;
      });
    } catch (e) {
      setState(() => _isFetching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickLogo() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _logoFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'agency_name': _agencyNameController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
      };

      if (_logoFile != null) {
        data['logo'] = await dio.MultipartFile.fromFile(_logoFile!.path);
      }

      await AgencyService().updateProfile(data);
      
      // Update provider to reflect changes immediately
      if (mounted) context.read<AgencyProvider>().fetchDashboard();
      
      setState(() {
        _isSaving = false;
        _logoFile = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: "Agency Settings".text.bold.make(),
        backgroundColor: const Color(0xFF111827),
        actions: [
          if (!_isFetching)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: (_isSaving ? "Saving..." : "Save").text.white.bold.make(),
            ),
        ],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVerificationBanner(),
                    const SizedBox(height: 32),
                    
                    _buildLogoSection(),
                    const SizedBox(height: 32),
                    
                    "Basic Information".text.bold.lg.make().pOnly(bottom: 16),
                    _buildField("Representative Name", _nameController, Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildField("Agency Business Name", _agencyNameController, Icons.business_outlined),
                    const SizedBox(height: 16),
                    _buildField("Business Contact Number", _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 32),
                    
                    "Business Location".text.bold.lg.make().pOnly(bottom: 16),
                    _buildField("Full Office Address", _locationController, Icons.location_on_outlined, maxLines: 3),
                    const SizedBox(height: 32),
                    
                    "Verification Documents".text.bold.lg.make().pOnly(bottom: 16),
                    _buildDocumentTile("Government ID", _profile?.govtIdImageUrl != null),
                    _buildDocumentTile("Trademark License", _profile?.trademarkLicenseUrl != null),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
              image: _logoFile != null 
                ? DecorationImage(image: FileImage(_logoFile!), fit: BoxFit.cover)
                : (_profile?.logoUrl != null 
                    ? DecorationImage(image: NetworkImage(_profile!.logoUrl!), fit: BoxFit.cover)
                    : null),
            ),
            child: (_logoFile == null && _profile?.logoUrl == null)
                ? Icon(Icons.business_rounded, size: 40, color: Colors.grey.shade400)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickLogo,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner() {
    final isVerified = _profile?.isVerified ?? false;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isVerified ? Colors.green.shade100 : Colors.amber.shade100),
      ),
      child: Row(
        children: [
          Icon(isVerified ? Icons.verified : Icons.pending_actions, color: isVerified ? Colors.green : Colors.amber, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (isVerified ? "Verified Agency" : "Verification Pending").text.bold.lg.color(isVerified ? Colors.green.shade800 : Colors.amber.shade800).make(),
                (isVerified ? "Your agency status is active and trusted." : "Our team is reviewing your documents.").text.xs.gray600.make(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.text.xs.bold.gray500.make().pOnly(left: 4, bottom: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (v) => v!.isEmpty ? "This field is required" : null,
        ),
      ],
    );
  }

  Widget _buildDocumentTile(String title, bool isUploaded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Icon(Icons.description_outlined, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          title.text.medium.make(),
          const Spacer(),
          if (isUploaded)
            Row(
              children: [
                "Uploaded".text.xs.green600.bold.make(),
                const SizedBox(width: 4),
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
              ],
            )
          else
            "Missing".text.xs.red600.bold.make(),
        ],
      ),
    );
  }
}
