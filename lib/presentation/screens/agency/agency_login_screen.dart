import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/agency_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'agency_dashboard_screen.dart';
import 'agency_registration_screen.dart';
import 'agency_forgot_password_screen.dart';
import '../home/home_screen.dart';

class AgencyLoginScreen extends StatefulWidget {
  const AgencyLoginScreen({super.key});

  @override
  State<AgencyLoginScreen> createState() => _AgencyLoginScreenState();
}

class _AgencyLoginScreenState extends State<AgencyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AgencyProvider>();
    final success = await provider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AgencyDashboardScreen()),
        (route) => false,
      );
    } else if (mounted && provider.error != null) {
      if (provider.isAwaitingApproval) {
        _showApprovalPendingDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showApprovalPendingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            "Approval Pending".text.bold.make(),
          ],
        ),
        content: "Your agency account has been created successfully but is currently awaiting admin approval. Please try again later or contact support if this persists.".text.make(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: "Got it".text.color(AppTheme.secondaryColor).bold.make(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -100,
            left: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: AppTheme.secondaryColor.withOpacity(0.05),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: AppTheme.secondaryColor.withOpacity(0.05),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand / Logo
                    const Icon(Icons.business_center_rounded, size: 64, color: AppTheme.secondaryColor)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(delay: 200.ms),
                    const SizedBox(height: 16),
                    "XYZFinders".text.bold.xl3.color(AppTheme.primaryColor).center.make(),
                    "Agency Portal".text.bold.lg.color(AppTheme.secondaryColor).center.make(),
                    const SizedBox(height: 48),
                    
                    // Login Card
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
                            "Login to your workspace".text.bold.xl.make(),
                            "Enter your agency credentials".text.xs.gray500.make().pOnly(bottom: 24),
                            
                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: "Email Address",
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) => v!.isEmpty ? "Email is required" : null,
                            ),
                            const SizedBox(height: 16),
                            
                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              decoration: InputDecoration(
                                hintText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _showPassword = !_showPassword),
                                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? "Password is required" : null,
                            ),
                            const SizedBox(height: 8),
                            
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AgencyForgotPasswordScreen()),
                                  );
                                },
                                child: "Forgot Password?".text.sm.color(AppTheme.secondaryColor).make(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Login Button
                            Consumer<AgencyProvider>(
                              builder: (context, provider, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: provider.isLoading ? null : _handleLogin,
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
                                        : "Login Now".text.bold.make(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOut),
                    
                    const SizedBox(height: 24),
                    
                    // Sign Up Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        "Don't have an agency account?".text.gray600.make(),
                        const SizedBox(width: 4),
                        "Register Now".text.bold.color(AppTheme.secondaryColor).make().onTap(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AgencyRegistrationScreen()),
                          );
                        }),
                      ],
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 32),
                    
                    // Back to main app
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        "Back to Main App".text.gray500.make().onTap(() => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
