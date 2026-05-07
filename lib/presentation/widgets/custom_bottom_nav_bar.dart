import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../widgets/auth/auth_modal.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/chats/chat_list_screen.dart';
import '../screens/ads/post_ad_category_screen.dart';
import '../screens/seller/my_products_screen.dart';
import '../screens/seller/store_list_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool isSellerMode;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    this.isSellerMode = false,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      color: AppTheme.secondaryColor,
      elevation: 0,
      padding: EdgeInsets.zero,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {}, // Consume taps on blank space
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, isSellerMode ? Icons.dashboard_rounded : Icons.home_filled, isSellerMode ? 'Dashboard' : 'Home'),
            _buildNavItem(1, isSellerMode ? Icons.campaign_rounded : Icons.favorite_border, isSellerMode ? 'My Ads' : 'Wishlist'),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(3, Icons.forum_outlined, 'Chats'),
            _buildNavItem(4, Icons.person_rounded, 'Profile'), // changed from Icons.menu
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static void handleGlobalNavigation(BuildContext context, int index, int currentIndex, bool isSellerMode) {
    if (index == currentIndex) return;
    
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => isSellerMode ? MyProductsScreen() : const WishlistScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChatListScreen()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Speed-dial FAB — Half-circle Radial Layout
// ─────────────────────────────────────────────────────────────────────────────

class CustomFab extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isSellerMode;
  const CustomFab({super.key, required this.onPressed, this.isSellerMode = false});

  @override
  State<CustomFab> createState() => _CustomFabState();
}

class _CustomFabState extends State<CustomFab> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _controller.addListener(() {
      if (_overlayEntry != null) {
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    setState(() => _isOpen = true); // Hide original FAB
    final auth = context.read<AuthProvider>();
    final items = _getItems(context, auth);
    _overlayEntry = _createOverlayEntry(items);
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
  }

  void _close() {
    if (_controller.status == AnimationStatus.reverse) return;
    _controller.reverse().then((_) {
      if (mounted) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        setState(() => _isOpen = false); // Show original FAB again
      }
    });
  }

  List<_SpeedDialItem> _getItems(BuildContext context, AuthProvider auth) {
    if (!auth.isAuthenticated) {
      // ── Guest ──
      return [
        _SpeedDialItem(
          icon: Icons.login_rounded,
          label: 'Login',
          color: AppTheme.secondaryColor,
          onTap: () {
            _close();
            AuthModal.show(context, initialIsLogin: true);
          },
        ),
        _SpeedDialItem(
          icon: Icons.person_add_rounded,
          label: 'Register',
          color: Colors.teal,
          onTap: () {
            _close();
            AuthModal.show(context, initialIsLogin: false);
          },
        ),
        _SpeedDialItem(
          icon: Icons.store_rounded,
          label: 'Browse Stores',
          color: Colors.orange,
          onTap: () {
            _close();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreListScreen()));
          },
        ),
      ];
    }

    if (auth.isSellerMode) {
      // ── Seller ──
      return [
        _SpeedDialItem(
          icon: Icons.add_photo_alternate_rounded,
          label: 'Post Ad',
          color: AppTheme.secondaryColor,
          onTap: () {
            _close();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PostAdCategoryScreen()));
          },
        ),
        _SpeedDialItem(
          icon: Icons.inventory_2_rounded,
          label: 'My Products',
          color: Colors.indigo,
          onTap: () {
            _close();
            Navigator.push(context, MaterialPageRoute(builder: (_) => MyProductsScreen()));
          },
        ),
        _SpeedDialItem(
          icon: Icons.store_rounded,
          label: 'My Stores',
          color: Colors.teal,
          onTap: () {
            _close();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreListScreen()));
          },
        ),
        _SpeedDialItem(
          icon: Icons.forum_outlined,
          label: 'Chats',
          color: Colors.deepPurple,
          onTap: () {
            _close();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
          },
        ),
      ];
    }

    // ── Buyer ──
    return [
      _SpeedDialItem(
        icon: Icons.favorite_rounded,
        label: 'Wishlist',
        color: Colors.pinkAccent,
        onTap: () {
          _close();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
        },
      ),
      _SpeedDialItem(
        icon: Icons.forum_outlined,
        label: 'Chats',
        color: Colors.deepPurple,
        onTap: () {
          _close();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
        },
      ),
      _SpeedDialItem(
        icon: Icons.store_rounded,
        label: 'Stores',
        color: Colors.teal,
        onTap: () {
          _close();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreListScreen()));
        },
      ),
      _SpeedDialItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        color: Colors.blueGrey,
        onTap: () {
          _close();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
      ),
    ];
  }

  OverlayEntry _createOverlayEntry(List<_SpeedDialItem> items) {
    // Find the exact location of the FAB to animate outward from it
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final fabCenter = Offset(offset.dx + size.width / 2, offset.dy + size.height / 2);
    final count = items.length;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Transparent tap-to-close overlay covering the entire screen
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
            
            // Half-circle white background for shortcuts
            Positioned(
              left: fabCenter.dx - 180, // Radius is 180, so shift left by 180
              top: fabCenter.dy - 180,  // Shift up by 180 so bottom edge hits the FAB center
              width: 360,
              height: 180,
              child: Transform.scale(
                alignment: Alignment.bottomCenter,
                scale: Curves.easeOutBack.transform(_controller.value),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(180),
                      topRight: Radius.circular(180),
                    ),
                    boxShadow: [
                      BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, -2)),
                    ],
                  ),
                ),
              ),
            ),

            // Speed-dial buttons (Radial Half-Circle Layout)
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;

              // Explicit, pixel-perfect coordinates to prevent label overlaps
              double dx = 0;
              double dy = 0;

              if (count == 4) {
                const positions = [
                  Offset(-120, -50),   // Bottom Left
                  Offset(-55, -135),   // Top Left
                  Offset(55, -135),    // Top Right
                  Offset(120, -50),    // Bottom Right
                ];
                dx = positions[i].dx;
                dy = positions[i].dy;
              } else if (count == 3) {
                const positions = [
                  Offset(-100, -70),   // Left
                  Offset(0, -140),     // Top Center
                  Offset(100, -70),    // Right
                ];
                dx = positions[i].dx;
                dy = positions[i].dy;
              } else {
                // Fallback for any other count
                final double startAngle = 160 * math.pi / 180;
                final double endAngle = 20 * math.pi / 180;
                final double angle = count > 1 
                    ? startAngle - (i * (startAngle - endAngle) / (count - 1))
                    : math.pi / 2;
                final double radius = 125.0; 
                dx = radius * math.cos(angle);
                dy = -radius * math.sin(angle);
              }

              return Positioned(
                // Position a generous 200x200 box centered exactly on the calculated point
                left: fabCenter.dx + dx - 100, 
                top: fabCenter.dy + dy - 100,
                width: 200,
                height: 200,
                child: Opacity(
                  opacity: Curves.easeOut.transform(_controller.value),
                  child: Transform.scale(
                    scale: 0.5 + (0.5 * Curves.easeOutBack.transform(_controller.value)),
                    child: Center(
                      child: Material(
                        type: MaterialType.transparency,
                        child: _SpeedDialButton(item: item),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // The animated FAB drawn ON TOP of the white half-circle
            Positioned(
              left: fabCenter.dx - 30,
              top: fabCenter.dy - 30,
              width: 60,
              height: 60,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Color.lerp(Colors.white, Colors.redAccent, _controller.value),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4)),
                      ],
                    ),
                    child: RawMaterialButton(
                      onPressed: _close,
                      shape: const CircleBorder(),
                      fillColor: Colors.transparent,
                      elevation: 0,
                      child: Transform.rotate(
                        angle: (math.pi / 4) * _controller.value, // Rotates 45 degrees
                        child: Icon(
                          Icons.add,
                          size: 32,
                          color: Color.lerp(AppTheme.secondaryColor, Colors.white, _controller.value),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isOpen ? 0.0 : 1.0, // Hide the original FAB completely when the overlay is active
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: RawMaterialButton(
          onPressed: _toggle,
          shape: const CircleBorder(),
          fillColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            size: 32,
            color: AppTheme.secondaryColor,
          ),
        ),
      ),
    );
  }
}

class _SpeedDialItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SpeedDialItem({required this.icon, required this.label, required this.color, required this.onTap});
}

class _SpeedDialButton extends StatelessWidget {
  final _SpeedDialItem item;
  const _SpeedDialButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Center: Icon circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          // Label chip below icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Text(
              item.label, 
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
