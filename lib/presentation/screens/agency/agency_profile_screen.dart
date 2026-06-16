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
  final _pwdFormKey = GlobalKey<FormState>();
  AgencyProfile? _profile;
  bool _isFetching = true;
  bool _isSaving = false;
  bool _isChangingPwd = false;

  final _nameController = TextEditingController();
  final _agencyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();

  bool _showNewPwd = false;
  bool _showConfirmPwd = false;

  File? _logoFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _agencyNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
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
      _showError('Error loading profile: $e');
    }
  }

  Future<void> _pickLogo() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _logoFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final Map<String, dynamic> data = {
        'name': _nameController.text.trim(),
        'agency_name': _agencyNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
      };

      if (_logoFile != null) {
        data['logo'] = await dio.MultipartFile.fromFile(
          _logoFile!.path,
          filename: 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      await AgencyService().updateProfile(data);

      if (mounted) context.read<AgencyProvider>().fetchDashboard();

      setState(() {
        _isSaving = false;
        _logoFile = null;
      });
      _showSuccess('Profile updated successfully');
      _fetchProfile(); // Refresh to get new logo URL
    } catch (e) {
      setState(() => _isSaving = false);
      _showError('Error: $e');
    }
  }

  Future<void> _changePassword() async {
    if (!_pwdFormKey.currentState!.validate()) return;

    if (_newPwdController.text != _confirmPwdController.text) {
      _showError('New passwords do not match');
      return;
    }

    setState(() => _isChangingPwd = true);
    try {
      await AgencyService().changePassword(
        currentPassword: '',
        newPassword: _newPwdController.text,
      );
      setState(() => _isChangingPwd = false);
      _newPwdController.clear();
      _confirmPwdController.clear();
      _showSuccess('Password changed successfully');
    } catch (e) {
      setState(() => _isChangingPwd = false);
      _showError('Error: $e');
    }
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: 'Agency Settings'.text.bold.make(),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isFetching)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: (_isSaving ? 'Saving...' : 'Save').text.white.bold.make(),
            ),
        ],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVerificationBanner(),
                  const SizedBox(height: 24),

                  // --- Profile Photo Section ---
                  _buildSectionCard(
                    icon: Icons.camera_alt_outlined,
                    title: 'Profile Photo',
                    child: _buildLogoSection(),
                  ),
                  const SizedBox(height: 16),

                  // --- Basic Info Section ---
                  _buildSectionCard(
                    icon: Icons.business_outlined,
                    title: 'Basic Information',
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildField('Representative Name', _nameController, Icons.person_outline),
                          const SizedBox(height: 14),
                          _buildField('Agency Business Name', _agencyNameController, Icons.business_outlined),
                          const SizedBox(height: 14),
                          _buildField('Contact Number', _phoneController, Icons.phone_outlined,
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: 14),
                          _buildField('Office Address', _locationController, Icons.location_on_outlined,
                              maxLines: 2),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveProfile,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.check, size: 18),
                              label: Text(_isSaving ? 'Saving...' : 'Save Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Change Password Section ---
                  _buildSectionCard(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    child: Form(
                      key: _pwdFormKey,
                      child: Column(
                        children: [
                          _buildPasswordField(
                            'New Password (min. 8 chars)',
                            _newPwdController,
                            _showNewPwd,
                            () => setState(() => _showNewPwd = !_showNewPwd),
                            minLength: 8,
                          ),
                          // Strength bar
                          if (_newPwdController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildStrengthBar(_newPwdController.text),
                          ],
                          const SizedBox(height: 14),
                          _buildPasswordField(
                            'Confirm New Password',
                            _confirmPwdController,
                            _showConfirmPwd,
                            () => setState(() => _showConfirmPwd = !_showConfirmPwd),
                            confirmController: _newPwdController,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isChangingPwd ? null : _changePassword,
                              icon: _isChangingPwd
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.lock_reset, size: 18),
                              label: Text(_isChangingPwd ? 'Updating...' : 'Update Password'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Documents ---
                  _buildSectionCard(
                    icon: Icons.description_outlined,
                    title: 'Verification Documents',
                    child: Column(
                      children: [
                        _buildDocumentTile('Government ID', _profile?.govtIdImageUrl != null),
                        _buildDocumentTile('Trademark License', _profile?.trademarkLicenseUrl != null),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.secondaryColor),
                const SizedBox(width: 8),
                title.text.bold.base.make(),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    final logoUrl = _profile?.logoUrl;

    ImageProvider? imageProvider;
    if (_logoFile != null) {
      imageProvider = FileImage(_logoFile!);
    } else if (logoUrl != null && logoUrl.isNotEmpty) {
      imageProvider = NetworkImage(logoUrl);
    }

    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 2),
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                    : null,
              ),
              child: imageProvider == null
                  ? Icon(Icons.business_rounded, size: 36, color: Colors.grey.shade400)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              'Agency Logo'.text.bold.sm.make(),
              const SizedBox(height: 4),
              'PNG, JPG — max 5 MB'.text.xs.gray400.make(),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickLogo,
                icon: const Icon(Icons.upload, size: 16),
                label: const Text('Choose Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.secondaryColor,
                  side: BorderSide(color: AppTheme.secondaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              if (_logoFile != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Expanded(child: 'Photo selected — tap Save'.text.xs.green600.make()),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool visible,
    VoidCallback onToggle, {
    int minLength = 0,
    TextEditingController? confirmController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.text.xs.bold.gray500.make().pOnly(left: 4, bottom: 8),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          onChanged: (v) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(visible ? Icons.visibility_off : Icons.visibility, size: 20),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
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
              borderSide: BorderSide(color: AppTheme.secondaryColor, width: 1.5),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'This field is required';
            if (minLength > 0 && v.length < minLength) return 'Min. $minLength characters';
            if (confirmController != null && v != confirmController.text) return 'Passwords do not match';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStrengthBar(String pwd) {
    int strength = 0;
    if (pwd.length >= 6) strength++;
    if (pwd.length >= 10) strength++;
    if (pwd.contains(RegExp(r'[A-Z]')) && pwd.contains(RegExp(r'[0-9]'))) strength++;
    if (pwd.contains(RegExp(r'[!@#$%^&*]'))) strength++;

    final colors = [Colors.red, Colors.orange, Colors.yellow.shade700, Colors.green];
    final labels = ['Weak', 'Fair', 'Good', 'Strong'];

    return Row(
      children: [
        ...List.generate(4, (i) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: i < strength ? colors[strength - 1] : Colors.grey.shade200,
            ),
          ),
        )),
        const SizedBox(width: 8),
        if (strength > 0)
          labels[strength - 1].text.xs.color(colors[strength - 1]).bold.make(),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1}) {
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
            fillColor: Colors.grey.shade50,
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
              borderSide: BorderSide(color: AppTheme.secondaryColor, width: 1.5),
            ),
          ),
          validator: (v) => v!.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildDocumentTile(String title, bool isUploaded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          title.text.medium.make(),
          const Spacer(),
          if (isUploaded)
            Row(children: [
              'Uploaded'.text.xs.green600.bold.make(),
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 14, color: Colors.green),
            ])
          else
            'Missing'.text.xs.red600.bold.make(),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner() {
    final isVerified = _profile?.isVerified ?? false;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isVerified ? Colors.green.shade100 : Colors.amber.shade100),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending_actions,
            color: isVerified ? Colors.green : Colors.amber,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (isVerified ? 'Verified Agency' : 'Verification Pending')
                    .text
                    .bold
                    .base
                    .color(isVerified ? Colors.green.shade800 : Colors.amber.shade800)
                    .make(),
                (isVerified
                        ? 'Your agency status is active and trusted.'
                        : 'Our team is reviewing your documents.')
                    .text
                    .xs
                    .gray600
                    .make(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
