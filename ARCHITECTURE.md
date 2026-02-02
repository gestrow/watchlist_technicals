# Watchlist Technicals - Architecture Documentation

## Overview
This Flutter app follows **Clean Architecture** with a **feature-first** approach for displaying technical indicators, sentiment analysis, and real-time data for stock watchlists.

## Project Structure

```
lib/
├── core/                          # Core infrastructure
│   ├── constants/
│   │   ├── api_constants.dart     # Finnhub, MarketAux, Yahoo Finance, Twelve Data APIs
│   │   └── app_constants.dart     # RSI periods, timeframe presets, cache durations
│   ├── theme/
│   │   ├── app_theme.dart         # Light & dark themes
│   │   └── app_colors.dart        # Color palette (bullish, bearish, indicators)
│   ├── errors/
│   │   └── failures.dart          # ServerFailure, NetworkFailure, CacheFailure, etc.
│   ├── di/
│   │   └── injection_container.dart # GetIt dependency injection setup
│   └── utils/
│       └── extensions.dart        # DateTime, Double, String, BuildContext extensions
│
├── features/                      # Feature modules (Clean Architecture per feature)
│   ├── watchlist/
│   │   ├── data/
│   │   │   ├── models/            # DTOs extending domain entities
│   │   │   ├── datasources/       # Remote (API) & Local (Hive) data sources
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/          # Business models
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   └── usecases/          # Business logic
│   │   └── presentation/
│   │       ├── bloc/              # BLoC state management
│   │       ├── pages/             # Full-screen views
│   │       └── widgets/           # Feature-specific widgets
│   │
│   ├── technicals/                # Technical indicators (RSI, MACD, Bollinger Bands)
│   │   └── [same structure as watchlist]
│   │
│   ├── sentiment/                 # News & sentiment analysis (MarketAux)
│   │   └── [same structure as watchlist]
│   │
│   └── settings/                  # App settings & preferences
│       └── [same structure as watchlist]
│
└── shared/
    ├── widgets/                   # Reusable UI components
    │   └── placeholder_page.dart
    └── services/                  # Cross-feature services
```

## Tech Stack

### Dependencies
- **State Management**: `flutter_bloc` ^8.1.6
- **HTTP Client**: `dio` ^5.4.0
- **Charts**: `syncfusion_flutter_charts` ^27.1.58
- **Local Storage**: `hive` ^2.2.3, `hive_flutter` ^1.1.0
- **Secure Storage**: `flutter_secure_storage` ^9.2.2
- **Serialization**: `freezed_annotation` ^2.4.1, `json_annotation` ^4.8.1
- **Navigation**: `go_router` ^13.2.0
- **Dependency Injection**: `get_it` ^8.0.2
- **Utilities**: `equatable` ^2.0.5, `dartz` ^0.10.1, `intl` ^0.19.0

### Dev Dependencies
- **Code Generation**: `freezed` ^2.4.5, `json_serializable` ^6.7.1, `build_runner` ^2.4.7, `hive_generator` ^2.0.1

## API Integrations

### Finnhub (Real-time Stock Data)
- **Base URL**: `https://finnhub.io/api/v1`
- **Rate Limit**: 60 calls/minute (free tier)
- **WebSocket**: `wss://ws.finnhub.io` (50 symbols max on free tier)
- **Endpoints**:
  - `/quote` - Real-time quotes
  - `/stock/profile2` - Company profile
  - `/stock/peers` - Peer stocks
  - `/company-news` - Company news (1 year historical)
  - `/stock/earnings` - EPS surprises (last 4 quarters)
  - `/calendar/earnings` - Earnings calendar
  - `/stock/candle` - OHLC candlestick data
  - `/stock/recommendation` - Analyst recommendations

### MarketAux (News & Sentiment)
- **Base URL**: `https://api.marketaux.com/v1`
- **Rate Limit**: 100 calls/day (free), 2,500/day ($29/mo Basic)
- **Endpoints**:
  - `/news/all` - Stock-specific news with sentiment scores (-1 to +1)
  - `/entity/search` - Symbol lookup

### Twelve Data (Technical Indicators)
- **Base URL**: `https://api.twelvedata.com`
- **Rate Limit**: 800 calls/day (free tier)
- **Endpoints**:
  - `/rsi` - Relative Strength Index
  - `/macd` - MACD indicator
  - `/bbands` - Bollinger Bands
  - `/sma` - Simple Moving Average
  - `/ema` - Exponential Moving Average

### Yahoo Finance (Historical Data - Prototyping Only)
- **Base URL**: `https://query2.finance.yahoo.com`
- **Note**: Unofficial API, use for prototyping only

## Theme System

### Colors
- **Market Colors**: Bullish (#26A69A), Bearish (#EF5350)
- **Indicator Colors**: MACD Line (#2196F3), MACD Signal (#FF9800), RSI Line (#E91E63)
- **Sentiment Colors**: Positive (#4CAF50), Negative (#F44336), Neutral (#9E9E9E)
- **Candles**: Up (#26A69A), Down (#EF5350)

### Dark Mode
Fully supported with automatic system theme detection.

## Constants & Configuration

### Technical Indicator Defaults
```dart
defaultRsiPeriod = 14
defaultMacdFastPeriod = 12
defaultMacdSlowPeriod = 26
defaultMacdSignalPeriod = 9
defaultBollingerPeriod = 20
defaultBollingerStdDev = 2.0
```

### Timeframe Presets
- **Intraday**: 1m, 5m, 15m, 30m, 1H
- **Swing**: 1H, 4H, 1D, 1W
- **Long-term**: 1D, 1W, 1M, 3M, 1Y

### Hive Box Names
- `watchlist` - Saved symbols
- `settings` - User preferences
- `cache` - API response cache
- `search_history` - Recent searches

## Initialization Flow

### main.dart
1. Initialize Hive with `Hive.initFlutter()`
2. Open Hive boxes (watchlist, settings, cache, search_history)
3. Initialize dependency injection with `di.init()`
4. Register Hive boxes in DI
5. Run app with light/dark theme support

## State Management Pattern

### BLoC Convention
- **Events**: Past tense for user actions (e.g., `WatchlistLoadRequested`)
- **States**: Sealed classes with `Initial`, `Loading`, `Loaded`, `Error` subtypes
- **Disposal**: Always dispose StreamSubscriptions in `close()`
- **UI Safety**: Check `mounted` before `setState` after async operations

## Error Handling

### Failure Types
- `ServerFailure` - API errors (4xx, 5xx)
- `NetworkFailure` - Connection issues
- `CacheFailure` - Local storage errors
- `ValidationFailure` - Input validation errors
- `RateLimitFailure` - API rate limit exceeded (429)
- `DataParsingFailure` - JSON parsing errors

## Extensions

### DateTimeExtensions
```dart
DateTime.now().toFormattedString()  // "Feb 02, 2026"
DateTime.now().toTimeAgo()          // "5m ago"
```

### DoubleExtensions
```dart
123.45.toFormattedPrice()           // "123.45"
5.67.toFormattedPercentage()        // "+5.67%"
1234567.89.toCompactNumber()        // "1.23M"
```

### StringExtensions
```dart
"AAPL".isValidSymbol()              // true
"hello".capitalizeFirst()           // "Hello"
```

### BuildContextExtensions
```dart
context.theme
context.textTheme
context.colorScheme
context.screenWidth
context.isDarkMode
context.showSnackBar("Success!")
```

## Next Steps

### 1. Implement Watchlist Feature
- Create `Stock` entity
- Implement `WatchlistRepository`
- Build `WatchlistBloc`
- Design watchlist UI

### 2. Implement Technicals Feature
- Create `Candle` and `Indicator` entities
- Integrate Finnhub candles endpoint
- Implement Syncfusion charts
- Add indicator overlays (RSI, MACD, Bollinger Bands)

### 3. Implement Sentiment Feature
- Create `NewsArticle` and `Sentiment` entities
- Integrate MarketAux news endpoint
- Display news feed with sentiment scores
- Add sentiment aggregation (average over time)

### 4. Add Navigation
- Configure `go_router` with routes
- Create bottom navigation bar
- Implement deep linking

### 5. Add Real-time Updates
- Implement Finnhub WebSocket client
- Stream real-time quotes for watchlist
- Auto-refresh charts on new data

### 6. Optimize Performance
- Cache API responses with TTL
- Implement pagination for news
- Use `compute()` for heavy calculations (indicators)
- Lazy load charts on demand

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed, json_serializable, hive)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
flutter pub run build_runner watch --delete-conflicting-outputs

# Run app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## API Keys Setup

Add your API keys to [lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart):

```dart
static const String finnhubApiKey = 'YOUR_FINNHUB_API_KEY';
static const String marketAuxApiKey = 'YOUR_MARKETAUX_API_KEY';
static const String twelveDataApiKey = 'YOUR_TWELVE_DATA_API_KEY';
```

**Get API Keys:**
- Finnhub: https://finnhub.io/register
- MarketAux: https://www.marketaux.com/account/signup
- Twelve Data: https://twelvedata.com/register

## References
- [Research on Financial APIs](research%20for%20financial%20api%20providers.md)
- [Extra Info on APIs](extra%20info%20on%20APIs.txt)
- [Syncfusion Charts Documentation](https://help.syncfusion.com/flutter/cartesian-charts/overview)
- [BLoC Library Documentation](https://bloclibrary.dev/)
