import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/agency_provider.dart';
import '../../../core/theme/app_theme.dart';

class AgencyResetPasswordScreen extends StatefulWidget {
  final String email;
  
  const AgencyResetPasswordScreen({super.key, required this.email});

  @override
  State<AgencyResetPasswordScreen> createState() => _AgencyResetPasswordScreenState();
}

class _AgencyResetPasswordScreenState extends State<AgencyResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AgencyProvider>();
    
    final success = await provider.resetPassword(
      widget.email,
      _otpController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully. Please login with your new password.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to login screen
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                const Icon(Icons.password, size: 64, color: AppTheme.secondaryColor)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(delay: 200.ms),
                const SizedBox(height: 16),
                "Reset Password".text.bold.xl3.color(AppTheme.primaryColor).center.make(),
                "Enter the 6-digit code sent to ${widget.email}".text.gray500.center.make(),
                const SizedBox(height: 48),
                
                // Form Card
                Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // OTP
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            hintText: "6-Digit Code",
                            prefixIcon: Icon(Icons.pin_outlined),
                            counterText: "",
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Code is required";
                            if (v.length != 6) return "Enter a valid 6-digit code";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // New Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            hintText: "New Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Password is required";
                            if (v.length < 8) return "Password must be at least 8 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm New Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_showPassword,
                          decoration: const InputDecoration(
                            hintText: "Confirm Password",
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Confirm password is required";
                            if (v != _passwordController.text) return "Passwords do not match";
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Submit Button
                        Consumer<AgencyProvider>(
                          builder: (context, provider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: provider.isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: provider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : "Reset Password".text.bold.make(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
