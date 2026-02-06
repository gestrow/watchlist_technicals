import '../entities/company_profile.dart';
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

  /// Fetches all sentiment data for a symbol in one call.
  ///
  /// This is a convenience method that fetches profile, quote, and peers
  /// concurrently for better performance.
  ///
  /// Returns a [SentimentData] containing all fetched data.
  Future<SentimentData> getSentimentData(String symbol);
}

/// Container for all sentiment-related data for a symbol.
class SentimentData {
  final CompanyProfile profile;
  final StockQuote quote;
  final List<String> peers;

  const SentimentData({
    required this.profile,
    required this.quote,
    required this.peers,
  });
}
