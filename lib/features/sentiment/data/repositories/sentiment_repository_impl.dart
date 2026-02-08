import '../../domain/entities/company_profile.dart';
import '../../domain/entities/earnings.dart';
import '../../domain/entities/earnings_calendar_entry.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/stock_quote.dart';
import '../../domain/repositories/sentiment_repository.dart';
import '../datasources/finnhub_api.dart';
import '../datasources/marketaux_api.dart';

/// Implementation of [SentimentRepository] using Finnhub and MarketAux APIs.
class SentimentRepositoryImpl implements SentimentRepository {
  final FinnhubApi _finnhubApi;
  final MarketAuxApi? _marketAuxApi;

  SentimentRepositoryImpl({
    required FinnhubApi finnhubApi,
    MarketAuxApi? marketAuxApi,
  })  : _finnhubApi = finnhubApi,
        _marketAuxApi = marketAuxApi;

  @override
  Future<CompanyProfile> getCompanyProfile(String symbol) async {
    final model = await _finnhubApi.getCompanyProfile(symbol);
    return CompanyProfile.fromModel(model);
  }

  @override
  Future<StockQuote> getQuote(String symbol) async {
    final model = await _finnhubApi.getQuote(symbol);
    return StockQuote.fromModel(model);
  }

  @override
  Future<List<String>> getPeers(String symbol) async {
    return await _finnhubApi.getPeers(symbol);
  }

  @override
  Future<List<NewsArticle>> getNews(String symbol, {int days = 7}) async {
    if (_marketAuxApi == null) {
      return [];
    }

    try {
      final models = await _marketAuxApi.getRecentNews(symbol, days: days);
      return models.map((m) => NewsArticle.fromModel(m)).toList();
    } catch (e) {
      // Return empty list if news fetch fails (non-critical)
      print('[SentimentRepository] Failed to fetch news: $e');
      return [];
    }
  }

  @override
  Future<List<Earnings>> getEarningsSurprises(String symbol) async {
    try {
      final models = await _finnhubApi.getEarningsSurprises(symbol);
      // Return last 4 quarters
      final earnings = models.map((m) => Earnings.fromModel(m)).toList();
      return earnings.take(4).toList();
    } catch (e) {
      print('[SentimentRepository] Failed to fetch earnings: $e');
      return [];
    }
  }

  @override
  Future<List<EarningsCalendarEntry>> getEarningsCalendar(
    String symbol, {
    int days = 30,
  }) async {
    try {
      final now = DateTime.now();
      final to = now.add(Duration(days: days));
      final models = await _finnhubApi.getEarningsCalendar(
        symbol: symbol,
        from: now,
        to: to,
      );
      return models.map((m) => EarningsCalendarEntry.fromModel(m)).toList();
    } catch (e) {
      print('[SentimentRepository] Failed to fetch earnings calendar: $e');
      return [];
    }
  }

  @override
  Future<SentimentData> getSentimentData(String symbol) async {
    // Fetch all data concurrently for better performance
    // Group critical data (profile, quote, peers) and non-critical data (news, earnings)
    final results = await Future.wait([
      getCompanyProfile(symbol),
      getQuote(symbol),
      getPeers(symbol),
      getNews(symbol),
      getEarningsSurprises(symbol),
      getEarningsCalendar(symbol),
    ]);

    return SentimentData(
      profile: results[0] as CompanyProfile,
      quote: results[1] as StockQuote,
      peers: results[2] as List<String>,
      news: results[3] as List<NewsArticle>,
      earningsSurprises: results[4] as List<Earnings>,
      earningsCalendar: results[5] as List<EarningsCalendarEntry>,
    );
  }
}
