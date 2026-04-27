import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/notification_provider.dart';
import '../../../data/models/notification_model.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late NotificationSettingsModel _tempSettings;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchSettings();
    });
  }

  void _initializeTempSettings(NotificationSettingsModel settings) {
    if (!_isInitialized) {
      _tempSettings = settings;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isSettingsLoading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          final settings = provider.settings ?? NotificationSettingsModel();
          _initializeTempSettings(settings);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'General Notifications',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildSwitchTile(
                  title: 'Push Notifications (All)',
                  subtitle: 'Receive instant alerts on your device',
                  value: _tempSettings.pushMessages && _tempSettings.pushReviews,
                  onChanged: (val) => setState(() {
                    _tempSettings = _tempSettings.copyWith(
                      pushMessages: val,
                      pushReviews: val,
                    );
                  }),
                ),
                _buildSwitchTile(
                  title: 'Chat Messages',
                  subtitle: 'New messages from buyers and sellers',
                  value: _tempSettings.pushMessages,
                  onChanged: (val) => setState(() {
                    _tempSettings = _tempSettings.copyWith(pushMessages: val);
                  }),
                ),
                _buildSwitchTile(
                  title: 'Review Alerts',
                  subtitle: 'Updates about your product reviews',
                  value: _tempSettings.pushReviews,
                  onChanged: (val) => setState(() {
                    _tempSettings = _tempSettings.copyWith(pushReviews: val);
                  }),
                ),
                const Divider(height: 32),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Other Channels',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildSwitchTile(
                  title: 'Email Notifications',
                  subtitle: 'Receive updates via your registered email',
                  value: _tempSettings.emailMessages,
                  onChanged: (val) => setState(() {
                    _tempSettings = _tempSettings.copyWith(emailMessages: val);
                  }),
                ),
                _buildSwitchTile(
                  title: 'Marketing & Promos',
                  subtitle: 'Exclusive deals and personalized offers',
                  value: _tempSettings.emailPromotions,
                  onChanged: (val) => setState(() {
                    _tempSettings = _tempSettings.copyWith(emailPromotions: val);
                  }),
                ),
                _buildSwitchTile(
                  title: 'Product Updates',
                  subtitle: 'Get alerts for new products in your category',
                  value: _tempSettings.emailProducts,
                  onChanged: (val) => setState(() {
                    _tempSettings = _tempSettings.copyWith(emailProducts: val);
                  }),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await provider.updateSettings(_tempSettings);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Settings saved successfully')),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to save: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
