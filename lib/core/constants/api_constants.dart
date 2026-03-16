class ApiConstants {
  ApiConstants._();

  // Finnhub API (Real-time US stocks, WebSocket streaming, 60 calls/min free)
  static const String finnhubBaseUrl = 'https://finnhub.io/api/v1';
  static const String finnhubApiKey = ''; // TODO: Add your Finnhub API key
  static const String finnhubWebSocketUrl = 'wss://ws.finnhub.io';

  // Finnhub Endpoints
  static const String finnhubQuote = '/quote';
  static const String finnhubProfile = '/stock/profile2';
  static const String finnhubPeers = '/stock/peers';
  static const String finnhubCompanyNews = '/company-news';
  static const String finnhubEarnings = '/stock/earnings';
  static const String finnhubEarningsCalendar = '/calendar/earnings';
  static const String finnhubCandles = '/stock/candle';
  static const String finnhubRecommendation = '/stock/recommendation';
  static const String finnhubSymbolSearch = '/search';

  // MarketAux API (News & Sentiment, 100 calls/day free, 2,500/day for $29/mo)
  static const String marketAuxBaseUrl = 'https://api.marketaux.com/v1';
  static const String marketAuxApiKey = ''; // TODO: Add your MarketAux API key

  // MarketAux Endpoints
  static const String marketAuxNews = '/news/all';
  static const String marketAuxEntitySearch = '/entity/search';

  // Yahoo Finance (Unofficial - Use for prototyping only, historical data)
  static const String yahooFinanceBaseUrl = 'https://query2.finance.yahoo.com';
  static const String yahooFinanceChartEndpoint = '/v8/finance/chart';

  // Alpha Vantage API (Daily & Intraday OHLCV, 25 calls/day free)
  static const String alphaVantageBaseUrl = 'https://www.alphavantage.co';
  static const String alphaVantageQuery = '/query';

  // Twelve Data API (100+ technical indicators, 800/day free, $29/mo for Grow plan)
  static const String twelveDataBaseUrl = 'https://api.twelvedata.com';
  static const String twelveDataApiKey = ''; // TODO: Add your Twelve Data API key

  // Twelve Data Endpoints
  static const String twelveDataTimeSeries = '/time_series';
  static const String twelveDataRsi = '/rsi';
  static const String twelveDataMacd = '/macd';
  static const String twelveDataBbands = '/bbands';
  static const String twelveDataSma = '/sma';
  static const String twelveDataEma = '/ema';

  // Rate Limits
  static const int finnhubRateLimitPerMinute = 60;
  static const int marketAuxRateLimitPerDay = 100; // Free tier
  static const int twelveDataRateLimitPerDay = 800; // Free tier
  static const int alphaVantageRateLimitPerDay = 25; // Free tier

  // Headers
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
