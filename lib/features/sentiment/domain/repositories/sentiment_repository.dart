import '../entities/company_profile.dart';
import '../entities/earnings.dart';
import '../entities/earnings_calendar_entry.dart';
import '../entities/news_article.dart';
import '../entities/stock_quote.dart';

/// Repository interface for sentiment-related data operations.
abstract class SentimentRepository {
  /// Fetches company profile for the given symbol.
  ///
  /// Returns [CompanyProfile] on success.
  /// Throws exception on failure.
  Future<CompanyProfile> getCompanyProfile(String symbol);

  /// Fetches current stock quote for the given symbol.
  ///
  /// Returns [StockQuote] on success.
  /// Throws exception on failure.
  Future<StockQuote> getQuote(String symbol);

  /// Fetches peer companies for the given symbol.
  ///
  /// Returns list of peer ticker symbols.
  /// Throws exception on failure.
  Future<List<String>> getPeers(String symbol);

  /// Fetches recent news for the given symbol.
  ///
  /// [days] - Number of days back to fetch (default: 7).
  /// Returns list of [NewsArticle] sorted by date (most recent first).
  /// Throws exception on failure.
  Future<List<NewsArticle>> getNews(String symbol, {int days = 7});

  /// Fetches earnings surprises for the given symbol.
  ///
  /// Returns list of [Earnings] for recent quarters.
  /// Throws exception on failure.
  Future<List<Earnings>> getEarningsSurprises(String symbol);

  /// Fetches earnings calendar for the given symbol.
  ///
  /// [days] - Number of days forward to fetch (default: 30).
  /// Returns list of [EarningsCalendarEntry] sorted by date.
  /// Throws exception on failure.
  Future<List<EarningsCalendarEntry>> getEarningsCalendar(
    String symbol, {
    int days = 30,
  });

  /// Fetches all sentiment data for a symbol in one call.
  ///
  /// This is a convenience method that fetches profile, quote, peers,
  /// news, and earnings concurrently for better performance.
  ///
  /// Returns a [SentimentData] containing all fetched data.
  Future<SentimentData> getSentimentData(String symbol);
}

/// Container for all sentiment-related data for a symbol.
class SentimentData {
  final CompanyProfile profile;
  final StockQuote quote;
  final List<String> peers;
  final List<NewsArticle> news;
  final List<Earnings> earningsSurprises;
  final List<EarningsCalendarEntry> earningsCalendar;

  const SentimentData({
    required this.profile,
    required this.quote,
    required this.peers,
    required this.news,
    required this.earningsSurprises,
    required this.earningsCalendar,
  });

  /// Calculates average sentiment score from news articles.
  double get averageSentiment {
    if (news.isEmpty) return 0.0;
    final sum = news.fold<double>(0, (acc, n) => acc + n.sentimentScore);
    return sum / news.length;
  }

  /// Returns the number of articles used for sentiment calculation.
  int get articleCount => news.length;

  /// Returns true if there are any upcoming earnings in the calendar.
  bool get hasUpcomingEarnings => earningsCalendar.isNotEmpty;

  /// Returns true if there's an earnings date within 7 days.
  bool get hasNearEarnings => earningsCalendar.any((e) => e.isNear);
}
