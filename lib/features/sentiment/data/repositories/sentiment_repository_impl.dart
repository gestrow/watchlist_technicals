import '../../domain/entities/company_profile.dart';
import '../../domain/entities/stock_quote.dart';
import '../../domain/repositories/sentiment_repository.dart';
import '../datasources/finnhub_api.dart';

/// Implementation of [SentimentRepository] using Finnhub API.
class SentimentRepositoryImpl implements SentimentRepository {
  final FinnhubApi _finnhubApi;

  SentimentRepositoryImpl({
    required FinnhubApi finnhubApi,
  }) : _finnhubApi = finnhubApi;

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
  Future<SentimentData> getSentimentData(String symbol) async {
    // Fetch all data concurrently for better performance
    final results = await Future.wait([
      getCompanyProfile(symbol),
      getQuote(symbol),
      getPeers(symbol),
    ]);

    return SentimentData(
      profile: results[0] as CompanyProfile,
      quote: results[1] as StockQuote,
      peers: results[2] as List<String>,
    );
  }
}
