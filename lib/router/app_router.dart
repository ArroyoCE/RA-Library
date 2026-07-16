// lib/router/app_router.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:retroachievements_library/screens/about_screen.dart';
import 'package:retroachievements_library/screens/achievements/achievements_screen.dart';
import 'package:retroachievements_library/screens/auth/login_screen.dart';
import 'package:retroachievements_library/screens/consoles/consoles_screen.dart';
import 'package:retroachievements_library/screens/dashboard/dashboard_screen.dart';
import 'package:retroachievements_library/screens/game_data/game_data_screen.dart';
import 'package:retroachievements_library/screens/games/games_screen.dart';
import 'package:retroachievements_library/screens/hash_check/hash_check_screen.dart';
import 'package:retroachievements_library/screens/main_app_screen.dart';
import 'package:retroachievements_library/screens/settings_screen.dart';
import 'package:retroachievements_library/screens/splash_screen.dart';

// Root navigator key
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Individual navigator keys for each tab
final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
final _gamesNavigatorKey = GlobalKey<NavigatorState>();
final _achievementsNavigatorKey = GlobalKey<NavigatorState>();
final _hashCheckNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

GoRoute _buildGameDetailRoute({
  required String name,
  required String navigationSource,
}) {
  return GoRoute(
    path: 'game/:gameId',
    name: name,
    pageBuilder: (context, state) {
      final gameId = state.pathParameters['gameId'] ?? '0';
      final title = state.uri.queryParameters['title'] ?? 'Game';
      final iconPath = state.uri.queryParameters['icon'] ?? '';
      final consoleName = state.uri.queryParameters['console'] ?? '';

      return NoTransitionPage(
        child: GameDataScreen(
          gameId: gameId,
          title: title,
          iconPath: iconPath,
          consoleName: consoleName,
          navigationSource: navigationSource,
        ),
      );
    },
  );
}

// Provider that exposes the GoRouter instance
final appRouterProvider = Provider<GoRouter>((ref) {
  final authStateNotifier = ref.watch(authStateProvider.notifier);

  return GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authStateNotifier.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final userState = ref.read(authStateProvider);
      final isLoggedIn = userState.isAuthenticated;
      final location = state.matchedLocation;

      final isLogging = location == '/login';
      final isSplash = location == '/splash';
      final isAbout = location == '/about';

      // If we're in the splash screen, don't redirect
      if (isSplash) {
        return null;
      }

      // If not logged in and not on an auth page, redirect to login
      if (!isLoggedIn && !isLogging && !isAbout) {
        return '/login';
      }

      // If logged in and on an auth page, redirect to dashboard
      if (isLoggedIn && isLogging) {
        return '/dashboard';
      }

      // If logged in and at root path, redirect to dashboard
      if (isLoggedIn && location == '/') {
        return '/dashboard';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // About screen (accessible without login)
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),

      // Main app shell with sidebar navigation - using StatefulShellRoute instead of ShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainAppScreen(navigationShell: navigationShell);
        },
        branches: [
          // Dashboard branch
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: DashboardScreen(child: DashboardContent()),
                    ),
                routes: [
                  // Game data screen accessible from dashboard
                  _buildGameDetailRoute(
                    name: 'dashboard_game_details',
                    navigationSource: 'dashboard',
                  ),
                ],
              ),
            ],
          ),

          // Games branch
          StatefulShellBranch(
            navigatorKey: _gamesNavigatorKey,
            routes: [
              GoRoute(
                path: '/games',
                name: 'games',
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: ConsolesScreen(child: GamesContent()),
                  );
                },
                routes: [
                  GoRoute(
                    path: ':consoleId',
                    name: 'games_detail',
                    pageBuilder: (context, state) {
                      final consoleId =
                          int.tryParse(
                            state.pathParameters['consoleId'] ?? '0',
                          ) ??
                          0;
                      final consoleName =
                          state.uri.queryParameters['name'] ?? 'Console';
                      return NoTransitionPage(
                        child: GamesScreen(
                          consoleId: consoleId,
                          consoleName: consoleName,
                        ),
                      );
                    },
                    routes: [
                      // Game data screen as child of games/:consoleId
                      _buildGameDetailRoute(
                        name: 'game_details',
                        navigationSource: 'games',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Achievements branch
          StatefulShellBranch(
            navigatorKey: _achievementsNavigatorKey,
            routes: [
              GoRoute(
                path: '/achievements',
                name: 'achievements',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: AchievementsScreen(child: AchievementsContent()),
                    ),
                routes: [
                  // Game data screen accessible from achievements
                  _buildGameDetailRoute(
                    name: 'achievements_game_details',
                    navigationSource: 'achievements',
                  ),
                ],
              ),
            ],
          ),

          // Hash Check branch
          StatefulShellBranch(
            navigatorKey: _hashCheckNavigatorKey,
            routes: [
              GoRoute(
                path: '/hash-check',
                name: 'hash_check',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: HashCheckScreen(child: HashCheckContent()),
                    ),
                routes: [
                  _buildGameDetailRoute(
                    name: 'hash_check_game_details',
                    navigationSource: 'hash_check',
                  ),
                ],
              ),
            ],
          ),

          // Settings branch
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: SettingsScreen(child: SettingsContent()),
                    ),
                routes: const [
                  // Add nested routes for Settings here if needed
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
        ),
  );
});

// Helper class to convert Stream to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
