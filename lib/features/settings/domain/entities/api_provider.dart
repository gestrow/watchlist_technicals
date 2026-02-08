/// Enum representing supported API providers
enum ApiProvider {
  finnhub('Finnhub', 'finnhub_api_key'),
  marketaux('MarketAux', 'marketaux_api_key');

  final String displayName;
  final String storageKey;

  const ApiProvider(this.displayName, this.storageKey);

  /// Get the signup URL for this provider
  String get signupUrl {
    switch (this) {
      case ApiProvider.finnhub:
        return 'https://finnhub.io/register';
      case ApiProvider.marketaux:
        return 'https://www.marketaux.com/register';
    }
  }

  /// Get the API documentation URL
  String get docsUrl {
    switch (this) {
      case ApiProvider.finnhub:
        return 'https://finnhub.io/docs/api';
      case ApiProvider.marketaux:
        return 'https://www.marketaux.com/documentation';
    }
  }

  /// Get a description of the API
  String get description {
    switch (this) {
      case ApiProvider.finnhub:
        return 'Stock fundamentals, earnings, and company data';
      case ApiProvider.marketaux:
        return 'News articles with sentiment analysis';
    }
  }

  /// Get rate limit info
  String get rateLimitInfo {
    switch (this) {
      case ApiProvider.finnhub:
        return '60 calls/minute (Free tier)';
      case ApiProvider.marketaux:
        return '2500 calls/day (Basic plan)';
    }
  }
}
