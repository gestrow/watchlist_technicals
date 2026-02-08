import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart' as di;
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

    // Register preferences and navigation service
    await di.registerPreferences();

    // Register Hive boxes in DI
    await di.registerHiveBoxes();

    // Initialize connectivity service
    await di.sl<ConnectivityService>().init();

    runApp(const MyApp());
  }, (error, stack) {
    // Handle uncaught async errors
    debugPrint('Uncaught async error: $error');
    debugPrint('Stack trace: $stack');
  });
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
