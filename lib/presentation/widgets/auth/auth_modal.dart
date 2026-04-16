import 'package:flutter/material.dart';
import 'login_view.dart';
import 'register_view.dart';

class AuthModal extends StatefulWidget {
  final bool initialIsLogin;

  const AuthModal({
    super.key,
    this.initialIsLogin = true,
  });

  static Future<void> show(BuildContext context, {bool initialIsLogin = true}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => AuthModal(initialIsLogin: initialIsLogin),
    );
  }

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  late bool _isLogin;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  void _toggleView() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.90,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        if (_isLogin)
                          LoginView(
                            onToggleView: _toggleView,
                            onSuccess: () => Navigator.pop(context),
                          )
                        else
                          RegisterView(
                            onToggleView: _toggleView,
                            onSuccess: () => Navigator.pop(context),
                          ),
                      ],
                    ),
                    
                    // Top Close Button
                    Positioned(
                      top: -8,
                      right: -8,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                              )
                            ]
                          ),
                          child: const Icon(Icons.close, size: 20, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
