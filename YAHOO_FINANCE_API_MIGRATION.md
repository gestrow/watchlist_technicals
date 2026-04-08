# Yahoo Finance API Migration Notes (April 2026)

Reference document for Claude when updating this Flutter app's Yahoo Finance integration.

---

## What Changed

Yahoo **removed the v8 historical endpoint** that this app and the `yahoo-finance2` npm package relied on. The endpoint `query2.finance.yahoo.com/v8/finance/chart/{symbol}` now aggressively rate-limits (returns plain text `"Too Many Requests"` instead of JSON) and may be fully deprecated.

### Symptoms
- All price fetches fail with `"Too Many Requests"` (HTTP 429 or plain text, not JSON)
- The npm library `yahoo-finance2` deprecated `historical()` and maps it to `chart()` internally
- Rate limit backoff of 1-2s is not enough — Yahoo now requires 5-10s+ between retries
- The error is **not valid JSON**, so JSON parsing throws before the app can detect rate limiting

### What was fixed in Signal Wraith (Next.js)
**File**: `lib/services/yahoo-finance.ts`

1. Migrated from `yahooFinance.historical()` to `yahooFinance.chart()` (the npm library's new direct API)
2. Added detection for plain-text rate limit responses (`"Too Many Requests"` in error message)
3. Increased retry backoff for rate-limited requests: 5s, 10s, 15s (was 1s, 2s, 3s)
4. Pinned `yahoo-finance2` to `^2.14.2` (was `"latest"` — dangerous, npm latest is v3 with breaking changes)
5. Added `yahooFinance.suppressNotices(['ripHistorical'])` to suppress deprecation warnings
6. Chart API returns `adjclose` (lowercase) instead of `adjClose` — updated field mapping

---

## Required Changes in This Flutter App

### 1. Update endpoint (if Yahoo moved it)

**File**: `lib/core/constants/api_constants.dart`

The current endpoint is:
```dart
static const String yahooFinanceChartEndpoint = '/v8/finance/chart';
```

This may still work but is the same endpoint being rate-limited. Monitor and potentially update to whatever endpoint Yahoo stabilizes on. The npm library's `chart()` uses the same `/v8/finance/chart` path — so the endpoint itself hasn't changed, just the rate limiting behavior.

### 2. Fix rate limit error handling

**File**: `lib/features/technicals/data/datasources/yahoo_finance_api.dart`

The current retry interceptor doesn't handle **plain text rate limit responses**. Yahoo now sometimes returns `"Too Many Requests\r\n"` as plain text (not JSON, not a proper HTTP 429). This causes a `FormatException` in Dio's JSON parser before the retry interceptor can catch it.

**Changes needed**:

a) Add `FormatException` / parse error detection as a rate-limit signal:
```dart
bool _shouldRetry(DioException error) {
  // ... existing checks ...

  // Yahoo sometimes returns plain text "Too Many Requests" instead of JSON,
  // which causes a FormatException before we get a status code
  if (error.type == DioExceptionType.badResponse &&
      error.response?.data is String &&
      (error.response?.data as String).contains('Too Many Requests')) {
    return true;
  }

  return false;
}
```

b) Increase retry backoff for rate limits — current `(retryCount + 1) * 2` (2s, 4s, 6s) is too aggressive:
```dart
// In retry interceptor:
final isRateLimit = error.response?.statusCode == 429 ||
    (error.response?.data is String &&
     (error.response?.data as String).contains('Too Many Requests'));
final baseDelay = isRateLimit ? 5 : 2; // 5s base for rate limits
final delaySeconds = (retryCount + 1) * baseDelay;
```

c) Update the `getHistoricalData` catch block to handle the plain text case:
```dart
} on DioException catch (e) {
  if (e.response?.statusCode == 404) {
    throw Exception('Symbol not found: $symbol');
  }
  if (e.response?.statusCode == 429 ||
      (e.response?.data is String &&
       (e.response?.data as String).contains('Too Many Requests'))) {
    throw Exception(
        'Rate limit exceeded. Yahoo Finance API has usage limits. Try again in 30+ seconds.');
  }
  rethrow;
}
```

### 3. Add request throttling

Yahoo's rate limit is now stricter. Add a minimum delay between requests:

```dart
DateTime? _lastRequestTime;
static const Duration _minRequestInterval = Duration(seconds: 2);

Future<void> _throttle() async {
  if (_lastRequestTime != null) {
    final elapsed = DateTime.now().difference(_lastRequestTime!);
    if (elapsed < _minRequestInterval) {
      await Future.delayed(_minRequestInterval - elapsed);
    }
  }
  _lastRequestTime = DateTime.now();
}

// Call _throttle() at the start of getHistoricalData()
```

### 4. Response parsing — no structural changes needed

The Flutter app already parses the raw Yahoo Finance JSON response format directly:
```
chart.result[0].indicators.quote[0].{open,high,low,close,volume}
```

This is the same structure returned by the `/v8/finance/chart` endpoint. The npm library's `chart()` just wraps this same endpoint. **No parsing changes needed** — the Flutter app talks directly to Yahoo's API, not through a library.

---

## Signal Wraith API as Alternative Data Source

If Yahoo Finance continues to be unreliable, the Flutter app could fetch price data through Signal Wraith's API instead:

**Endpoint**: `GET /api/data/price-history`
```
?symbol=AAPL&from=2026-03-01&to=2026-03-28&volume=true
```

**Response**:
```json
{
  "symbol": "AAPL",
  "data": [
    {
      "date": "2026-03-02",
      "open": 242.00,
      "high": 245.50,
      "low": 241.00,
      "close": 243.50,
      "volume": 45234567
    }
  ],
  "metadata": {
    "requestedPeriod": { "from": "2026-03-01", "to": "2026-03-28" },
    "actualPeriod": { "from": "2026-03-02", "to": "2026-03-28" },
    "source": "Yahoo Finance"
  },
  "summary": {
    "recordCount": 20,
    "priceRange": { "min": 235.50, "max": 248.00 }
  }
}
```

This endpoint has its own caching (Redis, 1-hour TTL) and retry logic, so it's more resilient than hitting Yahoo directly. However, it requires the Signal Wraith server to be accessible and has its own rate limiting.

---

## Files to Modify (Summary)

| File | What to change |
|------|---------------|
| `lib/features/technicals/data/datasources/yahoo_finance_api.dart` | Rate limit detection, retry backoff, request throttling |
| `lib/core/constants/api_constants.dart` | Endpoint URL if Yahoo changes it |
| `lib/features/technicals/presentation/pages/yahoo_finance_test_page.dart` | Update test to handle rate limit gracefully |

---

## Key Takeaway

The Yahoo Finance API didn't change its endpoint or response format — it changed its **rate limiting behavior** to be much more aggressive. The fix is primarily about:
1. Detecting rate limits even when they arrive as malformed (non-JSON) responses
2. Using longer backoff delays (5-15s instead of 2-6s)
3. Throttling requests to avoid triggering limits in the first place
