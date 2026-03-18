import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'buyer';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      role: _selectedRole,
    );

    if (success && mounted) {
      ToastUtils.showSuccess(context, 'Registration successful! Please login.');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted && authProvider.error != null) {
      ToastUtils.showError(context, authProvider.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Top Illustration (Using a placeholder icon for now since we don't have the asset)
                    Center(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            height: 120,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(Icons.person, size: 60, color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.call, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Back logic
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.grey, size: 20),
                        label: const Text(
                          'Back',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title
                    const Text(
                      'Create an account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B), // Dark blue/slate color from mockup
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Full Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Full Name'),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration('admin@xyzfinders.com'),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _buildInputDecoration('........').copyWith(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: Validators.validatePassword,
                    ),
                    
                    // Hidden Role (default to buyer or default logically as needed, kept internal)
                    // Hidden Confirm Password (mockup does not have confirm password field, we can auto-fill or ignore it)
                    
                    const SizedBox(height: 32),
                    
                    // Register Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: Provider.of<AuthProvider>(context).isLoading ? null : () {
                           // If backend requires confirm password, we just pass the same password theoretically, or update backend
                           _confirmPasswordController.text = _passwordController.text;
                           // If phone number is required by backend, provide a default or empty string
                           _phoneController.text = _phoneController.text.isEmpty ? 'N/A' : _phoneController.text;
                           _register();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE824C), // Custom orange from mockup
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Provider.of<AuthProvider>(context).isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Close Button top right
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                 icon: const Icon(Icons.close, color: Colors.grey),
                 onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Taller inputs
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFE824C)),
      ),
    );
  }
}
