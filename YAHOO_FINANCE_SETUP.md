# Yahoo Finance API Setup Guide

This guide covers the Yahoo Finance API integration for fetching historical OHLCV (Open, High, Low, Close, Volume) data needed for technical analysis calculations.

## Overview

The Yahoo Finance API provides free historical market data for stocks. This implementation uses the unofficial `query2.finance.yahoo.com` endpoint.

### Implemented Features

- **Historical OHLCV Data**: Fetch daily, hourly, or intraday candlestick data
- **Date Range Queries**: Request data between specific start and end dates
- **Multiple Intervals**: Support for '1d' (daily), '1h' (hourly), '15m', '5m' intervals
- **Retry Logic**: Automatic retries with exponential backoff (3 attempts: 2s, 4s, 6s)
- **Error Handling**: Symbol validation, rate limit handling, parse error recovery

### Technical Implementation

- Retry logic: 3 attempts with exponential backoff (2s, 4s, 6s)
- Timeout: 30 seconds for connection and receive
- Clean Architecture with DI (GetIt)
- Freezed models with JSON serialization
- Null-safe parsing (skips candles with missing data)

## IMPORTANT WARNING

**Yahoo Finance API is UNOFFICIAL and UNRELIABLE:**

- Yahoo can change endpoints without notice
- The API broke multiple times in 2024-2025
- Commercial use violates Yahoo's Terms of Service
- Yahoo actively blocks heavy usage and can ban IP ranges
- No official documentation or support

**Use ONLY for:**
- Development and testing
- Personal projects
- Prototyping before switching to official APIs

**DO NOT use for:**
- Production applications
- Commercial products
- Apps distributed to users

For production, use official APIs like:
- Finnhub (60 calls/min free tier)
- Twelve Data ($29/month for historical data)
- Alpha Vantage (25 calls/day free tier)
- Polygon.io

## Setup Steps

### 1. No API Key Required

Unlike Finnhub and MarketAux, Yahoo Finance API doesn't require an API key. However, this also means:
- No rate limit guarantees
- Yahoo can block your IP at any time
- Unofficial rate limit: ~360 requests/hour (varies)

### 2. Test the Integration

1. Run the app:
   ```bash
   flutter run
   ```

2. From the API Test Dashboard, tap "Yahoo Finance API (Historical OHLCV)"
3. Tap "Test Yahoo Finance API (AAPL 60d)"
4. You should see output like:

```
Testing Yahoo Finance API...

Fetching 60 days of daily data for AAPL...
WARNING: Yahoo Finance API is unofficial and for testing only

✓ Successfully fetched 60 candles

=== FIRST 5 CANDLES ===
2024-12-04 | O:$242.00 H:$245.50 L:$241.00 C:$243.50 V:45,234,567
2024-12-05 | O:$243.50 H:$246.00 L:$242.00 C:$245.00 V:42,123,456
...

=== LAST 5 CANDLES ===
2025-02-01 | O:$235.00 H:$238.00 L:$234.00 C:$237.50 V:38,456,789
2025-02-04 | O:$237.50 H:$240.00 L:$236.00 C:$239.00 V:41,234,567
...

=== SUMMARY ===
Total candles: 60
Date range: 2024-12-04 to 2025-02-04
Highest close: $248.50
Lowest close: $225.00
Avg volume: 42,345,678

✅ All tests completed successfully!
```

## API Usage Examples

### Get Historical Daily Data

```dart
import 'package:watchlist_technicals/core/di/injection_container.dart';
import 'package:watchlist_technicals/features/technicals/data/datasources/yahoo_finance_api.dart';

final yahooApi = sl<YahooFinanceApi>();

try {
  final startDate = DateTime.now().subtract(Duration(days: 60));
  final endDate = DateTime.now();

  final candles = await yahooApi.getHistoricalData(
    'AAPL',
    startDate,
    endDate,
    '1d', // Daily interval
  );

  for (final candle in candles) {
    print('${candle.date}: Close \$${candle.close}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Get Recent Daily Data (Convenience Method)

```dart
try {
  // Get last 30 days of daily data
  final candles = await yahooApi.getRecentDailyData('AAPL', 30);

  print('Fetched ${candles.length} candles');
  print('Latest: ${candles.last.date} - Close: \$${candles.last.close}');
} catch (e) {
  print('Error: $e');
}
```

### Get Intraday Data

```dart
try {
  final startDate = DateTime.now().subtract(Duration(days: 7));
  final endDate = DateTime.now();

  // Get hourly data for last 7 days
  final candles = await yahooApi.getHistoricalData(
    'MSFT',
    startDate,
    endDate,
    '1h', // Hourly interval
  );

  print('Hourly candles: ${candles.length}');
} catch (e) {
  print('Error: $e');
}
```

### Supported Intervals

- `'1d'` - Daily
- `'1h'` - Hourly
- `'15m'` - 15 minutes
- `'5m'` - 5 minutes
- `'1m'` - 1 minute (very limited history)

**Note**: Intraday data (< 1d) has limited history (usually 7-30 days max).

### Use OHLCV Data for Technical Calculations

```dart
try {
  final candles = await yahooApi.getRecentDailyData('AAPL', 100);

  // Calculate 20-period Simple Moving Average
  final closes = candles.map((c) => c.close).toList();
  final sma20 = closes.sublist(closes.length - 20).reduce((a, b) => a + b) / 20;

  print('SMA(20): \$${sma20.toStringAsFixed(2)}');

  // Find highest high in period
  final highestHigh = candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
  print('Highest high: \$${highestHigh}');

  // Calculate average volume
  final avgVolume = candles.map((c) => c.volume).reduce((a, b) => a + b) / candles.length;
  print('Avg volume: ${avgVolume.toStringAsFixed(0)}');
} catch (e) {
  print('Error: $e');
}
```

## Retry Logic

The implementation automatically handles failures:

- **Network errors**: Connection timeout, receive timeout, connection errors
- **Server errors**: 5xx status codes (Yahoo can be unreliable)
- **Rate limiting**: 429 status codes
- **Retry strategy**: Exponential backoff - 2s, 4s, 6s (max 3 attempts)

If you see retry messages:
```
[Yahoo Finance API] Retrying in 2 seconds (attempt 1/3)
[Yahoo Finance API] Retrying in 4 seconds (attempt 2/3)
```

This is normal. Yahoo's servers can be flaky.

## Error Handling

Common errors and solutions:

### "Symbol not found: XXX"
- **Cause**: Invalid ticker symbol or symbol doesn't exist
- **Solution**: Use valid US stock symbols (e.g., AAPL, MSFT, GOOGL)

### "Rate limit exceeded. Yahoo Finance API has usage limits (~360/hour)"
- **Cause**: Too many requests in a short period
- **Solution**: Wait before retrying, implement caching, or use official APIs

### "Failed to parse Yahoo Finance response"
- **Cause**: Yahoo changed API format or returned unexpected data
- **Solution**: This is why Yahoo API is unreliable - consider switching to official APIs

### "No data available for symbol: XXX"
- **Cause**: Market closed, symbol delisted, or no data for requested period
- **Solution**: Try a different date range or check if symbol is still trading

## Data Structure

### OhlcModel

```dart
class OhlcModel {
  final DateTime date;      // Timestamp of the candle
  final double open;        // Opening price
  final double high;        // Highest price
  final double low;         // Lowest price
  final double close;       // Closing price
  final int volume;         // Trading volume
}
```

All prices are in USD. Volume is number of shares traded.

## Project Structure

```
lib/features/technicals/
├── data/
│   ├── datasources/
│   │   └── yahoo_finance_api.dart        # Main API client with retry logic
│   └── models/
│       ├── ohlc_model.dart               # OHLC candlestick model
│       ├── ohlc_model.freezed.dart       # Generated Freezed code
│       └── ohlc_model.g.dart             # Generated JSON serialization
└── presentation/
    └── pages/
        └── yahoo_finance_test_page.dart  # Test UI for AAPL 60-day data

lib/core/
└── di/
    └── injection_container.dart          # DI registration for YahooFinanceApi
```

## Limitations

### Yahoo Finance Unofficial API

- **No guarantees**: API can break at any time
- **Rate limits**: Unofficial ~360 requests/hour (can change)
- **No support**: No documentation, no customer service
- **IP bans**: Heavy usage can result in IP blocking
- **Legal**: Commercial use violates Terms of Service

### Data Limitations

- **Delayed data**: 15-minute delay for real-time quotes
- **Intraday history**: Limited to 7-30 days for intervals < 1d
- **Adjusted data**: Prices may be adjusted for splits/dividends
- **Gaps**: Market closed periods return null values (automatically skipped)

## Migration Path to Official APIs

When ready for production, migrate to:

### Option 1: Finnhub (Free Tier)
```dart
// Already implemented in this project!
final finnhubApi = sl<FinnhubApi>();
final quote = await finnhubApi.getQuote('AAPL');
```

Finnhub provides:
- Real-time quotes (60 calls/min free)
- WebSocket streaming
- Company profiles
- Earnings data

**Missing**: Historical OHLCV candles (paid tier only)

### Option 2: Twelve Data ($29/month)
Best for technical analysis apps:
- 100+ built-in technical indicators
- 30+ years of historical data
- Real-time data on paid plans
- Clean API with good documentation

### Option 3: Alpha Vantage (Free Tier)
- 25 calls/day free tier (very limited)
- 20+ years historical data
- 50+ technical indicators
- Good for low-frequency apps

## Next Steps

1. ✅ Yahoo Finance API client implemented with retry logic
2. ✅ OhlcModel created with Freezed + JSON serialization
3. ✅ DI registration completed
4. ✅ Test page working for AAPL 60-day data

### Suggested Enhancements:

- [ ] Add local caching (Hive) to reduce API calls
- [ ] Implement request queue to avoid rate limits
- [ ] Add data validation (prices > 0, high >= low, etc.)
- [ ] Create repository layer for data abstraction
- [ ] Add technical indicator calculations (SMA, EMA, RSI, MACD)
- [ ] Implement isolate-based calculations for performance
- [ ] Add error analytics/logging
- [ ] Create chart integration with Syncfusion or fl_chart
- [ ] Plan migration to official API before production

## Resources

- **Yahoo Finance**: [https://finance.yahoo.com](https://finance.yahoo.com)
- **Research Doc**: See `research for financial api providers.md` (lines 34-38)
- **Alternative APIs**:
  - Finnhub: [https://finnhub.io](https://finnhub.io)
  - Twelve Data: [https://twelvedata.com](https://twelvedata.com)
  - Alpha Vantage: [https://www.alphavantage.co](https://www.alphavantage.co)

## Troubleshooting

### Run build_runner if you see errors
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Check if API is accessible
```bash
curl "https://query2.finance.yahoo.com/v8/finance/chart/AAPL?interval=1d&range=1d"
```

If this returns an error, Yahoo may have changed endpoints or is blocking your IP.

### Enable verbose logging
The API client already includes logging via Dio's `LogInterceptor`. Check console for detailed request/response logs:

```
[Yahoo Finance API] Fetching 1d data for AAPL from 2024-12-04 to 2025-02-04
[Yahoo Finance API] Successfully parsed 60 candles
```

---

**REMEMBER**: This is an **unofficial API for development only**. Plan to migrate to official APIs (Finnhub, Twelve Data, or Alpha Vantage) before releasing to production.
