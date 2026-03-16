import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/app_constants.dart' as constants;
import 'core/di/injection_container.dart' as di;
import 'core/services/av_call_tracker.dart';
import 'core/router/app_router.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'features/watchlist/data/models/watchlist_model.dart';
import 'features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'shared/widgets/error_boundary.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize global error handler
    GlobalErrorHandler.init(
      onError: (error, stack) {
        // Log errors (could send to crash reporting service)
        debugPrint('Global error: $error');
        debugPrint('Stack trace: $stack');
      },
    );

    // Initialize Hive
    await Hive.initFlutter();

    // Register Hive adapters
    Hive.registerAdapter(WatchlistModelAdapter());

    // Open Hive boxes
    await Future.wait([
      Hive.openBox<WatchlistModel>(AppConstants.watchlistBoxName),
      Hive.openBox(AppConstants.settingsBoxName),
      Hive.openBox(AppConstants.cacheBoxName),
      Hive.openBox(AppConstants.searchHistoryBoxName),
    ]);

    // Initialize dependency injection
    await di.init();

    // Seed API keys from --dart-define (used by run_dev.sh)
    await _seedApiKeysFromEnv();

    // Register preferences and navigation service
    await di.registerPreferences();

    // Register Hive boxes in DI
    await di.registerHiveBoxes();

    // Clean up stale AV cache entries from previous days
    _cleanupAvCache();

    // Reset AV call counter if new day
    di.sl<AvCallTracker>().resetIfNewDay();

    // Initialize connectivity service
    await di.sl<ConnectivityService>().init();

    runApp(const MyApp());
  }, (error, stack) {
    // Handle uncaught async errors
    debugPrint('Uncaught async error: $error');
    debugPrint('Stack trace: $stack');
  });
}

/// Seeds API keys into secure storage from --dart-define values.
/// Only writes if a key is provided and no key is already stored.
Future<void> _seedApiKeysFromEnv() async {
  const finnhubKey = String.fromEnvironment('FINNHUB_API_KEY');
  const marketauxKey = String.fromEnvironment('MARKETAUX_API_KEY');
  const alphaVantageKey = String.fromEnvironment('ALPHA_VANTAGE_API_KEY');

  if (finnhubKey.isEmpty && marketauxKey.isEmpty && alphaVantageKey.isEmpty) {
    return;
  }

  const storage = FlutterSecureStorage();

  if (finnhubKey.isNotEmpty) {
    final existing = await storage.read(key: 'finnhub_api_key');
    if (existing == null || existing.isEmpty) {
      await storage.write(key: 'finnhub_api_key', value: finnhubKey);
      debugPrint('Seeded Finnhub API key from environment');
    }
  }

  if (marketauxKey.isNotEmpty) {
    final existing = await storage.read(key: 'marketaux_api_key');
    if (existing == null || existing.isEmpty) {
      await storage.write(key: 'marketaux_api_key', value: marketauxKey);
      debugPrint('Seeded MarketAux API key from environment');
    }
  }

  if (alphaVantageKey.isNotEmpty) {
    final existing = await storage.read(key: 'alpha_vantage_api_key');
    if (existing == null || existing.isEmpty) {
      await storage.write(key: 'alpha_vantage_api_key', value: alphaVantageKey);
      debugPrint('Seeded Alpha Vantage API key from environment');
    }
  }
}

/// Deletes AV indicator cache entries from previous days.
/// AV's daily call limit resets each day, so stale cache should be cleared.
void _cleanupAvCache() {
  final cacheBox = Hive.box(constants.AppConstants.cacheBoxName);
  final now = DateTime.now();
  final todayStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final keysToDelete = <dynamic>[];
  for (final key in cacheBox.keys) {
    if (key is String && key.contains('_av_')) {
      final cached = cacheBox.get(key);
      if (cached is Map) {
        final cacheDate = cached['date'];
        if (cacheDate is String && cacheDate != todayStr) {
          keysToDelete.add(key);
        }
      }
    }
  }

  for (final key in keysToDelete) {
    cacheBox.delete(key);
  }

  if (keysToDelete.isNotEmpty) {
    debugPrint('Cleaned up ${keysToDelete.length} stale AV cache entries');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouterConfig _routerConfig;

  @override
  void initState() {
    super.initState();
    _routerConfig = createRouterConfig();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<WatchlistBloc>()..add(const LoadWatchlists()),
      child: StreamBuilder<bool>(
        stream: di.sl<ConnectivityService>().connectivityStream,
        initialData: di.sl<ConnectivityService>().isOnline,
        builder: (context, snapshot) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: _routerConfig.router,
            builder: (context, child) {
              return _AppWrapper(
                isOffline: !(snapshot.data ?? true),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

/// Wrapper widget that adds offline banner when needed.
class _AppWrapper extends StatelessWidget {
  final bool isOffline;
  final Widget child;

  const _AppWrapper({
    required this.isOffline,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isOffline) _OfflineBanner(),
        Expanded(child: child),
      ],
    );
  }
}

/// Simple offline banner.
class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[800],
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'You\'re offline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
