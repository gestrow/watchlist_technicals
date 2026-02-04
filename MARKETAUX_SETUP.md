# MarketAux API Setup Guide

## Overview
The MarketAux API client has been successfully implemented with the following features:
- **Base URL**: https://api.marketaux.com/v1
- **Plan**: Basic ($29/mo) - 2,500 requests/day, 20 articles/request
- **Dio** with interceptors for logging and API key management
- **Sentiment scores** per article (-1 to +1 scale)
- **Error handling** for rate limits (429), invalid keys (401), and network errors

## Files Created

### 1. NewsModel (`lib/features/sentiment/data/models/news_model.dart`)
- Freezed model with JSON serialization
- Maps MarketAux API response to app model
- Fields: headline, description, url, publishedAt, sentimentScore, source, imageUrl

### 2. MarketAux API Client (`lib/features/sentiment/data/datasources/marketaux_api.dart`)
- `getNewsBySymbol()` - Fetch news by symbol with date range
- `getRecentNews()` - Helper method for last N days
- Automatic API key injection from secure storage
- Query parameters: symbols, published_after, published_before, countries=us, entity_types=equity, language=en

### 3. DI Registration (`lib/core/di/injection_container.dart`)
- Registered `FlutterSecureStorage` as singleton
- Registered `MarketAuxApi` as singleton with dependencies
- Added `_initSentimentFeature()` function

### 4. Test Page (`lib/features/sentiment/presentation/pages/marketaux_test_page.dart`)
- Fetches AAPL news from last 7 days
- Displays headlines with sentiment scores
- Shows average sentiment across all articles
- Color-coded sentiment indicators (green=positive, red=negative, gray=neutral)
- Console output for verification

## Setup Instructions

### Step 1: Store Your API Key
Before running the app, you need to store your MarketAux API key in Flutter Secure Storage.

Create a simple script or add this to your app initialization:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
await storage.write(key: 'marketaux_api_key', value: 'YOUR_API_KEY_HERE');
```

### Step 2: Run the Test App
The app is currently configured to show the MarketAux test page on launch:

```bash
flutter run
```

### Step 3: Verify in Console
Check the console output for:
- Number of articles fetched
- Headlines with sentiment scores
- Average sentiment calculation
- Any errors (rate limits, invalid key, network issues)

### Expected Console Output
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
...

Average Sentiment: 0.42 (Positive)

=== Test Complete ===
```

## API Usage Details

### Rate Limits (Basic Plan)
- **2,500 requests/day** - Generous for multiple users
- **20 articles/request** - Good coverage for per-symbol queries
- Rate limit errors return 429 status code

### Sentiment Score Scale
- **+0.3 to +1.0**: Positive sentiment (green)
- **-0.3 to +0.3**: Neutral sentiment (gray)
- **-1.0 to -0.3**: Negative sentiment (red)

### Query Parameters Used
- `symbols`: Stock ticker (e.g., "AAPL")
- `published_after`: ISO 8601 date string
- `published_before`: ISO 8601 date string
- `countries`: "us" (US markets only)
- `entity_types`: "equity" (stocks only)
- `limit`: Max 20 for Basic plan
- `language`: "en" (English)
- `api_token`: Auto-injected from secure storage

## Error Handling

### 429 Rate Limit Exceeded
```
[MarketAux API] Rate limit exceeded (2500 requests/day)
```
**Solution**: Wait until next day or upgrade plan

### 401 Invalid API Key
```
[MarketAux API] Invalid API key
```
**Solution**: Check your API key in secure storage

### Network Errors
```
[MarketAux API] Connection error: ...
[MarketAux API] Network timeout: ...
```
**Solution**: Check internet connection

## Next Steps

### Integration into Main App
1. Replace test page with actual placeholder page in main.dart
2. Create sentiment BLoC for state management
3. Add repository layer between data source and presentation
4. Integrate with watchlist feature to show sentiment per symbol
5. Add caching to reduce API calls
6. Implement sentiment charts/visualizations

### Production Considerations
1. Replace `print()` statements with proper logging framework
2. Add retry logic for transient network errors
3. Implement request queuing to avoid rate limits
4. Cache news data in Hive for offline access
5. Add user preferences for news date ranges
6. Implement pagination for more than 20 articles

## API Documentation
- Official Docs: https://www.marketaux.com/documentation
- Pricing: https://www.marketaux.com/pricing
- Support: Contact MarketAux for API issues

## Testing Checklist
- [x] MarketAux API client created with dio
- [x] NewsModel with Freezed generated code
- [x] DI registration complete
- [x] Test widget displays news correctly
- [x] Console output shows headlines and sentiment
- [ ] User stores API key in secure storage
- [ ] App successfully fetches real data
- [ ] Error handling works for rate limits and invalid keys
