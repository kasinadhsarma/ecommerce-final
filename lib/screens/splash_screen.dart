import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/loyalty_provider.dart';
import 'home_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final loyaltyProvider =
        Provider.of<LoyaltyProvider>(context, listen: false);

    // Initialize authentication state
    await authProvider.initAuth();

    // Initialize products
    await productProvider.initProducts();

    // Initialize loyalty program
    await loyaltyProvider.initLoyalty();

    // Delay for at least 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to appropriate screen based on auth state
    if (authProvider.isAuthenticated) {
      _navigateToHome();
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // App name
            const Text(
              'ECommerce Shop',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),

            // Tagline
            const Text(
              'Shop Smarter, Not Harder',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}
