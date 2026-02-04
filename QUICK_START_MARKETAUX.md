# Quick Start: MarketAux API Integration

## ✅ Implementation Complete

All deliverables have been successfully implemented:

### Files Created
1. **[news_model.dart](lib/features/sentiment/data/models/news_model.dart)** - Freezed model with custom JSON mapping
2. **[marketaux_api.dart](lib/features/sentiment/data/datasources/marketaux_api.dart)** - API client with dio & interceptors
3. **[injection_container.dart](lib/core/di/injection_container.dart)** - DI registration (updated)
4. **[marketaux_test_page.dart](lib/features/sentiment/presentation/pages/marketaux_test_page.dart)** - Test widget
5. **[store_api_key.dart](lib/core/utils/store_api_key.dart)** - Helper functions for API key storage

## 🚀 How to Test

### Step 1: Store Your API Key
Add this code somewhere in your app (e.g., in a settings page or during first launch):

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Store your MarketAux API key
const storage = FlutterSecureStorage();
await storage.write(key: 'marketaux_api_key', value: 'YOUR_API_KEY_HERE');
```

Or use the helper function:
```dart
import 'package:watchlist_technicals/core/utils/store_api_key.dart';

await storeMarketAuxApiKey('YOUR_API_KEY_HERE');
```

### Step 2: Run the App
```bash
flutter run
```

The app will automatically show the MarketAux test page and fetch AAPL news from the last 7 days.

### Step 3: Check Console Output
You should see output like:
```
=== MarketAux API Test Results ===
Fetched 20 articles for AAPL (last 7 days)
=====================================

Article 1:
  Headline: Apple Announces New Product Line
  Sentiment: 0.75 (Positive)
  Source: Reuters
  Published: 2026-02-03 10:30:00.000
  URL: https://...
---

Average Sentiment: 0.42 (Positive)

=== Test Complete ===
```

## 📊 API Features

### Methods Available
```dart
final api = sl<MarketAuxApi>();

// Get news by symbol with date range
final news = await api.getNewsBySymbol(
  'AAPL',
  DateTime(2026, 1, 1),
  DateTime(2026, 2, 4),
  limit: 20,
);

// Get recent news (last N days)
final recentNews = await api.getRecentNews(
  'AAPL',
  days: 7,
  limit: 20,
);
```

### NewsModel Fields
- `headline` - Article title
- `description` - Article description/summary
- `url` - Full article URL
- `publishedAt` - Publication date/time
- `sentimentScore` - Sentiment (-1 to +1)
- `source` - News source name
- `imageUrl` - Optional article image

### Sentiment Scale
- **+0.3 to +1.0** → Positive (Green)
- **-0.3 to +0.3** → Neutral (Gray)
- **-1.0 to -0.3** → Negative (Red)

## 🔧 API Configuration

### Current Settings
- **Base URL**: `https://api.marketaux.com/v1`
- **Endpoint**: `/news/all`
- **Plan**: Basic (2,500 requests/day, 20 articles/request)
- **Filters**: US markets only, equity entity type, English language

### Query Parameters
```dart
{
  'symbols': 'AAPL',
  'published_after': '2026-01-28T00:00:00.000Z',
  'published_before': '2026-02-04T00:00:00.000Z',
  'countries': 'us',
  'entity_types': 'equity',
  'limit': '20',
  'language': 'en',
  'api_token': 'YOUR_KEY' // Auto-injected
}
```

## ⚠️ Error Handling

### Rate Limit (429)
```
[MarketAux API] Rate limit exceeded (2500 requests/day)
```
Wait until next day or upgrade plan.

### Invalid Key (401)
```
[MarketAux API] Invalid API key
```
Check your API key in secure storage.

### Network Errors
```
[MarketAux API] Connection error: ...
[MarketAux API] Network timeout: ...
```
Check internet connection.

## 📝 Next Steps

To integrate into your main app:

1. **Restore Original Home Page**
   ```dart
   // In main.dart, change back to:
   home: const PlaceholderPage(),
   ```

2. **Create Sentiment BLoC**
   - Implement proper state management
   - Handle loading, success, error states

3. **Add Repository Layer**
   - Abstract data source behind repository interface
   - Implement caching with Hive

4. **Integrate with Watchlist**
   - Show sentiment indicators per symbol
   - Display recent news in symbol detail page

5. **Add UI Components**
   - Sentiment charts
   - News cards
   - Filter by date range

## 📚 Documentation
- Full setup guide: [MARKETAUX_SETUP.md](MARKETAUX_SETUP.md)
- API Docs: https://www.marketaux.com/documentation
- Pricing: https://www.marketaux.com/pricing

---

**Note**: The current implementation uses `print()` statements for debugging. Replace with a proper logging framework in production.
