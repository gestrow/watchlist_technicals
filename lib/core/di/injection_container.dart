import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../features/sentiment/data/datasources/marketaux_api.dart';
import '../../features/sentiment/data/datasources/finnhub_api.dart';
import '../../features/sentiment/data/repositories/sentiment_repository_impl.dart';
import '../../features/sentiment/domain/repositories/sentiment_repository.dart';
import '../../features/technicals/data/datasources/yahoo_finance_api.dart';
import '../../features/technicals/domain/calculators/sma_calculator.dart';
import '../../features/technicals/domain/calculators/ema_calculator.dart';
import '../../features/technicals/domain/calculators/rsi_calculator.dart';
import '../../features/technicals/domain/calculators/macd_calculator.dart';
import '../../features/technicals/domain/calculators/bollinger_bands_calculator.dart';
import '../../features/technicals/domain/calculators/vwap_calculator.dart';
import '../../features/technicals/domain/calculators/dominant_cycle_calculator.dart';
import '../../features/technicals/domain/usecases/calculate_technicals_usecase.dart';
import '../../features/watchlist/data/models/watchlist_model.dart';
import '../../features/watchlist/data/repositories/watchlist_repository_impl.dart';
import '../../features/watchlist/domain/repositories/watchlist_repository.dart';
import '../../features/watchlist/presentation/bloc/watchlist_bloc.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

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
  _initWatchlistFeature();
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

  // Repository
  sl.registerLazySingleton<SentimentRepository>(
    () => SentimentRepositoryImpl(
      finnhubApi: sl<FinnhubApi>(),
      marketAuxApi: sl<MarketAuxApi>(),
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

  // Use cases - registered after Hive boxes are opened
}

// Watchlist Feature - Watchlist management with local storage
void _initWatchlistFeature() {
  // BLoC - Factory so each widget gets a fresh instance
  sl.registerFactory<WatchlistBloc>(
    () => WatchlistBloc(repository: sl()),
  );

  // Repository - Lazy singleton, will use registered Hive box
  sl.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(
      watchlistBox: sl<Box<WatchlistModel>>(instanceName: AppConstants.watchlistBoxName),
    ),
  );
}

Future<void> registerHiveBoxes() async {
  // Register typed Hive box for watchlists
  sl.registerLazySingleton<Box<WatchlistModel>>(
    () => Hive.box<WatchlistModel>(AppConstants.watchlistBoxName),
    instanceName: AppConstants.watchlistBoxName,
  );

  // Register cache box for technicals
  sl.registerLazySingleton<Box>(
    () => Hive.box(AppConstants.cacheBoxName),
    instanceName: AppConstants.cacheBoxName,
  );

  // Register CalculateTechnicalsUsecase (needs cache box)
  sl.registerLazySingleton<CalculateTechnicalsUsecase>(
    () => CalculateTechnicalsUsecase(
      api: sl<YahooFinanceApi>(),
      cacheBox: sl<Box>(instanceName: AppConstants.cacheBoxName),
    ),
  );
}
