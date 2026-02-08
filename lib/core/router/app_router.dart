import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/sentiment/presentation/pages/sentiment_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/technicals/presentation/pages/technicals_page.dart';
import '../../features/watchlist/presentation/pages/watchlist_page.dart';
import '../../shared/widgets/app_navigation_bar.dart';
import '../di/injection_container.dart';
import '../services/navigation_persistence_service.dart';

/// Global navigator key for the root navigator.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Global navigator key for the shell navigator.
final shellNavigatorKey = GlobalKey<NavigatorState>();

/// Configuration class for the app router.
class AppRouterConfig {
  final GoRouter router;
  final NavigationPersistenceService? persistenceService;

  AppRouterConfig({
    required this.router,
    this.persistenceService,
  });
}

/// Creates and configures the app router with bottom navigation and persistence.
AppRouterConfig createRouterConfig() {
  NavigationPersistenceService? persistenceService;
  String initialLocation = '/watchlists';

  // Try to get persistence service and restore last route
  try {
    persistenceService = sl<NavigationPersistenceService>();
    final lastRoute = persistenceService.lastRoute;
    if (NavigationPersistenceService.isValidRoute(lastRoute)) {
      initialLocation = lastRoute;
    }
  } catch (_) {
    // Service not registered, use default location
  }

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          // Determine current index based on location
          final location = state.uri.path;
          int currentIndex = 0;
          if (location.startsWith('/technicals')) {
            currentIndex = 1;
          } else if (location.startsWith('/sentiment')) {
            currentIndex = 2;
          } else if (location.startsWith('/settings')) {
            currentIndex = 3;
          }

          // Persist the current route
          if (persistenceService != null &&
              NavigationPersistenceService.isValidRoute(location)) {
            persistenceService.saveRoute(location);
          }

          return AppShell(
            currentIndex: currentIndex,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/watchlists',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WatchlistPage(),
            ),
          ),
          GoRoute(
            path: '/technicals',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TechnicalsPage(),
            ),
          ),
          GoRoute(
            path: '/sentiment',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SentimentPage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );

  return AppRouterConfig(
    router: router,
    persistenceService: persistenceService,
  );
}

/// Creates router without persistence (for backward compatibility).
GoRouter createRouter() {
  return createRouterConfig().router;
}
