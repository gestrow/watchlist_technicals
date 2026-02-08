# API Integration Guide

This document describes the external APIs used by Watchlist Technicals and how they are integrated.

## Overview

| API | Purpose | Auth Required | Rate Limit |
|-----|---------|---------------|------------|
| Yahoo Finance | OHLC historical data | No | Unofficial limits |
| Finnhub | Quotes, company profiles, earnings | Yes (API key) | 60 calls/min (free) |
| MarketAux | News with sentiment scores | Yes (API key) | 100/day (free) |

## Yahoo Finance

### Endpoint

```
https://query1.finance.yahoo.com/v8/finance/chart/{symbol}
```

### Usage

Fetches historical OHLC (Open, High, Low, Close) candlestick data for technical analysis.

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `symbol` | string | Stock ticker (e.g., AAPL) |
| `interval` | string | Candle interval: 1d, 1wk, 1mo |
| `range` | string | Date range: 1mo, 3mo, 6mo, 1y, 2y |

### Example Request

```
GET https://query1.finance.yahoo.com/v8/finance/chart/AAPL?interval=1d&range=6mo
```

### Response Structure

```json
{
  "chart": {
    "result": [{
      "timestamp": [1704067200, 1704153600, ...],
      "indicators": {
        "quote": [{
          "open": [185.22, 184.50, ...],
          "high": [186.10, 185.80, ...],
          "low": [184.00, 183.50, ...],
          "close": [185.56, 184.25, ...],
          "volume": [45000000, 42000000, ...]
        }]
      }
    }]
  }
}
```

### Implementation

Located in: `lib/features/technicals/data/datasources/yahoo_finance_datasource.dart`

```dart
Future<List<OhlcModel>> getHistoricalData(String symbol, String range) async {
  final response = await dio.get(
    'https://query1.finance.yahoo.com/v8/finance/chart/$symbol',
    queryParameters: {
      'interval': '1d',
      'range': range,
    },
  );
  // Parse response...
}
```

---

## Finnhub API

### Base URL

```
https://finnhub.io/api/v1
```

### Authentication

API key passed as query parameter:
```
?token=YOUR_API_KEY
```

### Endpoints Used

#### 1. Stock Quote

```
GET /quote?symbol={symbol}&token={apiKey}
```

**Response:**
```json
{
  "c": 150.25,   // Current price
  "h": 152.00,   // Day high
  "l": 148.50,   // Day low
  "o": 149.00,   // Open price
  "pc": 148.75,  // Previous close
  "d": 1.50,     // Change
  "dp": 1.01     // Percent change
}
```

#### 2. Company Profile

```
GET /stock/profile2?symbol={symbol}&token={apiKey}
```

**Response:**
```json
{
  "country": "US",
  "currency": "USD",
  "exchange": "NASDAQ",
  "finnhubIndustry": "Technology",
  "ipo": "1980-12-12",
  "logo": "https://...",
  "marketCapitalization": 2500000,
  "name": "Apple Inc",
  "phone": "14089961010",
  "shareOutstanding": 16000,
  "ticker": "AAPL",
  "weburl": "https://apple.com"
}
```

#### 3. Earnings Calendar

```
GET /calendar/earnings?symbol={symbol}&token={apiKey}
```

**Response:**
```json
{
  "earningsCalendar": [
    {
      "date": "2024-01-25",
      "epsActual": 2.18,
      "epsEstimate": 2.10,
      "hour": "amc",
      "quarter": 1,
      "revenueActual": 119575000000,
      "revenueEstimate": 117900000000,
      "symbol": "AAPL",
      "year": 2024
    }
  ]
}
```

### Rate Limiting

- Free tier: 60 API calls per minute
- Consider implementing request queuing for bulk operations
- Cache responses to reduce API calls

### Implementation

Located in: `lib/features/sentiment/data/datasources/finnhub_datasource.dart`

```dart
class FinnhubDatasource {
  final Dio dio;
  final String apiKey;

  Future<QuoteModel> getQuote(String symbol) async {
    final response = await dio.get(
      '$baseUrl/quote',
      queryParameters: {
        'symbol': symbol,
        'token': apiKey,
      },
    );
    return QuoteModel.fromJson(response.data);
  }
}
```

---

## MarketAux API

### Base URL

```
https://api.marketaux.com/v1
```

### Authentication

API key passed as query parameter:
```
?api_token=YOUR_API_KEY
```

### Endpoints Used

#### News with Sentiment

```
GET /news/all?symbols={symbols}&api_token={apiKey}
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `symbols` | string | Comma-separated tickers (e.g., AAPL,GOOGL) |
| `filter_entities` | boolean | Filter to relevant entities only |
| `language` | string | Language code (en) |
| `limit` | int | Number of articles (max 50) |

**Response:**
```json
{
  "data": [
    {
      "uuid": "abc123",
      "title": "Apple Reports Record Quarter",
      "description": "Apple Inc. announced...",
      "url": "https://...",
      "image_url": "https://...",
      "published_at": "2024-01-15T14:30:00.000Z",
      "source": "Financial Times",
      "sentiment_score": 0.75
    }
  ],
  "meta": {
    "found": 100,
    "returned": 10,
    "limit": 10,
    "page": 1
  }
}
```

### Sentiment Score

- Range: -1.0 to +1.0
- Negative: Bearish sentiment
- Zero: Neutral
- Positive: Bullish sentiment

### Rate Limiting

| Plan | Daily Limit |
|------|-------------|
| Free | 100 requests |
| Basic | 500 requests |
| Pro | Unlimited |

### Implementation

Located in: `lib/features/sentiment/data/datasources/marketaux_datasource.dart`

```dart
class MarketAuxDatasource {
  Future<List<NewsModel>> getNews(String symbol) async {
    final response = await dio.get(
      '$baseUrl/news/all',
      queryParameters: {
        'symbols': symbol,
        'filter_entities': true,
        'language': 'en',
        'limit': 20,
        'api_token': apiKey,
      },
    );

    final articles = response.data['data'] as List;
    return articles.map((json) => NewsModel.fromJson(json)).toList();
  }
}
```

---

## Error Handling

All API calls use the Either pattern for error handling:

```dart
Future<Either<Failure, T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    final result = await call();
    return Right(result);
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      return Left(AuthFailure('Invalid API key'));
    } else if (e.response?.statusCode == 429) {
      return Left(RateLimitFailure('Rate limit exceeded'));
    }
    return Left(ServerFailure(e.message ?? 'Unknown error'));
  } catch (e) {
    return Left(UnexpectedFailure(e.toString()));
  }
}
```

## API Key Storage

API keys are stored securely using `flutter_secure_storage`:

```dart
class ApiKeyService {
  final FlutterSecureStorage _storage;

  Future<void> saveFinnhubKey(String key) async {
    await _storage.write(key: 'finnhub_api_key', value: key);
  }

  Future<String?> getFinnhubKey() async {
    return await _storage.read(key: 'finnhub_api_key');
  }
}
```

---

## Caching Strategy

### Local Storage (Hive)

- **Watchlists**: Persistent storage
- **OHLC Data**: Cached with timestamp, refresh after 1 hour
- **Quotes**: Short-lived cache (5 minutes)
- **Company Profiles**: Long-lived cache (24 hours)
- **News**: Medium cache (1 hour)

### Cache Invalidation

```dart
bool shouldRefresh(DateTime lastFetch, Duration maxAge) {
  return DateTime.now().difference(lastFetch) > maxAge;
}
```

---

## Testing API Integration

### Mock Responses

For testing, create mock data sources:

```dart
class MockFinnhubDatasource implements FinnhubDatasource {
  @override
  Future<QuoteModel> getQuote(String symbol) async {
    return const QuoteModel(
      current: 150.0,
      high: 152.0,
      low: 148.0,
      open: 149.0,
      previousClose: 148.0,
      change: 2.0,
      percentChange: 1.35,
    );
  }
}
```

### Integration Tests

```dart
test('fetches real quote from Finnhub', () async {
  final datasource = FinnhubDatasource(dio: Dio(), apiKey: testApiKey);
  final quote = await datasource.getQuote('AAPL');

  expect(quote.current, isPositive);
  expect(quote.high, greaterThanOrEqualTo(quote.low));
});
```

---

## Troubleshooting

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Invalid API key | Verify API key in Settings |
| 429 Too Many Requests | Rate limit exceeded | Wait and retry, implement backoff |
| Network Error | No internet | Check connectivity, show offline banner |
| Empty Response | Invalid symbol | Validate symbol format |

### Debug Logging

Enable Dio logging for debugging:

```dart
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```
