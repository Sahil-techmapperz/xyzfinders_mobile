import 'package:flutter/material.dart';
import '../../widgets/auth/login_view.dart';
import '../../widgets/auth/register_view.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
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
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoginView(
                  onToggleView: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  onSuccess: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
