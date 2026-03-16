import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/ohlc_model.dart';

/// Alpha Vantage API client for fetching OHLCV data
/// Free tier: 25 API calls/day
class AlphaVantageApi {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AlphaVantageApi({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = ApiConstants.alphaVantageBaseUrl;
    _dio.options.connectTimeout = ApiConstants.connectionTimeout;
    _dio.options.receiveTimeout = ApiConstants.receiveTimeout;

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
        logPrint: (obj) => print('[Alpha Vantage API] $obj'),
      ),
    );
  }

  /// Check if the API key is configured
  Future<bool> get isConfigured async {
    final key = await _secureStorage.read(key: 'alpha_vantage_api_key');
    return key != null && key.isNotEmpty;
  }

  /// Fetch daily OHLCV data for a symbol
  ///
  /// [symbol] - Stock ticker symbol (e.g., "AAPL")
  /// [outputSize] - "compact" (last 100 days) or "full" (20+ years)
  ///
  /// Returns list of [OhlcModel] sorted oldest first
  Future<List<OhlcModel>> getDailyData(
    String symbol, {
    String outputSize = 'compact',
  }) async {
    final apiKey = await _secureStorage.read(key: 'alpha_vantage_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Alpha Vantage API key not configured');
    }

    try {
      print('[Alpha Vantage API] Fetching daily data for $symbol');

      final response = await _dio.get(
        ApiConstants.alphaVantageQuery,
        queryParameters: {
          'function': 'TIME_SERIES_DAILY',
          'symbol': symbol.toUpperCase(),
          'outputsize': outputSize,
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return _parseDailyData(response.data, symbol);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Unexpected status code: ${response.statusCode}',
          type: DioExceptionType.badResponse,
          response: response,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      print('[Alpha Vantage API] Error: $e');
      rethrow;
    }
  }

  /// Fetch historical daily data filtered by date range
  Future<List<OhlcModel>> getHistoricalData(
    String symbol,
    DateTime startDate,
    DateTime endDate,
    String interval,
  ) async {
    // For daily interval, use TIME_SERIES_DAILY
    // For intraday intervals, use TIME_SERIES_INTRADAY (future use)
    if (interval != '1d') {
      throw Exception(
        'Alpha Vantage fallback currently supports daily interval only. '
        'Requested: $interval',
      );
    }

    final allCandles = await getDailyData(symbol, outputSize: 'compact');

    // Filter to requested date range
    return allCandles
        .where((c) =>
            !c.date.isBefore(startDate) &&
            !c.date.isAfter(endDate.add(const Duration(days: 1))))
        .toList();
  }

  List<OhlcModel> _parseDailyData(Map<String, dynamic> data, String symbol) {
    _checkForErrors(data);

    final timeSeries = data['Time Series (Daily)'] as Map<String, dynamic>?;
    if (timeSeries == null || timeSeries.isEmpty) {
      throw Exception('No daily data available for symbol: $symbol');
    }

    final candles = <OhlcModel>[];

    for (final entry in timeSeries.entries) {
      final dateStr = entry.key;
      final values = entry.value as Map<String, dynamic>;

      final date = DateTime.parse(dateStr);
      final open = double.tryParse(values['1. open']?.toString() ?? '');
      final high = double.tryParse(values['2. high']?.toString() ?? '');
      final low = double.tryParse(values['3. low']?.toString() ?? '');
      final close = double.tryParse(values['4. close']?.toString() ?? '');
      final volume = int.tryParse(values['5. volume']?.toString() ?? '');

      if (open != null &&
          high != null &&
          low != null &&
          close != null &&
          volume != null) {
        candles.add(OhlcModel(
          date: date,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ));
      }
    }

    // Alpha Vantage returns newest first; sort oldest first to match Yahoo
    candles.sort((a, b) => a.date.compareTo(b.date));

    print(
      '[Alpha Vantage API] Parsed ${candles.length} daily candles for $symbol',
    );
    return candles;
  }

  // ---------------------------------------------------------------------------
  // Technical Indicator Endpoints
  // ---------------------------------------------------------------------------

  /// Reads the API key or throws.
  Future<String> _requireApiKey() async {
    final apiKey = await _secureStorage.read(key: 'alpha_vantage_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Alpha Vantage API key not configured');
    }
    return apiKey;
  }

  /// Validates an AV response for error / rate-limit messages.
  void _checkForErrors(Map<String, dynamic> data) {
    if (data.containsKey('Error Message')) {
      throw Exception('Alpha Vantage error: ${data['Error Message']}');
    }
    if (data.containsKey('Note')) {
      throw Exception(
        'Alpha Vantage rate limit reached (25/day): ${data['Note']}',
      );
    }
    if (data.containsKey('Information')) {
      throw Exception('Alpha Vantage: ${data['Information']}');
    }
  }

  /// Fetch RSI indicator values keyed by date string.
  Future<Map<String, double>> getRSI(
    String symbol, {
    int timePeriod = 14,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final apiKey = await _requireApiKey();
    final response = await _dio.get(
      ApiConstants.alphaVantageQuery,
      queryParameters: {
        'function': 'RSI',
        'symbol': symbol.toUpperCase(),
        'interval': interval,
        'time_period': timePeriod.toString(),
        'series_type': seriesType,
        'apikey': apiKey,
      },
    );

    final data = response.data as Map<String, dynamic>;
    _checkForErrors(data);

    final analysis =
        data['Technical Analysis: RSI'] as Map<String, dynamic>? ?? {};
    return analysis.map((date, values) {
      final v = values as Map<String, dynamic>;
      return MapEntry(date, double.parse(v['RSI'] as String));
    });
  }

  /// Fetch EMA indicator values keyed by date string.
  Future<Map<String, double>> getEMA(
    String symbol, {
    int timePeriod = 12,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final apiKey = await _requireApiKey();
    final response = await _dio.get(
      ApiConstants.alphaVantageQuery,
      queryParameters: {
        'function': 'EMA',
        'symbol': symbol.toUpperCase(),
        'interval': interval,
        'time_period': timePeriod.toString(),
        'series_type': seriesType,
        'apikey': apiKey,
      },
    );

    final data = response.data as Map<String, dynamic>;
    _checkForErrors(data);

    final analysis =
        data['Technical Analysis: EMA'] as Map<String, dynamic>? ?? {};
    return analysis.map((date, values) {
      final v = values as Map<String, dynamic>;
      return MapEntry(date, double.parse(v['EMA'] as String));
    });
  }

  /// Fetch MACD indicator values keyed by date string.
  /// Each entry contains MACD, MACD_Signal, MACD_Hist.
  Future<Map<String, Map<String, double>>> getMACD(
    String symbol, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final apiKey = await _requireApiKey();
    final response = await _dio.get(
      ApiConstants.alphaVantageQuery,
      queryParameters: {
        'function': 'MACD',
        'symbol': symbol.toUpperCase(),
        'interval': interval,
        'series_type': seriesType,
        'fastperiod': fastPeriod.toString(),
        'slowperiod': slowPeriod.toString(),
        'signalperiod': signalPeriod.toString(),
        'apikey': apiKey,
      },
    );

    final data = response.data as Map<String, dynamic>;
    _checkForErrors(data);

    final analysis =
        data['Technical Analysis: MACD'] as Map<String, dynamic>? ?? {};
    return analysis.map((date, values) {
      final v = values as Map<String, dynamic>;
      return MapEntry(date, {
        'MACD': double.parse(v['MACD'] as String),
        'MACD_Signal': double.parse(v['MACD_Signal'] as String),
        'MACD_Hist': double.parse(v['MACD_Hist'] as String),
      });
    });
  }

  /// Fetch Bollinger Bands values keyed by date string.
  /// Each entry contains Real Upper Band, Real Middle Band, Real Lower Band.
  Future<Map<String, Map<String, double>>> getBBands(
    String symbol, {
    int timePeriod = 20,
    double nbDevUp = 2.0,
    double nbDevDn = 2.0,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final apiKey = await _requireApiKey();
    final response = await _dio.get(
      ApiConstants.alphaVantageQuery,
      queryParameters: {
        'function': 'BBANDS',
        'symbol': symbol.toUpperCase(),
        'interval': interval,
        'time_period': timePeriod.toString(),
        'series_type': seriesType,
        'nbdevup': nbDevUp.toString(),
        'nbdevdn': nbDevDn.toString(),
        'apikey': apiKey,
      },
    );

    final data = response.data as Map<String, dynamic>;
    _checkForErrors(data);

    final analysis = data['Technical Analysis: Bollinger Bands']
            as Map<String, dynamic>? ??
        {};
    return analysis.map((date, values) {
      final v = values as Map<String, dynamic>;
      return MapEntry(date, {
        'upper': double.parse(v['Real Upper Band'] as String),
        'middle': double.parse(v['Real Middle Band'] as String),
        'lower': double.parse(v['Real Lower Band'] as String),
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Fundamentals Endpoints
  // ---------------------------------------------------------------------------

  /// Fetch company overview for a symbol.
  Future<Map<String, dynamic>> getCompanyOverview(String symbol) async {
    final apiKey = await _requireApiKey();
    final response = await _dio.get(
      ApiConstants.alphaVantageQuery,
      queryParameters: {
        'function': 'OVERVIEW',
        'symbol': symbol.toUpperCase(),
        'apikey': apiKey,
      },
    );

    final data = response.data as Map<String, dynamic>;
    _checkForErrors(data);
    return data;
  }

  /// Fetch earnings data for a symbol.
  Future<Map<String, dynamic>> getEarnings(String symbol) async {
    final apiKey = await _requireApiKey();
    final response = await _dio.get(
      ApiConstants.alphaVantageQuery,
      queryParameters: {
        'function': 'EARNINGS',
        'symbol': symbol.toUpperCase(),
        'apikey': apiKey,
      },
    );

    final data = response.data as Map<String, dynamic>;
    _checkForErrors(data);
    return data;
  }

  /// Fetch income statement data for a symbol.
  Future<Map<String, dynamic>> getIncomeStatement(String symbol) async {
    final apiKey = await _requireApiKey();
    final response = await _dio.get(
      ApiConstants.alphaVantageQuery,
      queryParameters: {
        'function': 'INCOME_STATEMENT',
        'symbol': symbol.toUpperCase(),
        'apikey': apiKey,
      },
    );

    final data = response.data as Map<String, dynamic>;
    _checkForErrors(data);
    return data;
  }
}
