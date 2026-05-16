import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GCColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Animation
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
            )
                .animate()
                .fade(duration: 800.ms)
                .scale(
                    delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack)
                .shimmer(delay: 1500.ms, duration: 1000.ms),

            const SizedBox(height: 24),

            // Text Animation
            const Text(
              'GoldenCare',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Playfair Display',
                color: GCColors.primary,
                letterSpacing: 1.2,
              ),
            ).animate().fade(delay: 600.ms, duration: 800.ms).slideY(
                begin: 0.3,
                end: 0,
                duration: 800.ms,
                curve: Curves.easeOutCubic),

            const SizedBox(height: 12),

            const Text(
              'Compassionate Care at Home',
              style: TextStyle(
                fontSize: 14,
                color: GCColors.mutedForeground,
                letterSpacing: 0.5,
              ),
            ).animate().fade(delay: 1200.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
