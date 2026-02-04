import 'package:dio/dio.dart';
import '../models/ohlc_model.dart';

/// Yahoo Finance API client for fetching historical OHLCV data
///
/// WARNING: This is an unofficial API. Yahoo can change endpoints without notice.
/// Use only for development/testing. For production, use official APIs.
///
/// Endpoint pattern: https://query2.finance.yahoo.com/v8/finance/chart/{symbol}
/// Rate limit: ~360 requests/hour (unofficial)
class YahooFinanceApi {
  final Dio _dio;
  static const String _baseUrl = 'https://query2.finance.yahoo.com';

  YahooFinanceApi({required Dio dio}) : _dio = dio {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
        logPrint: (obj) => print('[Yahoo Finance API] $obj'),
      ),
    );

    // Add retry interceptor for reliability
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          // Retry on network errors or server errors
          if (_shouldRetry(error)) {
            final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
            if (retryCount < 3) {
              final delaySeconds = (retryCount + 1) * 2; // 2s, 4s, 6s
              print(
                  '[Yahoo Finance API] Retrying in $delaySeconds seconds (attempt ${retryCount + 1}/3)');
              await Future.delayed(Duration(seconds: delaySeconds));

              // Retry the request
              final options = error.requestOptions;
              options.extra['retryCount'] = retryCount + 1;

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetry(DioException error) {
    // Retry on network errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on 5xx server errors (Yahoo can be unreliable)
    if (error.response?.statusCode != null &&
        error.response!.statusCode! >= 500) {
      return true;
    }

    // Retry on 429 rate limit
    if (error.response?.statusCode == 429) {
      return true;
    }

    return false;
  }

  /// Fetches historical OHLCV data for a given symbol
  ///
  /// [symbol] - Stock ticker symbol (e.g., 'AAPL', 'MSFT')
  /// [startDate] - Start date for historical data
  /// [endDate] - End date for historical data
  /// [interval] - Time interval: '1d' (daily), '1h' (hourly), '15m', '5m'
  ///
  /// Returns a list of OHLC candles sorted by date (oldest first)
  ///
  /// Throws:
  /// - [DioException] with 404 if symbol not found
  /// - [Exception] if response parsing fails
  Future<List<OhlcModel>> getHistoricalData(
    String symbol,
    DateTime startDate,
    DateTime endDate,
    String interval,
  ) async {
    try {
      // Convert dates to Unix epoch timestamps
      final period1 = (startDate.millisecondsSinceEpoch / 1000).floor();
      final period2 = (endDate.millisecondsSinceEpoch / 1000).floor();

      print(
          '[Yahoo Finance API] Fetching $interval data for $symbol from $startDate to $endDate');

      final response = await _dio.get(
        '/v8/finance/chart/$symbol',
        queryParameters: {
          'period1': period1,
          'period2': period2,
          'interval': interval,
          'includePrePost': false,
        },
      );

      // Parse the response
      return _parseHistoricalData(response.data, symbol);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Symbol not found: $symbol');
      }
      if (e.response?.statusCode == 429) {
        throw Exception(
            'Rate limit exceeded. Yahoo Finance API has usage limits (~360/hour).');
      }
      rethrow;
    }
  }

  List<OhlcModel> _parseHistoricalData(
      Map<String, dynamic> data, String symbol) {
    try {
      // Navigate through the response structure
      final chart = data['chart'];
      if (chart == null) {
        throw Exception('Invalid response: missing chart data');
      }

      final result = chart['result'];
      if (result == null || result.isEmpty) {
        throw Exception('Invalid response: missing result data');
      }

      final firstResult = result[0];

      // Check for error in response
      final error = chart['error'];
      if (error != null) {
        throw Exception('Yahoo Finance API error: ${error['description']}');
      }

      // Extract timestamps
      final timestamps = List<int>.from(firstResult['timestamp'] ?? []);
      if (timestamps.isEmpty) {
        throw Exception('No data available for symbol: $symbol');
      }

      // Extract indicators
      final indicators = firstResult['indicators'];
      if (indicators == null) {
        throw Exception('Invalid response: missing indicators');
      }

      final quote = indicators['quote'];
      if (quote == null || quote.isEmpty) {
        throw Exception('Invalid response: missing quote data');
      }

      final quoteData = quote[0];

      // Extract OHLCV arrays
      final opens = List<double?>.from(
          quoteData['open']?.map((e) => e?.toDouble()) ?? []);
      final highs = List<double?>.from(
          quoteData['high']?.map((e) => e?.toDouble()) ?? []);
      final lows =
          List<double?>.from(quoteData['low']?.map((e) => e?.toDouble()) ?? []);
      final closes = List<double?>.from(
          quoteData['close']?.map((e) => e?.toDouble()) ?? []);
      final volumes =
          List<int?>.from(quoteData['volume']?.map((e) => e?.toInt()) ?? []);

      // Validate array lengths
      if (timestamps.length != opens.length ||
          timestamps.length != highs.length ||
          timestamps.length != lows.length ||
          timestamps.length != closes.length ||
          timestamps.length != volumes.length) {
        throw Exception('Invalid response: array length mismatch');
      }

      // Combine into OhlcModel list
      final ohlcList = <OhlcModel>[];
      for (int i = 0; i < timestamps.length; i++) {
        // Skip candles with null values (market closed, etc.)
        if (opens[i] == null ||
            highs[i] == null ||
            lows[i] == null ||
            closes[i] == null ||
            volumes[i] == null) {
          continue;
        }

        ohlcList.add(
          OhlcModel(
            date: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
            open: opens[i]!,
            high: highs[i]!,
            low: lows[i]!,
            close: closes[i]!,
            volume: volumes[i]!,
          ),
        );
      }

      print(
          '[Yahoo Finance API] Successfully parsed ${ohlcList.length} candles');
      return ohlcList;
    } catch (e) {
      print('[Yahoo Finance API] Parse error: $e');
      throw Exception('Failed to parse Yahoo Finance response: $e');
    }
  }

  /// Convenience method to fetch recent daily data
  Future<List<OhlcModel>> getRecentDailyData(String symbol, int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    return getHistoricalData(symbol, startDate, endDate, '1d');
  }
}
