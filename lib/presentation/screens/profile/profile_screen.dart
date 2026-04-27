import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../../widgets/auth/auth_modal.dart';
import 'edit_profile_screen.dart';
import 'account_settings_screen.dart';
import 'security_settings_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../notifications/notification_settings_screen.dart';
import '../support/support_screen.dart';
import 'job_applications_screen.dart';
import 'language_selection_screen.dart';
import 'buyer_dashboard_screen.dart';
import '../seller/seller_reports_screen.dart';
import '../seller/my_job_posts_screen.dart';
import '../../providers/language_provider.dart';
import '../../../core/localization/app_localization.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return _buildUnauthenticatedView(context);
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 0, // Mockup has no app bar, just system status bar
          ),
          body: RefreshIndicator(
            onRefresh: () => authProvider.refreshUser(),
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 120.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // User Info Card
                    _buildUserInfoCard(context, authProvider),
                    const SizedBox(height: 16),
                    
                    // Switch Mode Button (Premium Design)
                    _buildModeSwitchTile(context, authProvider),
                    
                    const SizedBox(height: 16),
                    
                    // Action Cards replaced by premium banner above
                    
                    const Divider(color: Colors.grey, height: 1),
                    
                    // Settings List
                    _buildSettingsList(context, authProvider),
                    
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, toolbarHeight: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              const Text(
                'Create an account or log in',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Log in to access your profile, manage your ads, and chat with buyers.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => AuthModal.show(context, initialIsLogin: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => AuthModal.show(context, initialIsLogin: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondaryColor,
                    side: const BorderSide(color: AppTheme.secondaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;

    // Helper to format date
    String formatJoinDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'January, 2026';
      try {
        final date = DateTime.parse(dateStr);
        final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        return '${months[date.month - 1]}, ${date.year}';
      } catch (e) {
        return 'January, 2026';
      }
    }

    // Safely get user initials
    String getInitials() {
      if (user == null || user.name.isEmpty) return 'U';
      return user.name[0].toUpperCase();
    }
    
    // Process Avatar URL logic
    ImageProvider? getAvatar() {
      // 1. Prioritize image from binary retrieval endpoint
      if (user != null) {
        final dynamicUrl = '${ApiConstants.baseUrl}${ApiConstants.userImage(user.id)}?t=${authProvider.lastUpdateTimestamp}';
        return CachedNetworkImageProvider(dynamicUrl);
      }
      
      // 2. Fallback to ImageKit/External URL if available
      if (user?.avatar != null && user!.avatar!.isNotEmpty) {
        return CachedNetworkImageProvider(user.avatar!);
      }
      
      return null;
    }

    Future<void> pickAndUploadImage() async {
      try {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1000,
        );
        
        if (image != null && context.mounted) {
          await authProvider.uploadAvatar(File(image.path));
        }
      } catch (e) {
        debugPrint('Image picker error: $e');
        if (e.toString().contains('already_active')) {
          // Ignore if already active
          return;
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to open image picker')),
          );
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Stack(
            children: [
              GestureDetector(
                onTap: authProvider.isLoading ? null : pickAndUploadImage,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: authProvider.isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        )
                      : ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: (user?.avatar != null && user!.avatar!.startsWith('http'))
                                ? user!.avatar!
                                : '${ApiConstants.baseUrl}${ApiConstants.userImage(user!.id)}?t=${authProvider.lastUpdateTimestamp}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                getInitials(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: authProvider.isLoading ? null : pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.isSellerMode ? 'Professional Seller' : 'Verified Buyer',
                  style: TextStyle(
                    fontSize: 13,
                    color: authProvider.isSellerMode ? AppTheme.primaryColor : Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Joined on ${formatJoinDate(user?.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitchTile(BuildContext context, AuthProvider authProvider) {
    final l10n = AppLocalization.of(context);
    final isSeller = authProvider.isSellerMode;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSeller 
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)] 
              : [const Color(0xFF1E293B), const Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final success = await authProvider.toggleMode();
            if (!success && context.mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(authProvider.error ?? 'Failed to switch mode')),
               );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSeller ? Icons.shopping_bag : Icons.storefront,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSeller ? l10n.translate('switch_to_buyer') : l10n.translate('switch_to_seller'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSeller ? l10n.translate('manage_orders') : l10n.translate('manage_ads'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (authProvider.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, AuthProvider authProvider) {
    final l10n = AppLocalization.of(context);
    return Column(
      children: [
        if (!authProvider.isSellerMode)
          _buildListTile(
            icon: Icons.dashboard_outlined, 
            title: 'Dashboard',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuyerDashboardScreen()),
              );
            },
          ),
        _buildListTile(
          icon: Icons.person_outline, 
          title: l10n.translate('profile'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
        ),
        _buildListTile(
          icon: Icons.settings_outlined, 
          title: l10n.translate('account_settings'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
            );
          },
        ),
        _buildListTile(
          icon: Icons.notifications_none_outlined, 
          title: l10n.translate('notification_settings'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
            );
          },
        ),
        _buildListTile(
          icon: Icons.security_outlined, 
          title: l10n.translate('security_settings'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
            );
          },
        ),
        if (authProvider.isSellerMode)
          _buildListTile(
            icon: Icons.report_problem_outlined, 
            title: 'Reported Products',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SellerReportsScreen()),
              );
            },
          ),
        if (authProvider.isSellerMode)
          _buildListTile(
            icon: Icons.work_history_outlined, 
            title: 'My Job Posts',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyJobPostsScreen()),
              );
            },
          ),
        const Divider(color: Colors.grey, height: 1),
        if (!authProvider.isSellerMode)
          _buildListTile(
            icon: Icons.work_outline, 
            title: l10n.translate('job_applications'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JobApplicationsScreen()),
              );
            },
          ),
        if (!authProvider.isSellerMode)
          _buildListTile(
            icon: Icons.favorite_border, 
            title: l10n.translate('wishlist'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
            },
          ),
        const Divider(color: Colors.grey, height: 1),
        Consumer<LanguageProvider>(
          builder: (context, langProvider, _) => _buildListTile(
            icon: Icons.translate, 
            title: l10n.translate('languages'), 
            trailingText: '${langProvider.currentLanguage} >',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
              );
            },
          ),
        ),
        _buildListTile(
          icon: Icons.support_agent_outlined, 
          title: l10n.translate('support'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SupportScreen()),
            );
          },
        ),
        const Divider(color: Colors.grey, height: 1),
        
        // Logout Tile
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
          ),
          title: Text(
            l10n.translate('logout'),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.red, size: 20),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text(l10n.translate('logout'), style: const TextStyle(fontWeight: FontWeight.bold)),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(l10n.translate('logout')),
                  ),
                ],
              ),
            );

            if (confirmed == true && context.mounted) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              // Consumer<AuthProvider> automatically shows the unauthenticated view
            }
          },
        ),
        const SizedBox(height: 48), // Padding for bottom navbar
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
             Text(trailingText, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))
          else
             const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }
}
