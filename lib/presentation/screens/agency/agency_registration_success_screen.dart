import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'agency_login_screen.dart';

class AgencyRegistrationSuccessScreen extends StatelessWidget {
  const AgencyRegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.secondaryColor,
                  size: 80,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),
              
              // Title
              "Registration Completed!"
                  .text
                  .xl3
                  .bold
                  .center
                  .make()
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.2),
                  
              const SizedBox(height: 16),
              
              // Message
              "Thank you for registering your agency. Our team will verify your uploaded documents and approve your account shortly. You will receive an email once your account is activated."
                  .text
                  .gray600
                  .center
                  .lg
                  .make()
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.2),
                  
              const SizedBox(height: 48),
              
              // Back to Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AgencyLoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: "Back to Login".text.bold.white.lg.make(),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}
