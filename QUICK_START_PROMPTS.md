# Quick Start: Sequential Prompts for Claude Code

**IMPORTANT**: Use these prompts one at a time, in order. Each prompt is self-contained and references the spec files (research for financial api providers.md, extra info on APIs.txt, hilbert transform notes.txt).

**Your Setup**:
- MarketAux API: Basic Plan (2500 requests/day, 20 articles/request) ✅
- Finnhub API: Free tier (60 calls/min)
- Yahoo Finance: No key needed (unofficial)
- Charts: Syncfusion Flutter Charts
- Storage: Hive + flutter_secure_storage

---

## Phase 1: Project Setup

```
I need to set up the core architecture for my Flutter watchlist technicals app.

REFERENCE FILES (read these first):
- research for financial api providers.md
- extra info on APIs.txt

TASKS:

1. UPDATE pubspec.yaml dependencies:
   - syncfusion_flutter_charts: ^latest
   - hive: ^2.2.3
   - hive_flutter: ^1.1.0
   - flutter_secure_storage: ^9.2.2
   - dio: ^5.4.0
   - freezed_annotation: ^2.4.1
   - json_annotation: ^4.8.1
   - go_router: ^13.2.0
   - equatable: ^2.0.5
   - Dev dependencies: freezed, json_serializable, build_runner, hive_generator

2. CREATE folder structure (Clean Architecture, feature-first):
   lib/
   ├── core/
   │   ├── constants/ (api_constants.dart, app_constants.dart)
   │   ├── theme/ (app_theme.dart, app_colors.dart)
   │   ├── errors/ (failures.dart)
   │   ├── di/ (injection_container.dart using get_it)
   │   └── utils/ (extensions.dart)
   ├── features/
   │   ├── watchlist/
   │   │   ├── data/ (models/, datasources/, repositories/)
   │   │   ├── domain/ (entities/, repositories/)
   │   │   └── presentation/ (bloc/, pages/, widgets/)
   │   ├── technicals/ (same structure)
   │   ├── sentiment/ (same structure)
   │   └── settings/ (same structure)
   └── shared/
       ├── widgets/
       └── services/

3. CREATE core files:
   - app_theme.dart: Material theme, dark-mode friendly, financial app aesthetic
   - app_colors.dart: Primary, accent, error, success colors
   - api_constants.dart: Base URLs for Finnhub, MarketAux, Yahoo Finance
   - app_constants.dart: Default RSI periods, timeframe presets (intraday/swing/long)
   - failures.dart: ServerFailure, CacheFailure, ValidationFailure, NetworkFailure

4. SETUP dependency injection (core/di/injection_container.dart):
   - Use get_it for service locator
   - Create init() function for setup
   - Setup for lazy singletons

5. UPDATE main.dart:
   - Initialize Hive with await Hive.initFlutter()
   - Call dependency injection init()
   - Setup MaterialApp with app_theme
   - Basic home screen (can be placeholder)

DELIVERABLES:
- Updated pubspec.yaml
- Complete folder structure
- Core files created
- DI setup
- App runs with no errors
```

---

## Phase 2A: MarketAux API (Priority - You Have Paid Plan)

```
Implement MarketAux API client - I have the Basic paid plan (2500 requests/day, 20 articles/request).

READ FIRST:
- extra info on APIs.txt (MarketAux section lines 216-263)

IMPLEMENT:

1. CREATE features/sentiment/data/datasources/marketaux_api.dart:
   - Base URL: https://api.marketaux.com/v1
   - Use dio with interceptors
   - Add API key from flutter_secure_storage in query param
   - Method: Future<List<NewsModel>> getNewsBySymbol(
       String symbol,
       DateTime from,
       DateTime to,
       {int limit = 20}
     )
   - Endpoint: /news/all
   - Query params:
     * symbols={symbol}
     * published_after={from.toIso8601String()}
     * published_before={to.toIso8601String()}
     * countries=us
     * entity_types=equity
     * limit={limit}
     * language=en
   - Parse JSON response, extract articles array
   - Each article has: title, description, url, published_at, sentiment_score, source, image_url
   - Handle errors: 429 (rate limit), 401 (invalid key), network errors
   - Add dio logging interceptor

2. CREATE features/sentiment/data/models/news_model.dart:
   ```dart
   @freezed
   class NewsModel with _$NewsModel {
     factory NewsModel({
       required String headline,
       required String description,
       required String url,
       required DateTime publishedAt,
       required double sentimentScore, // -1 to +1 from MarketAux
       required String source,
       String? imageUrl,
     }) = _NewsModel;

     factory NewsModel.fromJson(Map<String, dynamic> json) => _$NewsModelFromJson(json);
   }
   ```
   - Map MarketAux JSON fields: title -> headline, published_at -> publishedAt, sentiment_score -> sentimentScore

3. REGISTER in core/di/injection_container.dart:
   - Register Dio instance as singleton
   - Register MarketAuxApi as singleton

4. CREATE simple test widget to verify:
   - Fetch news for "AAPL" from last 7 days
   - Print headlines and sentiment scores to console

IMPORTANT: MarketAux sentiment_score is per-article, ranges -1 (very negative) to +1 (very positive), 0 is neutral. Your Basic plan allows 2500 calls/day which is generous.

DELIVERABLES:
- MarketAux API client working
- NewsModel with Freezed generated code
- DI registration
- Manual test confirms API works with your key
```

---

## Phase 2B: Finnhub API

```
Implement Finnhub API client (free tier, 60 calls/min).

READ FIRST:
- extra info on APIs.txt (Finnhub section lines 14-142)

IMPLEMENT:

1. CREATE features/sentiment/data/datasources/finnhub_api.dart:
   - Base URL: https://finnhub.io/api/v1
   - Use dio with interceptor to add token={api_key} query param
   - Implement rate limiting queue (max 60 calls/min)

   Methods:
   a) Future<CompanyProfileModel> getCompanyProfile(String symbol)
      - Endpoint: /stock/profile2?symbol={symbol}
      - Extract: name, ticker, logo, description (weburl can be used), industry, country

   b) Future<QuoteModel> getQuote(String symbol)
      - Endpoint: /quote?symbol={symbol}
      - Response keys: c (current), h (high), l (low), o (open), pc (previous close), d (change), dp (percent change)

   c) Future<List<String>> getPeers(String symbol)
      - Endpoint: /stock/peers?symbol={symbol}
      - Returns array of peer symbols

   d) Future<List<EarningsModel>> getEarningsSurprises(String symbol)
      - Endpoint: /stock/earnings?symbol={symbol}
      - Returns array, extract: actual, estimate, period, surprise

   e) Future<List<EarningsCalendarModel>> getEarningsCalendar({String? symbol, DateTime? from, DateTime? to})
      - Endpoint: /calendar/earnings?from={from}&to={to}&symbol={symbol}
      - Extract: date, epsEstimate, symbol

   - Handle 429 errors with exponential backoff
   - Implement simple in-memory cache for repeated calls (30 second TTL for quotes, 1 hour for profiles)

2. CREATE models in features/sentiment/data/models/:
   - company_profile_model.dart
   - quote_model.dart
   - earnings_model.dart
   - earnings_calendar_model.dart
   All using Freezed + JsonSerializable

3. REGISTER in DI container

4. TEST: Fetch profile + quote + peers for "AAPL", print to console

DELIVERABLES:
- Finnhub API client with rate limiting
- All Finnhub models
- DI registration
- Manual test working
```

---

## Phase 2C: Yahoo Finance Client

```
Implement Yahoo Finance client for historical OHLCV data (needed for technical calculations).

READ FIRST:
- research for financial api providers.md (Yahoo Finance section lines 34-38)

IMPLEMENT:

1. CREATE features/technicals/data/datasources/yahoo_finance_api.dart:
   - Can use simple HTTP client or yahoo_finance_data_reader package if available
   - Method: Future<List<OhlcModel>> getHistoricalData(
       String symbol,
       DateTime startDate,
       DateTime endDate,
       String interval, // '1d', '1h', '15m', '5m'
     )
   - Yahoo endpoint pattern: https://query2.finance.yahoo.com/v8/finance/chart/{symbol}?period1={start_epoch}&period2={end_epoch}&interval={interval}
   - Parse JSON response: result[0].indicators.quote[0] contains arrays for open, high, low, close, volume
   - Timestamps in result[0].timestamp array
   - Combine into List<OhlcModel>
   - Handle errors: invalid symbol (404), rate limiting, parse errors
   - Add retry logic (Yahoo can be unreliable)

2. CREATE features/technicals/data/models/ohlc_model.dart:
   ```dart
   @freezed
   class OhlcModel with _$OhlcModel {
     factory OhlcModel({
       required DateTime date,
       required double open,
       required double high,
       required double low,
       required double close,
       required int volume,
     }) = _OhlcModel;

     factory OhlcModel.fromJson(Map<String, dynamic> json) => _$OhlcModelFromJson(json);
   }
   ```

3. REGISTER in DI

4. TEST: Fetch 60 days of daily data for "AAPL", print first 5 and last 5 candles

DELIVERABLES:
- Yahoo Finance client working
- OhlcModel
- DI registration
- Manual test confirms data fetches correctly

Phase 2 now complete - all API clients ready!
```

---

## Phase 3A: Core Technical Indicators

```
Implement RSI, EMA, SMA calculators with EXACT mathematical formulas.

CONTEXT: These process OHLCV data from Yahoo Finance. Must use precise formulas to ensure accuracy.

IMPLEMENT in features/technicals/domain/calculators/:

1. rsi_calculator.dart:
   ```dart
   class RsiCalculator {
     /// Calculate RSI using Wilder's smoothing method
     /// Requires minimum of (period + 1) data points
     List<double?> calculate(List<double> closes, int period) {
       if (closes.length < period + 1) return [];

       List<double?> rsi = List.filled(closes.length, null);

       // Calculate price changes
       List<double> gains = [];
       List<double> losses = [];

       for (int i = 1; i < closes.length; i++) {
         double change = closes[i] - closes[i - 1];
         gains.add(change > 0 ? change : 0);
         losses.add(change < 0 ? change.abs() : 0);
       }

       // First average: Simple mean
       double avgGain = gains.sublist(0, period).reduce((a, b) => a + b) / period;
       double avgLoss = losses.sublist(0, period).reduce((a, b) => a + b) / period;

       // Calculate first RSI
       if (avgLoss == 0) {
         rsi[period] = 100.0;
       } else if (avgGain == 0) {
         rsi[period] = 0.0;
       } else {
         double rs = avgGain / avgLoss;
         rsi[period] = 100 - (100 / (1 + rs));
       }

       // Subsequent RSI values using Wilder's smoothing
       for (int i = period + 1; i < closes.length; i++) {
         avgGain = ((avgGain * (period - 1)) + gains[i - 1]) / period;
         avgLoss = ((avgLoss * (period - 1)) + losses[i - 1]) / period;

         if (avgLoss == 0) {
           rsi[i] = 100.0;
         } else if (avgGain == 0) {
           rsi[i] = 0.0;
         } else {
           double rs = avgGain / avgLoss;
           rsi[i] = 100 - (100 / (1 + rs));
         }
       }

       return rsi;
     }
   }
   ```

2. ema_calculator.dart:
   ```dart
   class EmaCalculator {
     /// Calculate EMA
     /// Multiplier = 2 / (period + 1)
     /// EMA[i] = (Close[i] - EMA[i-1]) * Multiplier + EMA[i-1]
     /// First EMA = SMA of first N periods
     List<double?> calculate(List<double> values, int period) {
       if (values.length < period) return [];

       List<double?> ema = List.filled(values.length, null);
       double multiplier = 2.0 / (period + 1);

       // Calculate first EMA as SMA
       double sum = values.sublist(0, period).reduce((a, b) => a + b);
       ema[period - 1] = sum / period;

       // Calculate subsequent EMAs
       for (int i = period; i < values.length; i++) {
         ema[i] = (values[i] - ema[i - 1]!) * multiplier + ema[i - 1]!;
       }

       return ema;
     }
   }
   ```

3. sma_calculator.dart:
   ```dart
   class SmaCalculator {
     /// Calculate Simple Moving Average
     List<double?> calculate(List<double> values, int period) {
       if (values.length < period) return [];

       List<double?> sma = List.filled(values.length, null);

       for (int i = period - 1; i < values.length; i++) {
         double sum = 0;
         for (int j = 0; j < period; j++) {
           sum += values[i - j];
         }
         sma[i] = sum / period;
       }

       return sma;
     }
   }
   ```

4. CREATE unit tests for each calculator in test/features/technicals/domain/calculators/:
   - Test with known inputs/outputs
   - Test edge cases: insufficient data, all zeros, all same values

5. REGISTER in DI

DELIVERABLES:
- RSI, EMA, SMA calculators working
- Unit tests passing
- DI registration
```

---

## Phase 3B: Advanced Technical Indicators

```
Implement MACD, Bollinger Bands, VWAP calculators.

CONTEXT: Builds on Phase 3A calculators (RSI, EMA, SMA already implemented).

IMPLEMENT in features/technicals/domain/calculators/:

1. macd_calculator.dart:
   ```dart
   class MacdResult {
     final List<double?> macdLine;
     final List<double?> signalLine;
     final List<double?> histogram;
     MacdResult(this.macdLine, this.signalLine, this.histogram);
   }

   class MacdCalculator {
     final EmaCalculator _emaCalculator = EmaCalculator();

     /// MACD = 12-period EMA - 26-period EMA
     /// Signal = 9-period EMA of MACD
     /// Histogram = MACD - Signal
     /// Use configurable periods for different timeframes
     MacdResult calculate(
       List<double> closes,
       {int fastPeriod = 12, int slowPeriod = 26, int signalPeriod = 9}
     ) {
       // Calculate fast and slow EMAs
       List<double?> fastEma = _emaCalculator.calculate(closes, fastPeriod);
       List<double?> slowEma = _emaCalculator.calculate(closes, slowPeriod);

       // Calculate MACD line
       List<double?> macdLine = List.filled(closes.length, null);
       for (int i = 0; i < closes.length; i++) {
         if (fastEma[i] != null && slowEma[i] != null) {
           macdLine[i] = fastEma[i]! - slowEma[i]!;
         }
       }

       // Calculate signal line (EMA of MACD)
       List<double> macdValues = macdLine.where((v) => v != null).cast<double>().toList();
       List<double?> signalEma = _emaCalculator.calculate(macdValues, signalPeriod);

       // Align signal line with macdLine indices
       List<double?> signalLine = List.filled(closes.length, null);
       int signalIndex = 0;
       for (int i = 0; i < macdLine.length; i++) {
         if (macdLine[i] != null) {
           if (signalIndex < signalEma.length && signalEma[signalIndex] != null) {
             signalLine[i] = signalEma[signalIndex];
           }
           signalIndex++;
         }
       }

       // Calculate histogram
       List<double?> histogram = List.filled(closes.length, null);
       for (int i = 0; i < closes.length; i++) {
         if (macdLine[i] != null && signalLine[i] != null) {
           histogram[i] = macdLine[i]! - signalLine[i]!;
         }
       }

       return MacdResult(macdLine, signalLine, histogram);
     }
   }
   ```

2. bollinger_bands_calculator.dart:
   ```dart
   class BollingerBandsResult {
     final List<double?> upper;
     final List<double?> middle;
     final List<double?> lower;
     BollingerBandsResult(this.upper, this.middle, this.lower);
   }

   class BollingerBandsCalculator {
     final SmaCalculator _smaCalculator = SmaCalculator();

     /// Middle Band = 20-period SMA
     /// Standard Deviation of last N closes
     /// Upper Band = Middle + (2 * StdDev)
     /// Lower Band = Middle - (2 * StdDev)
     BollingerBandsResult calculate(
       List<double> closes,
       {int period = 20, double stdDevMultiplier = 2.0}
     ) {
       List<double?> middle = _smaCalculator.calculate(closes, period);
       List<double?> upper = List.filled(closes.length, null);
       List<double?> lower = List.filled(closes.length, null);

       for (int i = period - 1; i < closes.length; i++) {
         // Calculate standard deviation
         List<double> window = closes.sublist(i - period + 1, i + 1);
         double mean = middle[i]!;
         double variance = window.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / period;
         double stdDev = sqrt(variance);

         upper[i] = mean + (stdDevMultiplier * stdDev);
         lower[i] = mean - (stdDevMultiplier * stdDev);
       }

       return BollingerBandsResult(upper, middle, lower);
     }
   }
   ```

3. vwap_calculator.dart:
   ```dart
   class VwapCalculator {
     /// VWAP = Cumulative(Typical Price * Volume) / Cumulative(Volume)
     /// Typical Price = (High + Low + Close) / 3
     /// Use rolling window matching EMA period (not daily reset for our use case)
     List<double?> calculate(
       List<OhlcModel> candles,
       {int? rollingPeriod} // if null, cumulative from start
     ) {
       List<double?> vwap = List.filled(candles.length, null);

       if (rollingPeriod == null) {
         // Cumulative VWAP
         double cumulativeTPV = 0; // Typical Price * Volume
         double cumulativeVolume = 0;

         for (int i = 0; i < candles.length; i++) {
           double typicalPrice = (candles[i].high + candles[i].low + candles[i].close) / 3;
           cumulativeTPV += typicalPrice * candles[i].volume;
           cumulativeVolume += candles[i].volume;

           vwap[i] = cumulativeVolume > 0 ? cumulativeTPV / cumulativeVolume : null;
         }
       } else {
         // Rolling window VWAP
         for (int i = rollingPeriod - 1; i < candles.length; i++) {
           double windowTPV = 0;
           double windowVolume = 0;

           for (int j = 0; j < rollingPeriod; j++) {
             int idx = i - j;
             double typicalPrice = (candles[idx].high + candles[idx].low + candles[idx].close) / 3;
             windowTPV += typicalPrice * candles[idx].volume;
             windowVolume += candles[idx].volume;
           }

           vwap[i] = windowVolume > 0 ? windowTPV / windowVolume : null;
         }
       }

       return vwap;
     }
   }
   ```

4. ADD unit tests

5. REGISTER in DI

DELIVERABLES:
- MACD, Bollinger Bands, VWAP calculators
- Unit tests passing
- DI registration
```

---

## Phase 3C: Dominant Cycle Calculator

```
Implement Dominant Cycle Period calculator using Hilbert Transform (Homodyne Discriminator method).

READ FIRST:
- hilbert transform notes.txt (contains exact implementation and formulas)

IMPLEMENT:

1. COPY the exact implementation from hilbert transform notes.txt into:
   features/technicals/domain/calculators/dominant_cycle_calculator.dart

   The file already contains a complete Dart implementation (lines 82-141). Use it exactly as provided.

2. CREATE wrapper to use with OhlcModel:
   ```dart
   class DominantCycleFacade {
     final DominantCycleCalculator _calculator = DominantCycleCalculator();

     /// Calculate dominant cycle from OHLC data
     /// Requires minimum 30-40 bars for stable results
     /// Returns cycle period in days (xx.xx format)
     double? calculate(List<OhlcModel> candles) {
       if (candles.length < 30) return null; // Insufficient data

       // Calculate midpoint prices: (High + Low) / 2
       List<double> midpoints = candles.map((c) => (c.high + c.low) / 2).toList();

       // Calculate dominant cycle
       double period = _calculator.calculate(midpoints);

       // Return null if result is invalid
       return (period > 0 && period <= 50) ? period : null;
     }
   }
   ```

3. CREATE unit test:
   - Test with 60 days of real stock data (e.g., AAPL)
   - Verify result is between 6 and 50 days
   - Test with insufficient data (returns null)

4. REGISTER in DI

IMPORTANT: This requires 30-40 days minimum of historical data. The algorithm is complex but the implementation is provided in hilbert transform notes.txt - use it exactly.

DELIVERABLES:
- Dominant Cycle calculator implemented
- Wrapper for OhlcModel
- Unit test passing
- DI registration

Phase 3 now complete - all technical calculations ready!
```

---

## Phase 4: Watchlists Page

```
Build the Watchlists management page with full CRUD operations.

SPECIFICATION REFERENCE:
- Watchlists page shows vertical scrollable list of watchlist boxes
- Each box: name (top, small font), symbols (alphabetically sorted, all caps), edit button (gear icon, bottom left), delete button (trash, bottom right)
- Below last watchlist (or if empty): Large "+" button to add watchlist
- Add/Edit dialog: text field for name, text field for symbols (comma/space separated)
- Input processing: Split by " " and ",", remove empty, convert to uppercase, sort alphabetically
- Bottom navigation bar: 4 items (Watchlists, Technicals, Sentiment, Settings) with current page highlighted

IMPLEMENT:

1. CREATE domain layer:
   - features/watchlist/domain/entities/watchlist.dart:
     ```dart
     class Watchlist {
       final String id;
       final String name;
       final List<String> symbols; // Always uppercase, sorted

       Watchlist({required this.id, required this.name, required this.symbols});
     }
     ```

   - features/watchlist/domain/repositories/watchlist_repository.dart (interface)

2. CREATE data layer:
   - features/watchlist/data/models/watchlist_model.dart (Freezed + Hive adapter)
   - features/watchlist/data/repositories/watchlist_repository_impl.dart (uses Hive)
   - Initialize Hive box: 'watchlistsBox'

3. CREATE BLoC:
   - features/watchlist/presentation/bloc/watchlist_bloc.dart
   - Events: LoadWatchlists, AddWatchlist, UpdateWatchlist, DeleteWatchlist
   - States: WatchlistInitial, WatchlistLoading, WatchlistLoaded, WatchlistError

4. CREATE UI:
   - features/watchlist/presentation/pages/watchlist_page.dart:
     * Scrollable ListView of watchlist cards
     * Each card: Card widget with name, symbols as Wrap of Chip widgets, IconButton for edit/delete
     * FloatingActionButton "+" to add new watchlist (or large button if list empty)

   - features/watchlist/presentation/widgets/watchlist_dialog.dart:
     * showDialog for add/edit
     * TextFormField for name (required)
     * TextFormField for symbols (required, hint: "AAPL, GOOGL, MSFT")
     * On save: Parse symbols (split by " " and ",", remove empty, toUpperCase, sort)
     * Validation: name not empty, at least 1 symbol, symbols match pattern (letters only)

   - features/watchlist/presentation/widgets/delete_confirmation_dialog.dart

5. CREATE bottom navigation:
   - shared/widgets/app_navigation_bar.dart:
     * BottomNavigationBar with 4 items: Watchlists, Technicals, Sentiment, Settings
     * Icons: list icon, candlestick icon, sentiment icon, settings icon
     * Highlight current page (use different color or pressed effect)
     * Use IndexedStack or go_router for navigation

6. UPDATE main.dart:
   - Setup navigation with initial route to Watchlists page
   - Wrap with BlocProvider for WatchlistBloc

7. STYLING:
   - Use theme colors from app_theme.dart
   - Cards with elevation: 2
   - Spacing: 16.0 between cards
   - Symbol chips: small, subtle background color
   - Professional financial app aesthetic

DELIVERABLES:
- Watchlist CRUD working
- Hive persistence
- Bottom navigation functional
- Input validation and formatting working
- Professional UI

TEST: Create, edit, delete watchlists. Restart app, verify persistence.
```

---

## Phase 5: Technicals Page Structure

```
Build Technicals page layout with selectors (watchlist, timeframe, date) and symbol list.

SPECIFICATION REFERENCE:
- Top section: Watchlist selector (dropdown), Timeframe selector (dropdown: Intraday/Swing/Long/Custom), End date selector
- End date selector: Default shows current date + "up-to-date". Left arrow to go back. When < today, shows: left arrow | date | right arrow
- Timeframe periods table:
  * Intraday (0-3 days): RSI(9, 80/20), 9 EMA, MACD(5,13,1), BB(20,2), VWAP(9)
  * Swing (3-10 days): RSI(11, 75/25), 13 & 50 EMA, MACD(12,26,9), BB(20,2), VWAP(13)
  * Long (10-21 days): RSI(14, 70/30), 20 SMA, MACD(12,26,9), BB(20,2), VWAP(20)
- Symbol list: Vertical, descending alphabetical (Z to A per spec), tappable to expand
- Expanded view will be implemented in next phase

IMPLEMENT:

1. CREATE domain entities:
   - features/technicals/domain/entities/timeframe_config.dart:
     ```dart
     class TimeframeConfig {
       final String name;
       final int rsiPeriod;
       final int rsiOverbought;
       final int rsiOversold;
       final List<int> emaPeriods; // [9] or [13, 50] or [20]
       final bool useSMA; // true for Long
       final int macdFast;
       final int macdSlow;
       final int macdSignal;
       final int bollingerPeriod;
       final double bollingerStdDev;
       final int vwapPeriod;

       // Presets
       static TimeframeConfig intraday = TimeframeConfig(
         name: 'Intraday',
         rsiPeriod: 9, rsiOverbought: 80, rsiOversold: 20,
         emaPeriods: [9], useSMA: false,
         macdFast: 5, macdSlow: 13, macdSignal: 1,
         bollingerPeriod: 20, bollingerStdDev: 2.0,
         vwapPeriod: 9,
       );

       static TimeframeConfig swing = TimeframeConfig(
         name: 'Swing',
         rsiPeriod: 11, rsiOverbought: 75, rsiOversold: 25,
         emaPeriods: [13, 50], useSMA: false,
         macdFast: 12, macdSlow: 26, macdSignal: 9,
         bollingerPeriod: 20, bollingerStdDev: 2.0,
         vwapPeriod: 13,
       );

       static TimeframeConfig long = TimeframeConfig(
         name: 'Long',
         rsiPeriod: 14, rsiOverbought: 70, rsiOversold: 30,
         emaPeriods: [20], useSMA: true,
         macdFast: 12, macdSlow: 26, macdSignal: 9,
         bollingerPeriod: 20, bollingerStdDev: 2.0,
         vwapPeriod: 20,
       );

       List<TimeframeConfig> get presets => [intraday, swing, long];
     }
     ```

2. CREATE BLoC:
   - features/technicals/presentation/bloc/technicals_bloc.dart
   - Events: SelectWatchlist, SelectTimeframe, SelectDate, ExpandSymbol, CollapseSymbol
   - State: TechnicalsState with selectedWatchlist, selectedTimeframe, selectedDate, expandedSymbol

3. CREATE UI:
   - features/technicals/presentation/pages/technicals_page.dart:

     Top section (pinned, doesn't scroll):
     * DropdownButton for watchlist selection (loads from WatchlistBloc)
     * DropdownButton for timeframe (Intraday, Swing, Long, Custom...)
       - "Custom..." opens dialog with fields for all parameters
     * Date selector widget:
       - Initial: [< Current Date | "up-to-date"]
       - When date < today: [< Date >]
       - Format: "MMM dd, yyyy"
       - Use IconButton for arrows, TextButton for date display

     Symbol list section (scrollable):
     * ListView.builder of symbol cards
     * Symbols from selected watchlist
     * Sort: descending alphabetical (Z at top, A at bottom)
     * Tappable cards to expand (Phase 6)

4. CREATE widgets:
   - features/technicals/presentation/widgets/date_selector.dart (animated transition between 2-button and 3-button modes)
   - features/technicals/presentation/widgets/custom_timeframe_dialog.dart

5. STYLING:
   - Top section: Container with bottom border, padding
   - Dropdowns: Consistent styling
   - Date buttons: Smooth animation on mode change
   - Symbol cards: Elevated, show symbol name only (collapsed state)

DELIVERABLES:
- Technicals page structure
- Watchlist/Timeframe/Date selectors working
- Symbol list displays from selected watchlist
- Date navigation functional (forward/back, stops at today)
- Custom timeframe dialog
- Timeframe presets configured correctly

TEST: Change watchlist, timeframe, date. Verify symbol list updates. Verify date selector UI transitions.
```

---

## Phase 6: Technicals Calculations & Expanded View

```
Implement technical calculations and expanded symbol view with Syncfusion charts.

SPECIFICATION REFERENCE:
- Expanded view fills screen (except navigation bar)
- Header: Symbol name (large) | Timeframe badge (tappable to change)
- Indicators (vertical): RSI, EMA/SMA, MACD, Dominant Cycle
- Syncfusion chart: Candlesticks with overlays (Bollinger, EMA/SMA, VWAP), RSI panel below, MACD panel below that
- Calculate up to selectedDate only

REQUIREMENTS:
- Fetch 60 days of historical data (for calculation buffer)
- Run calculations in isolate using compute()
- Cache data in Hive (TTL: 4 hours)
- Display loading spinner while calculating

IMPLEMENT:

1. CREATE use case:
   - features/technicals/domain/usecases/calculate_technicals_usecase.dart:
     ```dart
     class CalculateTechnicalsUsecase {
       final YahooFinanceApi _api;
       final RsiCalculator _rsiCalc;
       final EmaCalculator _emaCalc;
       final SmaCalculator _smaCalc;
       final MacdCalculator _macdCalc;
       final BollingerBandsCalculator _bbCalc;
       final VwapCalculator _vwapCalc;
       final DominantCycleFacade _cycleCalc;

       Future<TechnicalIndicatorsResult> execute({
         required String symbol,
         required DateTime endDate,
         required TimeframeConfig config,
       }) async {
         // Fetch OHLCV data from 60 days before endDate
         DateTime startDate = endDate.subtract(Duration(days: 60));
         List<OhlcModel> candles = await _api.getHistoricalData(
           symbol, startDate, endDate, '1d'
         );

         // Run calculations in isolate
         return await compute(_calculateInIsolate, {
           'candles': candles,
           'config': config,
         });
       }

       static TechnicalIndicatorsResult _calculateInIsolate(Map<String, dynamic> params) {
         // Extract params
         List<OhlcModel> candles = params['candles'];
         TimeframeConfig config = params['config'];
         List<double> closes = candles.map((c) => c.close).toList();

         // Calculate all indicators using config parameters
         // Return TechnicalIndicatorsResult
       }
     }

     class TechnicalIndicatorsResult {
       final List<double?> rsi;
       final Map<int, List<double?>> emas; // {9: [...], 13: [...], 50: [...]}
       final List<double?> sma;
       final MacdResult macd;
       final BollingerBandsResult bollinger;
       final List<double?> vwap;
       final double? dominantCycle;
       final List<OhlcModel> candles;
     }
     ```

2. UPDATE TechnicalsBloc:
   - Add LoadTechnicals event
   - Add TechnicalsCalculated state
   - Cache results in state

3. CREATE expanded view:
   - features/technicals/presentation/widgets/symbol_expanded_view.dart:

     Layout:
     * AppBar: Symbol name, Timeframe badge (tappable), Close button
     * Body: SingleChildScrollView with:
       - Syncfusion chart section (400-500px height)
       - Indicator details section (Column):
         * RSI card: Current value, color-coded (green 30-70, red outside), mini line chart
         * EMA/SMA card: Current values, relationship to price
         * MACD card: MACD/Signal/Histogram values, mini chart
         * Dominant Cycle card: "Dominant Cycle Period: XX.XX days"

4. INTEGRATE Syncfusion Charts:
   - features/technicals/presentation/widgets/technical_chart.dart:
     ```dart
     SfCartesianChart(
       primaryXAxis: DateTimeAxis(),
       primaryYAxis: NumericAxis(name: 'Price'),
       axes: [
         NumericAxis(name: 'RSI', opposedPosition: true),
         NumericAxis(name: 'MACD', opposedPosition: true),
       ],
       series: [
         CandleSeries<OhlcModel, DateTime>(
           dataSource: candles,
           xValueMapper: (data, _) => data.date,
           openValueMapper: (data, _) => data.open,
           highValueMapper: (data, _) => data.high,
           lowValueMapper: (data, _) => data.low,
           closeValueMapper: (data, _) => data.close,
         ),
         // Add LineSeries for Bollinger Bands (upper, middle, lower)
         // Add LineSeries for EMA/SMA overlays
         // Add LineSeries for VWAP
       ],
       indicators: [
         RsiIndicator<OhlcModel, DateTime>(
           seriesName: 'Candles',
           yAxisName: 'RSI',
           period: config.rsiPeriod,
           overbought: config.rsiOverbought,
           oversold: config.rsiOversold,
         ),
         MacdIndicator<OhlcModel, DateTime>(
           seriesName: 'Candles',
           yAxisName: 'MACD',
           shortPeriod: config.macdFast,
           longPeriod: config.macdSlow,
           period: config.macdSignal,
         ),
       ],
       zoomPanBehavior: ZoomPanBehavior(
         enablePinching: true,
         enablePanning: true,
       ),
     )
     ```

5. IMPLEMENT Hive caching:
   - Cache OhlcModel data with key: "{symbol}_ohlc_{startDate}_{endDate}"
   - TTL: 4 hours for intraday, 24 hours for daily
   - Check cache before API call

6. HANDLE insufficient data:
   - Show message if < 30 days available
   - Don't show Dominant Cycle if < 30 days
   - Gracefully handle missing indicator values

DELIVERABLES:
- Historical data fetching with caching
- All technical calculations running in isolate
- Expanded symbol view with all indicators
- Syncfusion chart with multi-panel display (price, RSI, MACD)
- Dominant Cycle displayed when sufficient data
- Loading states
- Error handling

TEST: Expand symbol, verify calculations. Change timeframe, verify indicators recalculate. Test with symbol that has insufficient data.
```

---

## Phase 7: Sentiment Page - Company Profile

```
Build Sentiment page with company profile section.

SPECIFICATION REFERENCE:
- Top: Watchlist selector
- Symbol list (collapsed): Vertical stack, tappable
- Expanded view:
  * Top left: Symbol (large, bold, all caps)
  * Below symbol (indented): Current quote/price
  * Top right of symbol: Company name (underlined)
  * Below company name: Company logo (80x80px)
  * Left of logo, under price: Company description (3-4 lines, scrollable, "Read more")
  * Under description: Peer list (collapsed: "Peers >", expanded: chips)

IMPLEMENT:

1. CREATE domain entities:
   - features/sentiment/domain/entities/company_profile.dart
   - features/sentiment/domain/entities/stock_quote.dart

2. CREATE repositories (already have Finnhub API client from Phase 2B):
   - features/sentiment/domain/repositories/sentiment_repository.dart (interface)
   - features/sentiment/data/repositories/sentiment_repository_impl.dart

3. CREATE BLoC:
   - features/sentiment/presentation/bloc/sentiment_bloc.dart
   - Events: SelectWatchlist, SelectSymbol, LoadSentimentData, TogglePeers, CollapseSentiment
   - State: SentimentState with selectedWatchlist, selectedSymbol, profileData, quoteData, peers, newsData, earningsData

4. CREATE UI:
   - features/sentiment/presentation/pages/sentiment_page.dart:
     * Top: Watchlist selector dropdown
     * Symbol list: ListView.builder of symbol cards
       - Show symbol + quick sentiment badge (placeholder for now)
     * Tappable to expand

   - features/sentiment/presentation/widgets/sentiment_expanded_view.dart:

     Company Profile Section:
     * Layout using Row, Column, Expanded:
       - Left column:
         * Symbol name (style: 24px, bold, all caps)
         * Quote price (indented, 20px, color: green/red for change)
         * Description (maxLines: 4, overflow: ellipsis, "Read more" expands)
         * Peers widget (collapsed/expanded)
       - Right column:
         * Company name (18px, underlined)
         * Company logo (CachedNetworkImage, 80x80, rounded corners)

     * Peers widget:
       - Collapsed: TextButton("Peers >")
       - Expanded: Wrap of peer chips (tappable to view that symbol)

5. IMPLEMENT data fetching:
   - On symbol selection:
     * Call Finnhub getCompanyProfile(symbol)
     * Call Finnhub getQuote(symbol)
     * Call Finnhub getPeers(symbol)
   - Cache profile: 7 days TTL
   - Cache quote: 30 seconds TTL
   - Show loading spinner while fetching
   - Handle errors gracefully

6. CREATE widgets:
   - features/sentiment/presentation/widgets/company_description.dart (expandable text)
   - features/sentiment/presentation/widgets/peer_list.dart (collapsible)

7. STYLING:
   - Professional layout with proper spacing
   - Logo: rounded corners (8px radius), border
   - Description: readable font, expand animation
   - Peer chips: small (height: 32), color from theme
   - Quote price: color based on change (green +, red -)

DELIVERABLES:
- Sentiment page structure
- Company profile section working
- Finnhub data fetching and caching
- Loading and error states
- Peer list collapsible
- Professional UI

TEST: Select different symbols, verify profile loads. Test peer expansion. Verify quote updates.
```

---

## Phase 8: Sentiment Page - News & Earnings

```
Complete Sentiment page with MarketAux news, sentiment scores, and Finnhub earnings.

SPECIFICATION REFERENCE:
- Below profile: Sentiment scores section (MarketAux sentiment, color-coded)
- Recent news section: Last 7 days, most recent first, headlines expandable to show blurb
- Earnings section: Recent earnings (last 4 quarters table), Earnings calendar (next 30 days)

IMPLEMENT:

1. UPDATE sentiment_expanded_view.dart to add below profile section:

   SENTIMENT SCORES SECTION:
   ```dart
   Card(
     child: Column(
       children: [
         Text('Sentiment Analysis', style: headline6),
         // MarketAux sentiment
         Row(
           children: [
             Text('MarketAux Sentiment:'),
             Spacer(),
             // Colored indicator based on score
             Container(
               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
               decoration: BoxDecoration(
                 color: _getSentimentColor(score),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Text(
                 score.toStringAsFixed(2),
                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
               ),
             ),
           ],
         ),
         Text('Based on ${articleCount} articles', style: caption),
       ],
     ),
   )
   ```

   Color coding:
   - score > 0.2: green
   - score < -0.2: red
   - -0.2 to 0.2: gray (neutral)

   RECENT NEWS SECTION:
   ```dart
   ExpansionTile(
     title: Text('Recent News (Last 7 Days)'),
     children: [
       ListView.builder(
         shrinkWrap: true,
         physics: NeverScrollableScrollPhysics(),
         itemCount: news.length,
         itemBuilder: (context, index) {
           return NewsItem(news: news[index]);
         },
       ),
     ],
   )
   ```

   News item widget:
   - Headline (bold, 2 lines max, TextOverflow.ellipsis)
   - Source + date (small, gray)
   - Sentiment dot (colored circle based on article sentiment)
   - Expandable to show:
     * Full headline
     * Description/blurb
     * Sentiment score
     * "Read full article" link button

   EARNINGS SECTION:
   ```dart
   Column(
     children: [
       // Recent Earnings
       Text('Recent Earnings', style: headline6),
       DataTable(
         columns: [
           DataColumn(label: Text('Quarter')),
           DataColumn(label: Text('Actual')),
           DataColumn(label: Text('Estimate')),
           DataColumn(label: Text('Surprise')),
         ],
         rows: earnings.map((e) => DataRow(
           cells: [
             DataCell(Text(e.period)),
             DataCell(Text('\$${e.actual.toStringAsFixed(2)}')),
             DataCell(Text('\$${e.estimate.toStringAsFixed(2)}')),
             DataCell(Text(
               '\$${e.surprise.toStringAsFixed(2)}',
               style: TextStyle(
                 color: e.surprise >= 0 ? Colors.green : Colors.red,
                 fontWeight: FontWeight.bold,
               ),
             )),
           ],
         )).toList(),
       ),

       SizedBox(height: 16),

       // Earnings Calendar
       Text('Upcoming Earnings (Next 30 Days)', style: headline6),
       ListView.builder(
         shrinkWrap: true,
         physics: NeverScrollableScrollPhysics(),
         itemCount: calendar.length,
         itemBuilder: (context, index) {
           final item = calendar[index];
           final isNear = item.date.difference(DateTime.now()).inDays <= 7;
           return ListTile(
             leading: Icon(
               Icons.calendar_today,
               color: isNear ? Colors.orange : Colors.grey,
             ),
             title: Text(DateFormat('MMM dd, yyyy').format(item.date)),
             subtitle: Text('Est. EPS: \$${item.epsEstimate.toStringAsFixed(2)}'),
             tileColor: isNear ? Colors.orange.withOpacity(0.1) : null,
           );
         },
       ),
     ],
   )
   ```

2. UPDATE SentimentBloc to fetch:
   - MarketAux news (last 7 days) when symbol selected
   - Calculate average sentiment from articles
   - Finnhub earnings surprises
   - Finnhub earnings calendar (next 30 days)

3. IMPLEMENT caching:
   - News: 4 hour TTL
   - Earnings: 24 hour TTL
   - Cache in Hive

4. CREATE widgets:
   - features/sentiment/presentation/widgets/news_item.dart (expandable)
   - features/sentiment/presentation/widgets/sentiment_gauge.dart (visual indicator)
   - features/sentiment/presentation/widgets/earnings_table.dart

5. HANDLE edge cases:
   - No news available: Show "No recent news for {symbol}"
   - No earnings data: Show "Earnings data not available"
   - API rate limits: Queue requests
   - Loading states: Skeleton loaders

6. STYLING:
   - Sentiment gauge: Visual bar or radial gauge
   - News items: Clean card design
   - Earnings table: Alternating row colors
   - Highlight earnings within 7 days

DELIVERABLES:
- MarketAux news integration (using your Basic plan)
- Sentiment scores displayed with color coding
- Recent news list with expansion
- Earnings surprises table
- Earnings calendar
- All data cached properly
- Loading and error states

TEST: Verify MarketAux API works with your key. Check sentiment calculation. Test with symbols with no recent news. Verify earnings data displays correctly.
```

---

## Phase 9: Settings Page

```
Implement Settings page for API key management with secure storage.

SPECIFICATION:
- API key configuration for Finnhub, MarketAux
- Secure storage using flutter_secure_storage
- Key validation before saving
- Help links for getting API keys

IMPLEMENT:

1. CREATE domain layer:
   - features/settings/domain/entities/api_config.dart
   - features/settings/domain/repositories/settings_repository.dart (interface)

2. CREATE data layer:
   - features/settings/data/datasources/secure_storage_datasource.dart:
     * Uses flutter_secure_storage
     * Methods: saveApiKey(provider, key), getApiKey(provider), deleteApiKey(provider)
     * Keys: 'finnhub_api_key', 'marketaux_api_key'

   - features/settings/data/repositories/settings_repository_impl.dart

3. CREATE BLoC:
   - features/settings/presentation/bloc/settings_bloc.dart
   - Events: LoadSettings, SaveApiKey, ValidateApiKey, ClearApiKey
   - States: SettingsInitial, SettingsLoading, SettingsLoaded, SettingsSaving, ValidationSuccess, ValidationFailure, SettingsError

4. CREATE UI:
   - features/settings/presentation/pages/settings_page.dart:

     Layout:
     ```dart
     Scaffold(
       appBar: AppBar(title: Text('Settings')),
       body: ListView(
         children: [
           // App Info
           ListTile(
             title: Text('Watchlist Technicals', style: headline5),
             subtitle: Text('Version 1.0.0'),
           ),
           Divider(),

           // API Keys Section
           Padding(
             padding: EdgeInsets.all(16),
             child: Text('API Configuration', style: headline6),
           ),

           // Finnhub
           ApiKeyTile(
             provider: 'Finnhub',
             logoAsset: 'assets/finnhub_logo.png', // or use Icon
             configured: state.finnhubConfigured,
             onConfigure: () => _showApiKeyDialog('Finnhub'),
           ),

           // MarketAux
           ApiKeyTile(
             provider: 'MarketAux',
             logoAsset: 'assets/marketaux_logo.png',
             configured: state.marketauxConfigured,
             onConfigure: () => _showApiKeyDialog('MarketAux'),
           ),

           Divider(),

           // Future: Theme toggle, cache management, etc.
         ],
       ),
     )
     ```

   - features/settings/presentation/widgets/api_key_tile.dart:
     * Shows provider name + logo
     * Status indicator: "Configured" (green checkmark) or "Not Set" (gray)
     * "Configure" button

   - features/settings/presentation/widgets/api_key_dialog.dart:
     ```dart
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Configure ${provider} API Key'),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Text('Enter your API key for ${provider}'),
             SizedBox(height: 16),
             TextFormField(
               controller: _keyController,
               obscureText: !_showKey,
               decoration: InputDecoration(
                 labelText: 'API Key',
                 suffixIcon: IconButton(
                   icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility),
                   onPressed: () => setState(() => _showKey = !_showKey),
                 ),
               ),
             ),
             SizedBox(height: 8),
             TextButton.icon(
               icon: Icon(Icons.open_in_new),
               label: Text('Get Free API Key'),
               onPressed: () => _launchUrl(_getSignupUrl(provider)),
             ),
           ],
         ),
         actions: [
           TextButton(
             child: Text('Clear'),
             onPressed: state.configured ? () => _clearKey() : null,
           ),
           TextButton(
             child: Text('Test'),
             onPressed: () => _testKey(),
           ),
           ElevatedButton(
             child: Text('Save'),
             onPressed: () => _saveKey(),
           ),
         ],
       ),
     );
     ```

5. IMPLEMENT key validation:
   - Finnhub: Test with /quote?symbol=AAPL
   - MarketAux: Test with /news/all?limit=1
   - Show success/error snackbar
   - Only save if validation passes (or user overrides)

6. INTEGRATE with API clients:
   - Update Finnhub API client to read key from secure storage on init
   - Update MarketAux API client to read key from secure storage on init
   - If key missing, throw ApiKeyMissingException
   - Show error dialog with "Go to Settings" button

7. IMPLEMENT signup URL helpers:
   ```dart
   String _getSignupUrl(String provider) {
     switch (provider) {
       case 'Finnhub':
         return 'https://finnhub.io/register';
       case 'MarketAux':
         return 'https://www.marketaux.com/register';
       default:
         return '';
     }
   }
   ```

DELIVERABLES:
- Settings page with API key management
- Secure storage for keys
- Key validation before saving
- Integration with API clients
- Help links for registration
- Error handling when keys missing

TEST: Configure API keys, test validation. Clear keys, verify API calls fail with helpful error. Restart app, verify keys persist.
```

---

## Phase 10: Navigation & Polish

```
Finalize navigation, add loading states, implement offline mode, optimize performance.

TASKS:

1. COMPLETE BOTTOM NAVIGATION:
   - Ensure smooth transitions between pages
   - Persist selected page on app restart (save to SharedPreferences)
   - Visual "pressed" effect for current page (use selectedItemColor, use different icons for selected/unselected)
   - Prevent redundant page reloads when tapping current page

2. GLOBAL ERROR HANDLING:
   - Wrap MaterialApp with error boundary
   - Catch and log unhandled exceptions
   - Show user-friendly error dialogs
   - Implement retry logic for network errors

3. IMPLEMENT LOADING STATES:
   - Create shared/widgets/loading_shimmer.dart (shimmer effect for cards)
   - Create shared/widgets/loading_skeleton.dart (skeleton loaders for lists)
   - Add to all list views: watchlists, symbols, news
   - Use CircularProgressIndicator for calculations

4. OPTIMIZE PERFORMANCE:
   - Wrap Syncfusion charts in RepaintBoundary
   - Use const constructors throughout
   - Use ListView.builder for all scrollable lists (already done)
   - Profile app with Flutter DevTools, fix any jank
   - Implement pagination for news (load 20 at a time)

5. IMPLEMENT OFFLINE MODE:
   - Create core/services/connectivity_service.dart:
     * Use connectivity_plus package
     * Stream<bool> connectivityStream
     * bool get isOnline

   - Before API calls:
     * Check connectivity
     * If offline, load from cache
     * Show "Offline" banner at top of screen (SnackBar or persistent banner)

   - Queue failed API calls:
     * When connection restored, retry queued calls

6. ADD PULL-TO-REFRESH:
   - Wrap list views with RefreshIndicator
   - On refresh:
     * Clear relevant cache
     * Fetch fresh data
     * Show refresh animation
   - Implement for: watchlist page, technicals symbol list, sentiment symbol list, news list

7. ADD EMPTY STATES:
   - Create shared/widgets/empty_state.dart:
     * Icon, message, optional action button

   - Add empty states:
     * Watchlists page: "Create your first watchlist" + large "+" button
     * No symbols in watchlist: "Add symbols to get started"
     * No news: "No recent news for {symbol}"
     * No earnings: "Earnings data not available"

   - Use appropriate icons (e.g., Icons.list_alt, Icons.article, Icons.calendar_today)

8. ADD SEARCH (optional but recommended):
   - In watchlist selection dropdowns: Add search filter
   - Use debounced search (300ms delay)
   - Filter symbols by typing

9. POLISH UI:
   - Consistent spacing: 8, 16, 24 px
   - Consistent elevation: 2 for cards, 4 for dialogs
   - Smooth animations: 200-300ms duration for expansions
   - Haptic feedback: Use HapticFeedback.lightImpact() on button presses
   - Dark mode: Ensure all colors have dark mode variants in app_theme.dart
   - Accessibility: Add Semantics labels for screen readers

10. ADD SPLASH SCREEN:
    - Create native splash screens (Android: launch_background.xml, iOS: LaunchScreen.storyboard)
    - Show app logo + name
    - Initialize Hive, DI, API keys during splash

11. ADD APP ICON:
    - Design icon (financial/chart theme)
    - Use flutter_launcher_icons package to generate for all platforms
    - Update android/app/src/main/res and ios/Runner/Assets.xcassets

DELIVERABLES:
- Smooth navigation with state persistence
- Global error handling
- Loading shimmers and skeletons
- Performance optimizations (60fps)
- Offline mode with banner
- Pull-to-refresh on all lists
- Empty states with helpful messages
- UI polish (animations, haptics, spacing)
- Splash screen and app icon

TEST: Navigate between pages smoothly. Turn off internet, verify offline mode. Pull to refresh lists. Check performance with DevTools.
```

---

## Phase 11: Testing & Final Polish

```
Add tests, fix bugs, prepare for release.

TASKS:

1. UNIT TESTS:
   - Test technical indicator calculators:
     * rsi_calculator_test.dart
     * ema_calculator_test.dart
     * sma_calculator_test.dart
     * macd_calculator_test.dart
     * bollinger_bands_calculator_test.dart
     * vwap_calculator_test.dart
     * dominant_cycle_calculator_test.dart
   - Use known inputs/outputs (compare with TradingView or TA-Lib)
   - Test edge cases: insufficient data, all zeros, all same values
   - Target: >70% coverage for calculators

   - Test input validation:
     * Watchlist name validation
     * Symbol parsing (split by space/comma, uppercase, sort)

   - Test data models:
     * Serialization/deserialization (toJson/fromJson)

2. WIDGET TESTS:
   - test/features/watchlist/presentation/pages/watchlist_page_test.dart:
     * Test watchlist CRUD operations
     * Test add dialog, edit dialog, delete confirmation

   - test/features/technicals/presentation/widgets/date_selector_test.dart:
     * Test date navigation (back, forward, today limit)

   - Test navigation:
     * Tap navigation bar items, verify page changes

3. INTEGRATION TESTS (optional, time permitting):
   - integration_test/app_test.dart:
     * Test flow: Create watchlist → View technicals → View sentiment
     * Test flow: Configure API keys → Fetch data

4. FIX BUGS:
   - Review all TODO comments in code
   - Fix any console warnings/errors
   - Handle edge cases:
     * Empty watchlists
     * Invalid/delisted symbols (API returns error)
     * Insufficient historical data (< 30 days)
     * Rate limit errors (show user-friendly message)
     * Date selection edge cases (weekends, holidays)

   - Test on multiple screen sizes (phone, tablet)
   - Test on both Android and iOS

5. DOCUMENTATION:
   - Create comprehensive README.md:
     ```markdown
     # Watchlist Technicals

     A Flutter app for tracking stock technical indicators and sentiment analysis.

     ## Features
     - Multiple watchlists with custom stock symbols
     - Technical indicators: RSI, EMA/SMA, MACD, Bollinger Bands, VWAP
     - Dominant Cycle Period calculation (Hilbert Transform)
     - Sentiment analysis from news articles
     - Company profiles and earnings data
     - Offline mode with caching

     ## Setup
     1. Clone repo
     2. Run `flutter pub get`
     3. Get free API keys:
        - Finnhub: https://finnhub.io/register
        - MarketAux: https://www.marketaux.com/register (Basic plan recommended)
     4. Run app: `flutter run`
     5. Configure API keys in Settings page

     ## Architecture
     - Clean Architecture with feature-first structure
     - BLoC for state management
     - Hive for local storage
     - Syncfusion Flutter Charts for visualization

     ## Technical Indicators
     - Intraday, Swing, and Long timeframe presets
     - Custom timeframe configuration
     - Historical data from Yahoo Finance
     - Calculations run in isolates for performance

     ## Screenshots
     [Add screenshots here]

     ## License
     MIT (or your choice)
     ```

   - Add dartdoc comments to public APIs
   - Create docs/API_USAGE.md with API integration details

6. PERFORMANCE PROFILING:
   - Run Flutter DevTools profiler
   - Check for memory leaks (dispose controllers, cancel subscriptions)
   - Optimize large widget builds
   - Ensure smooth scrolling (60fps)
   - Profile on physical device, not just emulator

7. PREPARE FOR RELEASE:
   - Update pubspec.yaml version: 1.0.0
   - Generate app icons (flutter_launcher_icons)
   - Configure Android manifest:
     * Internet permission: <uses-permission android:name="android.permission.INTERNET" />
     * App name, version
   - Configure iOS Info.plist:
     * App name, permissions
   - Create release builds:
     * Android: `flutter build apk --release` or `flutter build appbundle`
     * iOS: `flutter build ios --release`
   - Test release builds on physical devices

8. FINAL TESTING CHECKLIST:
   - [ ] All CRUD operations work (watchlists)
   - [ ] API integrations functional (Finnhub, MarketAux, Yahoo)
   - [ ] Technical calculations accurate (compare with TradingView)
   - [ ] Offline mode works (shows cached data, queue pending requests)
   - [ ] Error handling graceful (no crashes)
   - [ ] No console errors/warnings
   - [ ] Performance smooth (60fps scrolling, charts render quickly)
   - [ ] Works on different screen sizes (phone, tablet, landscape)
   - [ ] Dark mode looks good
   - [ ] API rate limits respected
   - [ ] All tests pass
   - [ ] Release builds successful

DELIVERABLES:
- Comprehensive unit test suite (>70% coverage for calculations)
- Widget tests for key flows
- All bugs fixed
- Documentation complete (README, API docs)
- Performance optimized
- Release builds configured
- App ready for deployment

CONGRATULATIONS! Your Watchlist Technicals app is complete! 🎉
```

---

## Summary

You now have 11 phases broken into specific, self-contained prompts. Each prompt:
- References the spec files for context
- Is completable within one context window
- Has clear deliverables
- Can be executed after a context compact

**Recommended workflow**:
1. Copy one prompt at a time from this file
2. Paste into Claude Code
3. Complete that phase
4. Verify deliverables
5. Move to next prompt

**MarketAux integration**: Prioritized in Phase 2A since you have the Basic paid plan ready. News and sentiment analysis are core features using your MarketAux API.

Good luck with your build! 🚀
