import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/sentiment/presentation/pages/api_test_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive boxes
  await Future.wait([
    Hive.openBox(AppConstants.watchlistBoxName),
    Hive.openBox(AppConstants.settingsBoxName),
    Hive.openBox(AppConstants.cacheBoxName),
    Hive.openBox(AppConstants.searchHistoryBoxName),
  ]);

  // Initialize dependency injection
  await di.init();

  // Register Hive boxes in DI
  await di.registerHiveBoxes();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // Use API test home page to access both MarketAux and Finnhub tests
      home: const ApiTestHomePage(),
    );
  }
}
