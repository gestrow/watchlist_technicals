import 'package:shared_preferences/shared_preferences.dart';

/// Service to persist and restore navigation state.
class NavigationPersistenceService {
  static const String _lastRouteKey = 'last_route';
  static const String _defaultRoute = '/watchlists';

  final SharedPreferences _prefs;

  NavigationPersistenceService({required SharedPreferences prefs})
      : _prefs = prefs;

  /// Get the last visited route.
  String get lastRoute => _prefs.getString(_lastRouteKey) ?? _defaultRoute;

  /// Save the current route.
  Future<void> saveRoute(String route) async {
    await _prefs.setString(_lastRouteKey, route);
  }

  /// Valid routes that can be persisted.
  static const validRoutes = [
    '/watchlists',
    '/technicals',
    '/sentiment',
    '/settings',
  ];

  /// Check if a route is valid for persistence.
  static bool isValidRoute(String route) {
    return validRoutes.contains(route);
  }
}
