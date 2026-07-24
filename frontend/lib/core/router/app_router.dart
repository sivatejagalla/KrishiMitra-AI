import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/home_dashboard_screen.dart';
import '../../features/ai_chat/screens/ai_chat_screen.dart';
import '../../features/voice/screens/voice_assistant_screen.dart';
import '../../features/disease/screens/disease_detection_screen.dart';
import '../../features/weather/screens/weather_screen.dart';
import '../../features/schemes/screens/government_schemes_screen.dart';
import '../../features/market/screens/market_prices_screen.dart';
import '../../features/soil/screens/soil_health_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/history/screens/chat_history_screen.dart';
import '../../features/history/screens/chat_history_detail_screen.dart';
import '../../features/agri/screens/agri_menu_screen.dart';

// Notifier to refresh GoRouter when auth state changes
class _AuthRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  _AuthRouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

final _authRouterNotifierProvider = Provider((ref) => _AuthRouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_authRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      // Still loading — don't redirect, stay on current route
      if (authState.isLoading) return null;

      final isAuthenticated = authState.valueOrNull != null;
      final path = state.uri.path;

      final publicRoutes = ['/splash', '/login', '/register'];
      final isPublic = publicRoutes.any((r) => path.startsWith(r));

      if (!isAuthenticated && !isPublic) {
        return '/login';
      }
      if (isAuthenticated && (path == '/login' || path == '/register')) {
        return '/home/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/home/dashboard',
            builder: (context, state) => const HomeDashboardScreen(),
          ),
          GoRoute(
            path: '/home/chat',
            builder: (context, state) => const AIChatScreen(),
          ),
          GoRoute(
            path: '/home/tools',
            builder: (context, state) => const AgriMenuScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/voice',
        builder: (context, state) => const VoiceAssistantScreen(),
      ),
      GoRoute(
        path: '/disease',
        builder: (context, state) => const DiseaseDetectionScreen(),
      ),
      GoRoute(
        path: '/weather',
        builder: (context, state) => const WeatherScreen(),
      ),
      GoRoute(
        path: '/schemes',
        builder: (context, state) => const GovernmentSchemesScreen(),
      ),
      GoRoute(
        path: '/market',
        builder: (context, state) => const MarketPricesScreen(),
      ),
      GoRoute(
        path: '/soil',
        builder: (context, state) => const SoilHealthScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const ChatHistoryScreen(),
      ),
      GoRoute(
        path: '/history/:sessionId',
        builder: (context, state) => ChatHistoryDetailScreen(
          sessionId: state.pathParameters['sessionId'] ?? '',
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Route not found: ${state.uri.path}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Go to Dashboard'),
              onPressed: () => context.go('/home/dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});
