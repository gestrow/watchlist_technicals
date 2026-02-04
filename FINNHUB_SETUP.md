# Finnhub API Setup Guide

This guide walks you through setting up and testing the Finnhub API integration in the Watchlist Technicals app.

## Overview

The Finnhub API provides real-time US stock data, company profiles, earnings data, and more. The free tier offers 60 API calls per minute.

### Implemented Features

- **Company Profile**: Get company details (name, logo, industry, country, description)
- **Real-time Quotes**: Current price, high/low, open, previous close, change %
- **Peer Companies**: List of peer/competitor ticker symbols
- **Earnings Surprises**: Last 4 quarters of earnings vs estimates
- **Earnings Calendar**: Upcoming earnings dates and EPS estimates

### Technical Implementation

- Rate limiting: 60 calls/min with queue management
- Exponential backoff on 429 errors (3 retries: 2s, 4s, 6s)
- In-memory caching:
  - Quotes: 30 seconds TTL
  - Profiles/Peers/Earnings: 1 hour TTL
- Clean Architecture with DI (GetIt)
- Freezed models with JSON serialization

## Setup Steps

### 1. Get Your Free Finnhub API Key

1. Go to [https://finnhub.io/register](https://finnhub.io/register)
2. Sign up for a free account (no credit card required)
3. Verify your email
4. Copy your API key from the dashboard

### 2. Store API Key in Secure Storage

The app uses `flutter_secure_storage` to securely store your API key.

#### Option A: Use the helper function in code

Add this to any initialization code or a settings page:

```dart
import 'package:watchlist_technicals/core/utils/store_api_key.dart';

// Store your Finnhub API key
await storeFinnhubApiKey('your_finnhub_api_key_here');
```

#### Option B: Temporary test code in main.dart

Add before `runApp()` in `main.dart`:

```dart
import 'core/utils/store_api_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // ... existing code ...

  // ⚠️ TEMPORARY: Store your Finnhub API key (remove after first run!)
  await storeFinnhubApiKey('your_finnhub_api_key_here');

  await di.init();
  await di.registerHiveBoxes();

  runApp(const MyApp());
}
```

**Important**: Remove the API key line after the first run! The key is persisted in secure storage.

### 3. Test the Integration

1. Run the app:
   ```bash
   flutter run
   ```

2. You'll see the API Test Dashboard with two buttons
3. Tap "Finnhub API (Stock Data)"
4. Tap "Test Finnhub API (AAPL)"
5. You should see output like:

```
Testing Finnhub API...

Fetching company profile for AAPL...
✓ Company Profile:
  Name: Apple Inc
  Ticker: AAPL
  Industry: Technology
  Country: US
  Logo: https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AAPL.png
  Description: Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables...

Fetching quote for AAPL...
✓ Quote:
  Current: $XXX.XX
  High: $XXX.XX
  Low: $XXX.XX
  Open: $XXX.XX
  Previous Close: $XXX.XX
  Change: $X.XX (X.XX%)

Fetching peers for AAPL...
✓ Peers (XX total):
  MSFT, GOOGL, AMZN, META, NVDA, TSLA, ...

✅ All tests completed successfully!
```

## API Usage Examples

### Get Company Profile

```dart
import 'package:watchlist_technicals/core/di/injection_container.dart';
import 'package:watchlist_technicals/features/sentiment/data/datasources/finnhub_api.dart';

final finnhubApi = sl<FinnhubApi>();

try {
  final profile = await finnhubApi.getCompanyProfile('AAPL');
  print('Company: ${profile.name}');
  print('Industry: ${profile.industry}');
  print('Logo: ${profile.logo}');
} catch (e) {
  print('Error: $e');
}
```

### Get Real-time Quote

```dart
try {
  final quote = await finnhubApi.getQuote('AAPL');
  print('Current Price: \$${quote.current}');
  print('Change: ${quote.percentChange}%');
} catch (e) {
  print('Error: $e');
}
```

### Get Peer Companies

```dart
try {
  final peers = await finnhubApi.getPeers('AAPL');
  print('Peers: ${peers.join(", ")}');
} catch (e) {
  print('Error: $e');
}
```

### Get Earnings Surprises

```dart
try {
  final earnings = await finnhubApi.getEarningsSurprises('AAPL');
  for (final earning in earnings) {
    print('${earning.period}: Actual ${earning.actual} vs Estimate ${earning.estimate}');
    print('Surprise: ${earning.surprise}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Get Earnings Calendar

```dart
try {
  // Get earnings for a specific symbol
  final calendar = await finnhubApi.getEarningsCalendar(
    symbol: 'AAPL',
    from: DateTime.now(),
    to: DateTime.now().add(Duration(days: 30)),
  );

  for (final event in calendar) {
    print('${event.symbol} - ${event.date}: EPS Est ${event.epsEstimate}');
  }
} catch (e) {
  print('Error: $e');
}
```

## Rate Limiting

The implementation automatically handles rate limiting:

- **Max calls**: 60 per minute (free tier)
- **Queue management**: Requests wait if limit is reached
- **Auto-retry**: On 429 errors, retries with exponential backoff (2s, 4s, 6s)
- **Caching**: Reduces API calls by caching responses

If you exceed the rate limit, you'll see:
```
[Finnhub API] Rate limit reached, waiting XXXms
[Finnhub API] Rate limit exceeded (60 calls/minute)
[Finnhub API] Retrying in X seconds (attempt X/3)
```

## Caching

Responses are cached in memory to reduce API calls:

| Endpoint | TTL |
|----------|-----|
| Quote | 30 seconds |
| Company Profile | 1 hour |
| Peers | 1 hour |
| Earnings Surprises | 1 hour |
| Earnings Calendar | 1 hour |

Clear cache manually if needed:
```dart
final finnhubApi = sl<FinnhubApi>();
finnhubApi.clearCache();
```

## Error Handling

Common errors and solutions:

### "Finnhub API key not found in secure storage"
- **Cause**: API key not stored
- **Solution**: Follow Step 2 to store your API key

### "Invalid Finnhub API key"
- **Cause**: Wrong API key or expired
- **Solution**: Get a new API key from finnhub.io

### "Rate limit exceeded after 3 retries"
- **Cause**: Too many requests
- **Solution**: Wait 1 minute before retrying, or implement longer delays

### "Symbol not found: XXX"
- **Cause**: Invalid ticker symbol
- **Solution**: Use valid US stock symbols (e.g., AAPL, MSFT, GOOGL)

### "Invalid quote data for symbol: XXX"
- **Cause**: Market closed or symbol not supported
- **Solution**: Try during market hours or use a different symbol

## Project Structure

```
lib/features/sentiment/
├── data/
│   ├── datasources/
│   │   └── finnhub_api.dart          # Main API client with rate limiting & caching
│   └── models/
│       ├── company_profile_model.dart # Company profile model
│       ├── quote_model.dart           # Quote model
│       ├── earnings_model.dart        # Earnings surprises model
│       └── earnings_calendar_model.dart # Earnings calendar model
└── presentation/
    └── pages/
        └── finnhub_test_page.dart     # Test UI for AAPL data

lib/core/
├── di/
│   └── injection_container.dart       # DI registration for FinnhubApi
└── utils/
    └── store_api_key.dart             # Helpers for storing API keys
```

## Free Tier Limitations

The Finnhub free tier includes:

✅ **Available**:
- 60 API calls per minute
- Real-time US stock quotes (IEX)
- Company profiles
- Company news (1 year)
- Earnings surprises (4 quarters)
- Earnings calendar (1 month historical)
- Peer companies
- Basic fundamentals

❌ **Not Available** (Paid plans only):
- Historical OHLC/candles
- Deep historical data (20+ years)
- International real-time data
- Technical indicators
- News sentiment scores
- Full financial statements
- Recommendation trends
- Price targets

## Next Steps

1. ✅ Finnhub API client implemented with rate limiting
2. ✅ Models created with Freezed + JSON serialization
3. ✅ DI registration completed
4. ✅ Test page working for AAPL

### Suggested Enhancements:

- [ ] Add persistent cache (Hive) for longer TTLs
- [ ] Implement WebSocket for real-time streaming (50 symbols)
- [ ] Create repository layer for data abstraction
- [ ] Add BLoC for state management
- [ ] Implement retry logic with circuit breaker pattern
- [ ] Add logging framework instead of print statements
- [ ] Create settings page for API key management
- [ ] Add more endpoints (news, candles, etc.)

## Resources

- **Finnhub API Docs**: [https://finnhub.io/docs/api](https://finnhub.io/docs/api)
- **Pricing**: [https://finnhub.io/pricing](https://finnhub.io/pricing)
- **Dashboard**: [https://finnhub.io/dashboard](https://finnhub.io/dashboard)
- **Extra Info**: See `extra info on APIs.txt` (lines 14-142)

## Troubleshooting

### Run build_runner if you see errors
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Check if API key is stored
```dart
import 'package:watchlist_technicals/core/utils/store_api_key.dart';

final apiKey = await getFinnhubApiKey();
print('API Key: ${apiKey ?? "Not found"}');
```

### Delete API key (if needed)
```dart
import 'package:watchlist_technicals/core/utils/store_api_key.dart';

await deleteFinnhubApiKey();
```

### Enable verbose logging
The API client already includes logging via Dio's `LogInterceptor`. Check console for detailed request/response logs.

---

**Need help?** Check the console output for detailed error messages and API logs.
