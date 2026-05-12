import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../home/home_screen.dart';

class JobApplicationSuccessScreen extends StatelessWidget {
  final String jobTitle;

  const JobApplicationSuccessScreen({
    super.key,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Success Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).shake(delay: 600.ms),
            
            const SizedBox(height: 32),
            "Thank You!".text.xl3.bold.make().animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            "Your application for".text.gray500.make().animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 8),
            jobTitle.toUpperCase().text.center.xl.bold.black.make()
                .pSymmetric(h: 32)
                .animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),
            
            const SizedBox(height: 24),
            "has been successfully submitted.".text.center.gray500.make()
                .pSymmetric(h: 48)
                .animate().fadeIn(delay: 800.ms),

            const Spacer(),
            
            // What's Next Section
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "What happens next?".text.semiBold.gray700.make(),
                  const SizedBox(height: 16),
                  _buildStep(Icons.mail_outline, "The recruiter will review your profile."),
                  const SizedBox(height: 12),
                  _buildStep(Icons.notifications_active_outlined, "You'll be notified of any status changes."),
                  const SizedBox(height: 12),
                  _buildStep(Icons.chat_bubble_outline, "Recruiters may reach out to you via chat."),
                ],
              ),
            ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),
            
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE824C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: "Back to Home".text.bold.make(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                       Navigator.pop(context);
                    },
                    child: "View My Applications".text.color(const Color(0xFFFE824C)).bold.make(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(child: text.text.size(13).gray600.make()),
      ],
    );
  }
}
