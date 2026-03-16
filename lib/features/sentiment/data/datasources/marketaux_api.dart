import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/news_model.dart';

/// MarketAux API client for fetching news and sentiment data
/// Requires API key from flutter_secure_storage
/// Basic plan: 2500 requests/day, 20 articles/request
class MarketAuxApi {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  MarketAuxApi({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = ApiConstants.marketAuxBaseUrl;
    _dio.options.connectTimeout = ApiConstants.connectionTimeout;
    _dio.options.receiveTimeout = ApiConstants.receiveTimeout;

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[MarketAux API] $obj'),
      ),
    );

    // Add API key interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get API key from secure storage
          final apiKey = await _secureStorage.read(key: 'marketaux_api_key');

          if (apiKey == null || apiKey.isEmpty) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'MarketAux API key not found in secure storage',
                type: DioExceptionType.unknown,
              ),
            );
          }

          // Add API key to query parameters
          options.queryParameters['api_token'] = apiKey;
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle rate limiting
          if (error.response?.statusCode == 429) {
            print('[MarketAux API] Rate limit exceeded (2500 requests/day)');
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Rate limit exceeded. Try again later.',
                type: DioExceptionType.badResponse,
                response: error.response,
              ),
            );
          }

          // Handle invalid API key
          if (error.response?.statusCode == 401) {
            print('[MarketAux API] Invalid API key');
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Invalid MarketAux API key',
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

  /// Fetch news articles for a specific stock symbol
  ///
  /// [symbol] - Stock ticker symbol (e.g., "AAPL")
  /// [from] - Start date for news articles
  /// [to] - End date for news articles
  /// [limit] - Max articles per request (default: 20, max for Basic plan)
  ///
  /// Returns list of [NewsModel] with sentiment scores (-1 to +1)
  ///
  /// Throws [DioException] on network errors, rate limits, or invalid API key
  Future<List<NewsModel>> getNewsBySymbol(
    String symbol,
    DateTime from,
    DateTime to, {
    int limit = 20,
  }) async {
    try {
      // Validate limit for Basic plan
      if (limit > 20) {
        print('[MarketAux API] Warning: limit capped at 20 for Basic plan');
        limit = 20;
      }

      final response = await _dio.get(
        ApiConstants.marketAuxNews,
        queryParameters: {
          'symbols': symbol,
          'published_after': from.toUtc().toIso8601String().split('.').first,
          'published_before': to.toUtc().toIso8601String().split('.').first,
          'countries': 'us',
          'entity_types': 'equity',
          'limit': limit.toString(),
          'language': 'en',
          // Note: api_token will be added by interceptor
        },
      );

      // Parse response
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final articles = data['data'] as List<dynamic>? ?? [];

        print('[MarketAux API] Fetched ${articles.length} articles for $symbol');

        return articles
            .map((article) => NewsModel.fromJson(article as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Unexpected status code: ${response.statusCode}',
          type: DioExceptionType.badResponse,
          response: response,
        );
      }
    } on DioException catch (e) {
      // Handle network errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        print('[MarketAux API] Network timeout: ${e.message}');
        rethrow;
      }

      if (e.type == DioExceptionType.connectionError) {
        print('[MarketAux API] Connection error: ${e.message}');
        rethrow;
      }

      // Re-throw other errors
      rethrow;
    } catch (e) {
      print('[MarketAux API] Unexpected error: $e');
      rethrow;
    }
  }

  /// Get recent news for a symbol (last 7 days by default)
  Future<List<NewsModel>> getRecentNews(
    String symbol, {
    int days = 7,
    int limit = 20,
  }) async {
    final to = DateTime.now();
    final from = to.subtract(Duration(days: days));
    return getNewsBySymbol(symbol, from, to, limit: limit);
  }
}
