import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/live_tv/live_tv_screen.dart';
import '../../presentation/screens/vod/vod_screen.dart';
import '../../presentation/screens/series/series_screen.dart';
import '../../presentation/screens/player/player_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

/// Application routes
class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String liveTV = '/live-tv';
  static const String vod = '/vod';
  static const String series = '/series';
  static const String player = '/player';
  static const String settings = '/settings';
}

/// Router configuration provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.liveTV,
        name: 'liveTV',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LiveTVScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vod,
        name: 'vod',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const VodScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.series,
        name: 'series',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SeriesScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.player}/:contentType/:contentId',
        name: 'player',
        pageBuilder: (context, state) {
          final contentType = state.pathParameters['contentType'] ?? '';
          final contentId = state.pathParameters['contentId'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          
          return MaterialPage(
            key: state.pageKey,
            child: PlayerScreen(
              contentType: contentType,
              contentId: contentId,
              contentData: extra,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.login),
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
