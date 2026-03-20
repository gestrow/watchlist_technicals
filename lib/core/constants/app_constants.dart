class AppConstants {
  AppConstants._();

  static const String appName = 'Watchlist Technicals';
  static const String appVersion = '1.0.0';

  // Technical Indicator Periods
  static const int defaultRsiPeriod = 14;
  static const int defaultMacdFastPeriod = 12;
  static const int defaultMacdSlowPeriod = 26;
  static const int defaultMacdSignalPeriod = 9;
  static const int defaultBollingerPeriod = 20;
  static const double defaultBollingerStdDev = 2.0;
  static const int defaultSmaPeriod = 20;
  static const int defaultEmaPeriod = 12;

  // RSI Thresholds
  static const double rsiOverbought = 70.0;
  static const double rsiOversold = 30.0;

  // Common technical indicators
  static const List<String> technicalIndicators = [
    'RSI',
    'MACD',
    'SMA',
    'EMA',
    'Bollinger Bands',
    'Volume',
    'Stochastic',
    'ATR',
  ];

  // Timeframe Presets by Trading Style

  // Intraday Trading (Day Trading)
  static const List<String> intradayTimeframes = [
    '1m',
    '5m',
    '15m',
    '30m',
    '1H',
  ];

  // Swing Trading (Multi-day holds)
  static const List<String> swingTimeframes = [
    '1H',
    '4H',
    '1D',
    '1W',
  ];

  // Long-term/Position Trading
  static const List<String> longTermTimeframes = [
    '1D',
    '1W',
    '1M',
    '3M',
    '1Y',
  ];

  // All available timeframes
  static const List<String> allTimeframes = [
    '1m',
    '5m',
    '15m',
    '30m',
    '1H',
    '2H',
    '4H',
    '1D',
    '1W',
    '1M',
  ];

  // Finnhub resolution mapping (minutes, D, W, M)
  static const Map<String, String> finnhubResolution = {
    '1m': '1',
    '5m': '5',
    '15m': '15',
    '30m': '30',
    '1H': '60',
    '2H': '120',
    '4H': '240',
    '1D': 'D',
    '1W': 'W',
    '1M': 'M',
  };

  // Cache durations
  static const Duration quoteCacheDuration = Duration(seconds: 30);
  static const Duration profileCacheDuration = Duration(days: 7);
  static const Duration newsCacheDuration = Duration(hours: 4);
  static const Duration candleCacheDuration = Duration(minutes: 5);

  // Pagination
  static const int newsPageSize = 20;
  static const int maxWatchlistItems = 50;
  static const int maxRecentSearches = 10;

  // WebSocket
  static const int maxWebSocketSymbols = 50; // Finnhub free tier limit
  static const Duration webSocketReconnectDelay = Duration(seconds: 5);
  static const int maxWebSocketReconnectAttempts = 5;

  // Sentiment Thresholds (MarketAux sentiment score: -1 to 1)
  static const double sentimentPositiveThreshold = 0.2;
  static const double sentimentNegativeThreshold = -0.2;

  // Date Range Defaults
  static const int defaultNewsLookbackDays = 7;
  static const int defaultChartCandleCount = 100;

  // Hive Box Names
  static const String watchlistBoxName = 'watchlist';
  static const String settingsBoxName = 'settings';
  static const String cacheBoxName = 'cache';
  static const String searchHistoryBoxName = 'search_history';

  // Alpha Vantage Settings Keys (stored in settingsBoxName)
  static const String avModeKey = 'use_av_for_technicals';
  static const String avCallCountKey = 'av_call_count';
  static const String avCallDateKey = 'av_call_date';
  static const String avFreeTierKey = 'av_free_tier';
  static const int avDailyCallLimit = 25;
  /// Minimum ms between consecutive AV calls on the free tier (5 req/min = 12s).
  static const int avFreeMinIntervalMs = 13000;
  static const Duration fundamentalsCacheTtl = Duration(hours: 24);

  // Feature Flags
  static const bool enableWebSocket = true;
  static const bool enableAdvancedCharts = true;
  static const bool enableSentimentAnalysis = true;
}
