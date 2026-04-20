import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: April 2026',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              '1. Information We Collect',
              'When you use our services, we collect information about you that may include personal information such as your name, email address, phone number, and location data to provide you with localized marketplace experiences.',
            ),
            
            _buildSection(
              '2. How We Use Your Information',
              'We use your information to operate, improve, and protect our platform. This includes connecting buyers with sellers, processing transactions securely, sending security alerts, and providing customer support.',
            ),
            
            _buildSection(
              '3. Information Sharing',
              'We do not sell your personal information. We may share limited information with trusted service providers to help us operate our business, or when legally required to protect our rights or our platform.',
            ),
            
            _buildSection(
              '4. Your Data Rights',
              'You have the right to access, update, or delete your account information at any time through the Account Settings panel. You may also request a copy of your data by contacting our support team.',
            ),
            
            _buildSection(
              '5. Security Measures',
              'We implement state-of-the-art security measures to protect your data. All sensitive transactions and passwords are encrypted and securely stored using modern cryptographic standards.',
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}
