import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/sentiment/data/datasources/marketaux_api.dart';
import '../../features/sentiment/data/datasources/finnhub_api.dart';
import '../../features/technicals/data/datasources/yahoo_finance_api.dart';
import '../../features/technicals/domain/calculators/sma_calculator.dart';
import '../../features/technicals/domain/calculators/ema_calculator.dart';
import '../../features/technicals/domain/calculators/rsi_calculator.dart';
import '../../features/technicals/domain/calculators/macd_calculator.dart';
import '../../features/technicals/domain/calculators/bollinger_bands_calculator.dart';
import '../../features/technicals/domain/calculators/vwap_calculator.dart';
import '../../features/technicals/domain/calculators/dominant_cycle_calculator.dart';
import '../constants/api_constants.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive boxes (will be opened in main.dart after Hive.initFlutter())
  // Boxes will be registered here after they are opened

  // Core - Dio HTTP Client
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: ApiConstants.jsonHeaders,
      ),
    );

    // Add logging interceptor
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  });

  // Core - Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Features
  _initSentimentFeature();
  _initTechnicalsFeature();
}

// Sentiment Feature - News & Sentiment Analysis (MarketAux + Finnhub)
void _initSentimentFeature() {
  // Data sources
  sl.registerLazySingleton<MarketAuxApi>(
    () => MarketAuxApi(
      dio: sl(),
      secureStorage: sl(),
    ),
  );

  sl.registerLazySingleton<FinnhubApi>(
    () => FinnhubApi(
      dio: sl(),
      secureStorage: sl(),
    ),
  );
}

// Technicals Feature - Historical OHLCV data for technical calculations
void _initTechnicalsFeature() {
  // Data sources
  sl.registerLazySingleton<YahooFinanceApi>(
    () => YahooFinanceApi(
      dio: sl(),
    ),
  );

  // Calculators
  sl.registerLazySingleton<SmaCalculator>(() => SmaCalculator());
  sl.registerLazySingleton<EmaCalculator>(() => EmaCalculator());
  sl.registerLazySingleton<RsiCalculator>(() => RsiCalculator());
  sl.registerLazySingleton<MacdCalculator>(() => MacdCalculator());
  sl.registerLazySingleton<BollingerBandsCalculator>(() => BollingerBandsCalculator());
  sl.registerLazySingleton<VwapCalculator>(() => VwapCalculator());
  sl.registerLazySingleton<DominantCycleCalculator>(() => DominantCycleCalculator());
  sl.registerLazySingleton<DominantCycleFacade>(() => DominantCycleFacade());
}

// Feature-specific initialization functions will be added here
// Example:
// void _initWatchlistFeature() {
//   // BLoC
//   sl.registerFactory(() => WatchlistBloc(getWatchlist: sl()));
//
//   // Use cases
//   sl.registerLazySingleton(() => GetWatchlist(sl()));
//
//   // Repository
//   sl.registerLazySingleton<WatchlistRepository>(
//     () => WatchlistRepositoryImpl(
//       remoteDataSource: sl(),
//       localDataSource: sl(),
//     ),
//   );
//
//   // Data sources
//   sl.registerLazySingleton<WatchlistRemoteDataSource>(
//     () => WatchlistRemoteDataSourceImpl(dio: sl()),
//   );
//
//   sl.registerLazySingleton<WatchlistLocalDataSource>(
//     () => WatchlistLocalDataSourceImpl(box: sl()),
//   );
// }

Future<void> registerHiveBoxes() async {
  // Register Hive boxes after they are opened
  // This should be called from main.dart after opening boxes
  // Example:
  // sl.registerLazySingleton<Box>(() => Hive.box('watchlist'), instanceName: 'watchlist');
}
