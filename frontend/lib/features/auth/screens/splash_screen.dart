import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          context.go('/home/dashboard');
        } else {
          context.go('/login');
        }
      },
      loading: () => context.go('/login'),
      error: (_, __) => context.go('/login'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: const Icon(
                Icons.eco,
                size: 80,
                color: Color(0xFF2E7D32),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            const Text(
              'Agrolith',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ).animate().fade(delay: 300.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 12),
            const Text(
              'कृषि मित्र — Your Smart Farming Assistant',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fade(delay: 600.ms, duration: 500.ms),
            const SizedBox(height: 8),
            const Text(
              'मेరు వ్యవసాయ మిత్రుడు | உங்கள் விவசாய நண்பன்',
              style: TextStyle(fontSize: 12, color: Colors.white54),
              textAlign: TextAlign.center,
            ).animate().fade(delay: 900.ms),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ).animate().fade(delay: 1000.ms),
            const SizedBox(height: 16),
            const Text(
              'Powered by Gemini AI',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ).animate().fade(delay: 1200.ms),
          ],
        ),
      ),
    );
  }
}
