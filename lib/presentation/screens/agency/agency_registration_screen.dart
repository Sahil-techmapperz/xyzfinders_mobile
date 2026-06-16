import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/agency_provider.dart';
import '../../../data/services/category_service.dart';
import '../../../data/models/category_model.dart';
import 'agency_login_screen.dart';
import 'agency_registration_success_screen.dart';
import '../../../core/theme/app_theme.dart';

class AgencyRegistrationScreen extends StatefulWidget {
  const AgencyRegistrationScreen({super.key});

  @override
  State<AgencyRegistrationScreen> createState() => _AgencyRegistrationScreenState();
}

class _AgencyRegistrationScreenState extends State<AgencyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _agencyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _govtIdNumberController = TextEditingController();
  bool _obscurePassword = true;

  File? _tradeLicense;
  File? _govtId;
  final _picker = ImagePicker();
  
  final CategoryService _categoryService = CategoryService();
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;
  final List<int> _selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _agencyNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _govtIdNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 'license') _tradeLicense = File(pickedFile.path);
        if (type == 'id') _govtId = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_tradeLicense == null || _govtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload all required documents"), backgroundColor: Colors.orange),
      );
      return;
    }

    final provider = context.read<AgencyProvider>();
    
    final Map<String, dynamic> registrationData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'agency_name': _agencyNameController.text,
      'phone': _phoneController.text,
      'location': _locationController.text,
      'govt_id_number': _govtIdNumberController.text,
      'trade_license': _tradeLicense!,
      'govt_id': _govtId!,
      'categories': _selectedCategoryIds,
    };

    final success = await provider.register(registrationData);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AgencyRegistrationSuccessScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: (provider.error ?? 'Registration failed').text.make(), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AgencyProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        title: "Agency Registration".text.black.bold.make(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                "Setup Your Agency".text.xl3.bold.make()
                    .animate().slideX(begin: -0.2, duration: 400.ms),
                "Join our network of verified professionals.".text.gray500.make()
                    .animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),

                // ... [Other fields remain same, I'll include them in the full replacement below to be safe]
                _buildTextField(
                  controller: _nameController,
                  label: "Full Name",
                  hint: "John Doe",
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? "Enter your name" : null,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _agencyNameController,
                  label: "Agency Name",
                  hint: "Sunrise Real Estate",
                  icon: Icons.business_outlined,
                  validator: (v) => v!.isEmpty ? "Enter agency name" : null,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _emailController,
                  label: "Email Address",
                  hint: "agency@example.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains('@') ? null : "Enter valid email",
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _phoneController,
                  label: "Phone Number",
                  hint: "+91 98765 43210",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? "Enter phone number" : null,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _locationController,
                  label: "Location",
                  hint: "Kolkata, West Bengal",
                  icon: Icons.location_on_outlined,
                  validator: (v) => v!.isEmpty ? "Enter location" : null,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "••••••••",
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => v!.length < 6 ? "Password too short" : null,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _govtIdNumberController,
                  label: "Govt ID Number (Aadhar/PAN/etc.)",
                  hint: "Enter your government ID number",
                  icon: Icons.badge_outlined,
                  validator: (v) => v!.isEmpty ? "Enter ID number" : null,
                ),
                const SizedBox(height: 32),

                // Category Selection
                "Categories you deal in".text.lg.bold.make().pOnly(bottom: 8),
                "Select multiple if applicable. Leave empty for General Store.".text.xs.gray500.make().pOnly(bottom: 16),
                _isLoadingCategories
                    ? const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _categories.map((category) {
                            final isSelected = _selectedCategoryIds.contains(category.id);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedCategoryIds.remove(category.id);
                                  } else {
                                    _selectedCategoryIds.add(category.id);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.secondaryColor : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.secondaryColor : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.secondaryColor.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                const SizedBox(height: 32),

                // Document Upload Section
                "Verification Documents".text.lg.bold.make().pOnly(bottom: 16),
                
                _buildDocTile("Trade License / Agency Certificate", _tradeLicense, () => _pickImage('license')),
                const SizedBox(height: 12),
                _buildDocTile("Govt Issued ID (Owner Photo ID)", _govtId, () => _pickImage('id')),
                
                const SizedBox(height: 40),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : "Create Agency Account".text.bold.white.lg.make(),
                  ),
                ),
                const SizedBox(height: 24),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "Already have an account? ".text.gray500.make(),
                    "Login".text.bold.color(AppTheme.secondaryColor).make().onTap(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AgencyLoginScreen()),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocTile(String title, File? file, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: file != null ? AppTheme.secondaryColor : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(file != null ? Icons.check_circle : Icons.upload_file_outlined, 
                 color: file != null ? Colors.green : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title.text.sm.bold.make(),
                  (file != null ? "Document selected" : "Click to upload document").text.xs.gray500.make(),
                ],
              ),
            ),
            if (file != null) ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(file, width: 40, height: 40, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.text.sm.bold.gray700.make().pOnly(bottom: 8, left: 4),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    );
  }
}
