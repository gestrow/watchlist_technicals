import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/company_profile_model.dart';
import '../models/quote_model.dart';
import '../models/earnings_model.dart';
import '../models/earnings_calendar_model.dart';

/// Finnhub API client for fetching stock data
/// Requires API key from flutter_secure_storage
/// Free tier: 60 API calls/minute
class FinnhubApi {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Rate limiting: 60 calls per minute
  final Queue<DateTime> _requestTimestamps = Queue<DateTime>();
  static const int _maxCallsPerMinute = 60;
  static const Duration _rateLimitWindow = Duration(minutes: 1);

  // Simple in-memory cache
  final Map<String, _CacheEntry> _cache = {};

  FinnhubApi({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = ApiConstants.finnhubBaseUrl;
    _dio.options.connectTimeout = ApiConstants.connectionTimeout;
    _dio.options.receiveTimeout = ApiConstants.receiveTimeout;

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[Finnhub API] $obj'),
      ),
    );

    // Add API key interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get API key from secure storage
          final apiKey = await _secureStorage.read(key: 'finnhub_api_key');

          if (apiKey == null || apiKey.isEmpty) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Finnhub API key not found in secure storage',
                type: DioExceptionType.unknown,
              ),
            );
          }

          // Add API key to query parameters
          options.queryParameters['token'] = apiKey;
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle rate limiting with exponential backoff
          if (error.response?.statusCode == 429) {
            print('[Finnhub API] Rate limit exceeded (60 calls/minute)');

            // Attempt retry with exponential backoff
            final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
            if (retryCount < 3) {
              final delaySeconds = (retryCount + 1) * 2; // 2s, 4s, 6s
              print(
                  '[Finnhub API] Retrying in $delaySeconds seconds (attempt ${retryCount + 1}/3)');

              await Future.delayed(Duration(seconds: delaySeconds));

              error.requestOptions.extra['retryCount'] = retryCount + 1;

              // Retry the request
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }

            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Rate limit exceeded after 3 retries. Try again later.',
                type: DioExceptionType.badResponse,
                response: error.response,
              ),
            );
          }

          // Handle invalid API key
          if (error.response?.statusCode == 401) {
            print('[Finnhub API] Invalid API key');
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Invalid Finnhub API key',
                type: DioExceptionType.badResponse,
                response: error.response,
              ),
            );
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Rate limiting: Wait if necessary before making a request
  Future<void> _enforceRateLimit() async {
    final now = DateTime.now();

    // Remove timestamps older than the rate limit window
    _requestTimestamps
        .removeWhere((timestamp) => now.difference(timestamp) > _rateLimitWindow);

    // If we've hit the limit, wait until the oldest request falls outside the window
    if (_requestTimestamps.length >= _maxCallsPerMinute) {
      final oldestTimestamp = _requestTimestamps.first;
      final waitDuration =
          _rateLimitWindow - now.difference(oldestTimestamp) + Duration(milliseconds: 100);

      if (waitDuration.isNegative == false) {
        print(
            '[Finnhub API] Rate limit reached, waiting ${waitDuration.inMilliseconds}ms');
        await Future.delayed(waitDuration);
      }

      // Remove the oldest timestamp
      _requestTimestamps.removeFirst();
    }

    // Add current timestamp
    _requestTimestamps.add(DateTime.now());
  }

  /// Get cached value if available and not expired
  T? _getFromCache<T>(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      print('[Finnhub API] Cache hit: $key');
      return entry.value as T?;
    }
    return null;
  }

  /// Cache a value with TTL
  void _setCache(String key, dynamic value, Duration ttl) {
    _cache[key] = _CacheEntry(value, DateTime.now().add(ttl));
  }

  /// Fetch company profile for a stock symbol
  ///
  /// [symbol] - Stock ticker symbol (e.g., "AAPL")
  ///
  /// Returns [CompanyProfileModel] with company details
  /// Cache TTL: 1 hour
  ///
  /// Throws [DioException] on network errors, rate limits, or invalid API key
  Future<CompanyProfileModel> getCompanyProfile(String symbol) async {
    final cacheKey = 'profile_$symbol';

    // Check cache
    final cached = _getFromCache<CompanyProfileModel>(cacheKey);
    if (cached != null) return cached;

    try {
      await _enforceRateLimit();

      final response = await _dio.get(
        ApiConstants.finnhubProfile,
        queryParameters: {'symbol': symbol.toUpperCase()},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Check if response is empty (symbol not found)
        if (data.isEmpty || data['name'] == null) {
          throw DioException(
            requestOptions: response.requestOptions,
            error: 'Symbol not found: $symbol',
            type: DioExceptionType.badResponse,
            response: response,
          );
        }

        final profile = CompanyProfileModel.fromJson(data);

        // Cache for 1 hour
        _setCache(cacheKey, profile, Duration(hours: 1));

        print('[Finnhub API] Fetched profile for $symbol');
        return profile;
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
      print('[Finnhub API] Unexpected error in getCompanyProfile: $e');
      rethrow;
    }
  }

  /// Fetch real-time quote for a stock symbol
  ///
  /// [symbol] - Stock ticker symbol (e.g., "AAPL")
  ///
  /// Returns [QuoteModel] with current price and changes
  /// Cache TTL: 30 seconds
  ///
  /// Throws [DioException] on network errors, rate limits, or invalid API key
  Future<QuoteModel> getQuote(String symbol) async {
    final cacheKey = 'quote_$symbol';

    // Check cache
    final cached = _getFromCache<QuoteModel>(cacheKey);
    if (cached != null) return cached;

    try {
      await _enforceRateLimit();

      final response = await _dio.get(
        ApiConstants.finnhubQuote,
        queryParameters: {'symbol': symbol.toUpperCase()},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Check if response is valid (c = current price should exist and be non-zero)
        if (data['c'] == null || data['c'] == 0) {
          throw DioException(
            requestOptions: response.requestOptions,
            error: 'Invalid quote data for symbol: $symbol',
            type: DioExceptionType.badResponse,
            response: response,
          );
        }

        final quote = QuoteModel.fromJson(data);

        // Cache for 30 seconds
        _setCache(cacheKey, quote, Duration(seconds: 30));

        print('[Finnhub API] Fetched quote for $symbol');
        return quote;
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
      print('[Finnhub API] Unexpected error in getQuote: $e');
      rethrow;
    }
  }

  /// Fetch peer companies for a stock symbol
  ///
  /// [symbol] - Stock ticker symbol (e.g., "AAPL")
  ///
  /// Returns list of peer ticker symbols
  /// Cache TTL: 1 hour
  ///
  /// Throws [DioException] on network errors, rate limits, or invalid API key
  Future<List<String>> getPeers(String symbol) async {
    final cacheKey = 'peers_$symbol';

    // Check cache
    final cached = _getFromCache<List<String>>(cacheKey);
    if (cached != null) return cached;

    try {
      await _enforceRateLimit();

      final response = await _dio.get(
        ApiConstants.finnhubPeers,
        queryParameters: {'symbol': symbol.toUpperCase()},
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final peers = data.map((peer) => peer.toString()).toList();

        // Cache for 1 hour
        _setCache(cacheKey, peers, Duration(hours: 1));

        print('[Finnhub API] Fetched ${peers.length} peers for $symbol');
        return peers;
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
      print('[Finnhub API] Unexpected error in getPeers: $e');
      rethrow;
    }
  }

  /// Fetch earnings surprises for a stock symbol
  ///
  /// [symbol] - Stock ticker symbol (e.g., "AAPL")
  ///
  /// Returns list of [EarningsModel] (last 4 quarters for free tier)
  /// Cache TTL: 1 hour
  ///
  /// Throws [DioException] on network errors, rate limits, or invalid API key
  Future<List<EarningsModel>> getEarningsSurprises(String symbol) async {
    final cacheKey = 'earnings_$symbol';

    // Check cache
    final cached = _getFromCache<List<EarningsModel>>(cacheKey);
    if (cached != null) return cached;

    try {
      await _enforceRateLimit();

      final response = await _dio.get(
        ApiConstants.finnhubEarnings,
        queryParameters: {'symbol': symbol.toUpperCase()},
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final earnings = data
            .map((item) => EarningsModel.fromJson(item as Map<String, dynamic>))
            .toList();

        // Cache for 1 hour
        _setCache(cacheKey, earnings, Duration(hours: 1));

        print('[Finnhub API] Fetched ${earnings.length} earnings records for $symbol');
        return earnings;
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
      print('[Finnhub API] Unexpected error in getEarningsSurprises: $e');
      rethrow;
    }
  }

  /// Fetch earnings calendar
  ///
  /// [symbol] - Optional stock ticker symbol (e.g., "AAPL")
  /// [from] - Optional start date
  /// [to] - Optional end date
  ///
  /// Returns list of [EarningsCalendarModel]
  /// Cache TTL: 1 hour
  ///
  /// Throws [DioException] on network errors, rate limits, or invalid API key
  Future<List<EarningsCalendarModel>> getEarningsCalendar({
    String? symbol,
    DateTime? from,
    DateTime? to,
  }) async {
    final cacheKey =
        'earnings_calendar_${symbol ?? 'all'}_${from?.toIso8601String() ?? ''}_${to?.toIso8601String() ?? ''}';

    // Check cache
    final cached = _getFromCache<List<EarningsCalendarModel>>(cacheKey);
    if (cached != null) return cached;

    try {
      await _enforceRateLimit();

      final queryParams = <String, dynamic>{};
      if (symbol != null) queryParams['symbol'] = symbol.toUpperCase();
      if (from != null) {
        queryParams['from'] = _formatDate(from);
      }
      if (to != null) {
        queryParams['to'] = _formatDate(to);
      }

      final response = await _dio.get(
        ApiConstants.finnhubEarningsCalendar,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final earningsCalendar = data['earningsCalendar'] as List<dynamic>? ?? [];

        final calendar = earningsCalendar
            .map((item) =>
                EarningsCalendarModel.fromJson(item as Map<String, dynamic>))
            .toList();

        // Cache for 1 hour
        _setCache(cacheKey, calendar, Duration(hours: 1));

        print('[Finnhub API] Fetched ${calendar.length} earnings calendar entries');
        return calendar;
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
      print('[Finnhub API] Unexpected error in getEarningsCalendar: $e');
      rethrow;
    }
  }

  /// Format date to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Clear cache (useful for testing or forcing fresh data)
  void clearCache() {
    _cache.clear();
    print('[Finnhub API] Cache cleared');
  }
}

/// Cache entry with expiration
class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry(this.value, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
