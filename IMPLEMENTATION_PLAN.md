# Watchlist Technicals App - Implementation Plan

## Overview
This plan breaks down the development of the Watchlist Technicals app into 11 sequential phases. Each phase includes a specific prompt to provide to Claude Code after completing the previous phase.

## Technology Stack
- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: flutter_bloc (Cubit for simple states, Bloc for complex)
- **Charts**: Syncfusion Flutter Charts (Community License)
- **Local Storage**: Hive (with encryption for API keys)
- **HTTP Client**: dio (with interceptors)
- **Price Data**: Yahoo Finance (yfinance_data_reader)
- **APIs**: Finnhub (profile, quotes, earnings), MarketAux (news, sentiment)

## Architecture Pattern
Clean Architecture with Feature-First structure:
```
lib/
├── core/                # Theme, constants, utilities, error handling
├── features/            # Feature modules
│   ├── watchlist/       # Watchlist CRUD
│   ├── technicals/      # Technical indicators & charts
│   ├── sentiment/       # News & sentiment analysis
│   └── settings/        # API key management
└── shared/              # Reusable widgets, services
```

---

## Phase 1: Project Setup & Core Architecture

**Estimated Complexity**: Medium
**Goal**: Set up the project foundation with proper architecture, dependencies, and core utilities.

### Prompt for Claude:
```
I need to set up the core architecture for my Flutter watchlist technicals app. Here's what needs to be done:

1. UPDATE DEPENDENCIES in pubspec.yaml:
   - Add syncfusion_flutter_charts (latest version)
   - Add hive and hive_flutter for local storage
   - Add flutter_secure_storage for API keys
   - Add dio for HTTP requests
   - Add freezed and json_serializable for models
   - Add go_router for navigation
   - Add build_runner as dev dependency

2. CREATE FOLDER STRUCTURE following Clean Architecture:
   lib/
   ├── core/
   │   ├── constants/
   │   │   ├── api_constants.dart      # API endpoints, keys
   │   │   └── app_constants.dart      # App-wide constants
   │   ├── theme/
   │   │   ├── app_theme.dart          # Material theme
   │   │   └── app_colors.dart         # Color palette
   │   ├── errors/
   │   │   └── failures.dart           # Error types
   │   └── utils/
   │       └── extensions.dart         # Dart extensions
   ├── features/
   │   ├── watchlist/
   │   │   ├── data/
   │   │   ├── domain/
   │   │   └── presentation/
   │   ├── technicals/
   │   │   ├── data/
   │   │   ├── domain/
   │   │   └── presentation/
   │   ├── sentiment/
   │   │   ├── data/
   │   │   ├── domain/
   │   │   └── presentation/
   │   └── settings/
   │       ├── data/
   │       ├── domain/
   │       └── presentation/
   └── shared/
       ├── widgets/
       └── services/

3. CREATE CORE FILES:
   - app_theme.dart: Define Material theme with primary colors, text styles
   - app_colors.dart: Color constants (use a professional financial app palette)
   - api_constants.dart: Base URLs for Finnhub, MarketAux, Yahoo Finance
   - app_constants.dart: Default values (RSI periods, timeframes, etc.)
   - failures.dart: Define ServerFailure, CacheFailure, ValidationFailure classes

4. CREATE DEPENDENCY INJECTION setup:
   - Create core/di/injection_container.dart using get_it
   - Set up for lazy initialization of singletons

5. UPDATE main.dart:
   - Initialize Hive
   - Initialize dependency injection
   - Wrap app with BlocProvider for any global state
   - Set up basic MaterialApp with theme

DO NOT implement any features yet - just the architecture scaffolding.
```

**Deliverables**:
- ✅ Updated pubspec.yaml with all dependencies
- ✅ Complete folder structure
- ✅ Core theme and constants files
- ✅ Dependency injection setup
- ✅ Main.dart configured

**Verification**: Run `flutter pub get` and `flutter run` - app should launch with a blank screen and no errors.

---

## Phase 2A: MarketAux API Client & Models (Priority)

**Estimated Complexity**: Medium
**Goal**: Implement MarketAux API client first since you have the Basic paid plan ready.

**CONTEXT**: This is for a Flutter app. MarketAux provides news with sentiment scores. You have the Basic plan (2500 requests/day, 20 articles per request). Reference the spec in "extra info on APIs.txt" for details.

### Prompt for Claude:
```
I'm building a Flutter financial app. I have a MarketAux Basic API key (2500 requests/day, 20 articles/request).

READ these files first for context:
- extra info on APIs.txt (contains MarketAux API details)
- research for financial api providers.md (contains architecture guidance)

Then implement:

1. CREATE features/sentiment/data/datasources/marketaux_api.dart:
   - Base URL: https://api.marketaux.com/v1
   - Use dio package for HTTP requests
   - Add interceptor to inject API key from flutter_secure_storage
   - Method: Future<List<NewsModel>> getNewsBySymbol(String symbol, DateTime from, DateTime to)
     * Endpoint: /news/all
     * Query params: symbols={symbol}, published_after={from}, published_before={to}, countries=us, entity_types=equity, limit=20, language=en
     * Parse response JSON and extract: headline, description, url, published_at, sentiment_score, source
   - Handle errors: network errors, rate limits (429), invalid responses
   - Add logging with dio interceptor

2. CREATE features/sentiment/data/models/news_model.dart using Freezed:
   ```dart
   @freezed
   class NewsModel with _$NewsModel {
     factory NewsModel({
       required String headline,
       required String description,
       required String url,
       required DateTime publishedAt,
       required double sentimentScore, // -1 to +1
       required String source,
       String? imageUrl,
     }) = _NewsModel;

     factory NewsModel.fromJson(Map<String, dynamic> json) => _$NewsModelFromJson(json);
   }
   ```

3. SETUP dio in core/di/injection_container.dart:
   - Register Dio instance with BaseOptions
   - Register MarketAux API client
   - Add logging interceptor

4. TEST the implementation:
   - Create a simple test widget that fetches news for "AAPL" from last 7 days
   - Print results to console to verify

IMPORTANT: Use the exact endpoint structure from MarketAux docs. Handle rate limiting gracefully. The sentiment_score is per-article, ranging -1 (negative) to +1 (positive).
```

**Deliverables**:
- ✅ MarketAux API client with error handling
- ✅ NewsModel with Freezed
- ✅ DI setup for API client
- ✅ Manual test confirming API works

---

## Phase 2B: Finnhub API Client & Models

**Estimated Complexity**: Medium
**Goal**: Implement Finnhub API for company profiles, quotes, and earnings.

**CONTEXT**: Finnhub free tier provides 60 calls/min. Used for company profiles, stock quotes, earnings data, and news. Reference "extra info on APIs.txt" for capabilities.

### Prompt for Claude:
```
Continue building the Flutter financial app. Now implement Finnhub API (free tier, 60 calls/min).

READ these files first:
- extra info on APIs.txt (Finnhub capabilities section)

Then implement:

1. CREATE features/sentiment/data/datasources/finnhub_api.dart:
   - Base URL: https://finnhub.io/api/v1
   - Use dio with interceptor for API key (query param: token={key})
   - Methods:
     * Future<CompanyProfileModel> getCompanyProfile(String symbol)
       - Endpoint: /stock/profile2?symbol={symbol}
       - Extract: name, ticker, logo, description, industry, weburl, country

     * Future<QuoteModel> getQuote(String symbol)
       - Endpoint: /quote?symbol={symbol}
       - Extract: c (current), h (high), l (low), o (open), pc (prev close)

     * Future<List<String>> getPeers(String symbol)
       - Endpoint: /stock/peers?symbol={symbol}
       - Returns array of peer symbol strings

     * Future<List<EarningsModel>> getEarningsSurprises(String symbol)
       - Endpoint: /stock/earnings?symbol={symbol}
       - Extract: actual, estimate, period (quarter), surprise

     * Future<List<EarningsCalendarModel>> getEarningsCalendar({String? symbol})
       - Endpoint: /calendar/earnings?symbol={symbol}&from={30_days_ago}&to={today}
       - Extract: date, epsEstimate, symbol

   - Implement rate limiting: Max 60 calls/min using a queue
   - Handle 429 (rate limit) errors with retry after delay

2. CREATE models in features/sentiment/data/models/:
   - company_profile_model.dart (using Freezed)
   - quote_model.dart (using Freezed)
   - earnings_model.dart (using Freezed)
   - earnings_calendar_model.dart (using Freezed)

3. REGISTER in core/di/injection_container.dart

4. TEST with manual widget: Fetch profile + quote for "AAPL"

IMPORTANT: Respect 60 calls/min rate limit. Cache responses in memory or Hive for repeated requests.
```

**Deliverables**:
- ✅ Finnhub API client with rate limiting
- ✅ All Finnhub models
- ✅ DI registration
- ✅ Manual test

---

## Phase 2C: Yahoo Finance Client & OHLC Models

**Estimated Complexity**: Medium
**Goal**: Implement Yahoo Finance data fetching for historical OHLCV data.

**CONTEXT**: Yahoo Finance provides decades of free historical data but is unofficial. Used for technical indicator calculations. Reference "research for financial api providers.md" section on Yahoo Finance.

### Prompt for Claude:
```
Now I need to implement the data layer for all APIs. Here's what to build:

1. CREATE API CLIENTS:

   A. Finnhub API Client (features/sentiment/data/datasources/finnhub_api.dart):
      - Base URL: https://finnhub.io/api/v1
      - Methods needed:
        * getCompanyProfile(symbol) -> /stock/profile2
        * getQuote(symbol) -> /quote
        * getPeers(symbol) -> /stock/peers
        * getCompanyNews(symbol, from, to) -> /company-news
        * getEarningsSurprises(symbol) -> /stock/earnings
        * getEarningsCalendar(symbol) -> /calendar/earnings
      - Use dio with interceptors for API key injection and error handling
      - Rate limit: 60 calls/min (implement rate limiting queue)

   B. MarketAux API Client (features/sentiment/data/datasources/marketaux_api.dart):
      - Base URL: https://api.marketaux.com/v1
      - Methods needed:
        * getNewsBySymbol(symbol, from, to) -> /news/all?symbols=
        * Returns news with sentiment_score per entity
      - Rate limit: 100 calls/day (free tier)

   C. Yahoo Finance Client (features/technicals/data/datasources/yahoo_finance_api.dart):
      - Use a simple HTTP client or package for Yahoo Finance
      - Method: getHistoricalData(symbol, startDate, endDate, interval)
      - Returns OHLCV data for technical calculations
      - Implement retry logic and error handling

2. CREATE DATA MODELS using Freezed:

   In features/sentiment/data/models/:
   - company_profile_model.dart (name, logo, description, industry, etc.)
   - quote_model.dart (current, high, low, open, previousClose, change, percentChange)
   - news_model.dart (headline, description, url, publishedDate, sentiment, source)
   - earnings_model.dart (actual, estimate, surprise, period)

   In features/technicals/data/models/:
   - ohlc_model.dart (open, high, low, close, volume, date)
   - technical_indicator_model.dart (name, value, signal)

   In features/watchlist/data/models/:
   - watchlist_model.dart (id, name, symbols)

3. CREATE REPOSITORY INTERFACES in domain layer:
   - features/sentiment/domain/repositories/sentiment_repository.dart
   - features/technicals/domain/repositories/technicals_repository.dart
   - features/watchlist/domain/repositories/watchlist_repository.dart

4. IMPLEMENT REPOSITORY CLASSES in data layer:
   - Repositories should handle data fetching, caching, and error mapping
   - Use Either<Failure, Success> pattern from dartz for error handling

5. SET UP HIVE:
   - Create Hive adapters for all models that need local storage
   - Initialize boxes: watchlistsBox, quotesBox, profilesBox, newsBox, ohlcBox
   - Implement cache expiration logic (TTL for different data types)

6. REGISTER in dependency injection:
   - Register all API clients
   - Register all repositories

Use exact formulas from the documentation. Include proper error handling, logging, and type safety.
```
Implement Yahoo Finance client for OHLCV historical data.

READ: research for financial api providers.md (Yahoo Finance section)

Then implement:

1. CREATE features/technicals/data/datasources/yahoo_finance_api.dart:
   - Use http package or yahoo_finance_data_reader package
   - Method: Future<List<OhlcModel>> getHistoricalData(String symbol, DateTime start, DateTime end, String interval)
   - Intervals: 1d (daily), 1h (hourly), 15m, 5m
   - Parse CSV or JSON response into OhlcModel list
   - Handle errors: symbol not found, date range issues
   - Add retry logic (Yahoo can be flaky)

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

4. TEST: Fetch 60 days of daily OHLCV for "AAPL"

**Deliverables for Phase 2 (A+B+C)**:
- ✅ MarketAux API client (news + sentiment)
- ✅ Finnhub API client (profiles, quotes, earnings)
- ✅ Yahoo Finance client (OHLCV data)
- ✅ All data models with Freezed
- ✅ DI registration

**Verification**: All three APIs can fetch data successfully.

---

## Phase 3A: Core Technical Indicators (RSI, EMA, SMA)

**Estimated Complexity**: Medium
**Goal**: Implement basic technical indicators with exact mathematical formulas.

**CONTEXT**: These calculators will process OHLCV data from Yahoo Finance to generate technical indicators. Must use exact formulas to avoid AI hallucination.

### Prompt for Claude:
```
Now implement all technical indicator calculations in the domain layer. These must use EXACT formulas to avoid hallucination.

1. CREATE TECHNICAL INDICATOR CALCULATORS in features/technicals/domain/calculators/:

   A. rsi_calculator.dart:
      ```
      RSI Formula (Wilder's Smoothing):
      1. change = close[i] - close[i-1]
      2. Separate gains (positive) and losses (abs of negative)
      3. First average: Simple mean of first N periods
      4. Subsequent: avgGain = (prevAvgGain * (N-1) + currentGain) / N
      5. RS = avgGain / avgLoss
      6. RSI = 100 - (100 / (1 + RS))
      Edge cases: avgLoss == 0 → RSI = 100, avgGain == 0 → RSI = 0
      ```

   B. ema_calculator.dart:
      ```
      EMA Formula:
      Multiplier = 2 / (period + 1)
      EMA[i] = (Close[i] - EMA[i-1]) * Multiplier + EMA[i-1]
      First EMA = SMA of first N periods
      ```

   C. sma_calculator.dart:
      ```
      SMA Formula:
      SMA = Sum of last N closes / N
      ```

   D. macd_calculator.dart:
      ```
      MACD Formula:
      MACD Line = 12-period EMA - 26-period EMA
      Signal Line = 9-period EMA of MACD Line
      Histogram = MACD Line - Signal Line
      (Use configurable periods for intraday/swing/long)
      ```

   E. bollinger_bands_calculator.dart:
      ```
      Bollinger Bands Formula:
      Middle Band = 20-period SMA
      Standard Deviation = sqrt(sum((close - SMA)^2) / period)
      Upper Band = Middle + (2 * StdDev)
      Lower Band = Middle - (2 * StdDev)
      ```

   F. vwap_calculator.dart:
      ```
      VWAP Formula:
      Typical Price = (High + Low + Close) / 3
      VWAP = Cumulative(Typical Price * Volume) / Cumulative(Volume)
      Reset daily or use rolling window matching EMA period
      ```

   G. dominant_cycle_calculator.dart:
      ```
      Use the EXACT implementation from hilbert transform notes.txt
      This includes:
      - Midpoint calculation: (High + Low) / 2
      - Detrending with 7-tap filter
      - Hilbert Transform (I and Q components)
      - Homodyne Discriminator
      - Period calculation with constraints (6-50 bars)
      Requires minimum 30-40 bars of historical data
      ```

2. CREATE TIMEFRAME CONFIGURATIONS in features/technicals/domain/entities/timeframe_config.dart:
   ```dart
   class TimeframeConfig {
     final String name;
     final int rsiPeriod;
     final int rsiOverbought;
     final int rsiOversold;
     final List<int> emaPeriods; // Can have 1 or 2 values
     final bool useSMA; // true for Long, false for others
     final MacdConfig macd;
     final BollingerConfig bollinger;

     // Presets
     static TimeframeConfig intraday = ...;
     static TimeframeConfig swing = ...;
     static TimeframeConfig long = ...;
   }
   ```

   Default values from spec:
   - Intraday (0-3 days): RSI(9-10, 80/20), 9 EMA, MACD(5,13,1), BB(20,2)
   - Swing (3-10 days): RSI(10-12, 75/25), 13 & 50 EMA, MACD(12,26,9), BB(20,2)
   - Long (10-21 days): RSI(14, 70/30), 20 SMA, MACD(12,26,9), BB(20,2)

3. CREATE INDICATOR AGGREGATOR (features/technicals/domain/usecases/calculate_technicals.dart):
   - Takes OHLCV data and TimeframeConfig
   - Calculates all indicators for given timeframe
   - Returns TechnicalIndicators entity
   - Run calculations in isolates using compute() to avoid UI blocking

4. ADD UNIT TESTS:
   - Test each calculator with known inputs/outputs
   - Verify edge cases (insufficient data, zero values, etc.)

IMPORTANT: All calculations must match standard TA-Lib implementations. Use List<double> for efficiency, not dynamic types.
```

**Deliverables**:
- ✅ All technical indicator calculators with exact formulas
- ✅ Dominant Cycle calculator implementation
- ✅ Timeframe configuration presets
- ✅ Indicator aggregator with isolate support
- ✅ Unit tests for all calculations

**Verification**: Test with known stock data and compare results to TradingView or TA-Lib outputs.

---

## Phase 4: Watchlists Page

**Estimated Complexity**: Medium
**Goal**: Build the watchlist management page with full CRUD operations.

### Prompt for Claude:
```
Implement the Watchlists page with full CRUD functionality. Refer to the specification:

1. CREATE BLOC for watchlist management (features/watchlist/presentation/bloc/):
   - watchlist_bloc.dart with events:
     * LoadWatchlists
     * AddWatchlist(name, symbols)
     * UpdateWatchlist(id, name, symbols)
     * DeleteWatchlist(id)
   - States: WatchlistInitial, WatchlistLoading, WatchlistLoaded, WatchlistError
   - Use Hive for persistence

2. CREATE MODELS:
   - Watchlist entity (domain/entities/watchlist.dart)
   - Input validation for watchlist names and symbols

3. BUILD UI (features/watchlist/presentation/pages/watchlist_page.dart):

   LAYOUT:
   - Scrollable vertical list of watchlist boxes
   - Each box shows:
     * Watchlist name (small font, top)
     * Stock symbols (alphabetically sorted, all caps, displayed as chips or text)
     * Edit button (gear icon, bottom left)
     * Delete button (trash icon, bottom right)

   - Below last watchlist (or if empty): Large "+" button to add new watchlist

   ADD/EDIT DIALOG:
   - Text field for watchlist name
   - Text field for symbols (comma/space separated input)
   - On save: Split input by " " and ",", remove empty strings, convert to uppercase, sort alphabetically
   - Validate: No empty names, at least one symbol, valid symbol format

   DELETE CONFIRMATION:
   - Show confirmation dialog before deleting

4. STYLING:
   - Use Card widgets for watchlist boxes with elevation
   - Professional financial app aesthetic (dark mode friendly)
   - Smooth animations for add/delete operations
   - Responsive padding and spacing

5. NAVIGATION BAR INTEGRATION:
   - Add bottom navigation bar with 4 items: Watchlists, Technicals, Sentiment, Settings
   - Highlight current page (pressed/depressed effect)
   - Navigation uses go_router or simple IndexedStack

IMPORTANT: Follow BLoC best practices - no business logic in widgets, proper disposal, error handling.
```

**Deliverables**:
- ✅ WatchlistBloc with all events/states
- ✅ Watchlist page UI with CRUD dialogs
- ✅ Input validation and symbol formatting
- ✅ Bottom navigation bar structure
- ✅ Hive persistence working

**Verification**: Create, edit, delete watchlists. Restart app and verify persistence.

---

## Phase 5: Technicals Page - Part 1 (Structure & Selectors)

**Estimated Complexity**: Medium
**Goal**: Build the technicals page layout with watchlist selector, timeframe selector, and date selector.

### Prompt for Claude:
```
Implement the Technicals page structure and top selectors. Refer to specification:

1. CREATE BLOC (features/technicals/presentation/bloc/):
   - technicals_bloc.dart with events:
     * SelectWatchlist(watchlistId)
     * SelectTimeframe(timeframeConfig)
     * SelectDate(date)
     * LoadTechnicals(symbol)
     * ExpandSymbol(symbol)
     * CollapseSymbol()
   - States: TechnicalsInitial, TechnicalsLoading, TechnicalsLoaded, TechnicalsError
   - Track: selectedWatchlist, selectedTimeframe, selectedDate, expandedSymbol, technicalData

2. BUILD UI (features/technicals/presentation/pages/technicals_page.dart):

   TOP SECTION (always visible):

   A. Watchlist Selector (dropdown):
      - Shows all user's watchlists
      - On change: Load symbols from selected watchlist

   B. Timeframe Selector (dropdown):
      - Options: "Intraday", "Swing", "Long", "Custom..."
      - On "Custom": Show dialog with fields for:
        * Name
        * RSI period, overbought/oversold levels
        * EMA/SMA periods (checkbox for SMA vs EMA)
        * MACD parameters (fast, slow, signal)
        * Bollinger parameters (period, std dev)
      - Selected timeframe affects all calculations

   C. End Date Selector:
      - Default state: Single button showing current date with "up-to-date" label
      - Shows left arrow button to go back one day
      - When date < today: Show left arrow | date display | right arrow
      - Right arrow disappears when date == today
      - Date format: "MMM dd, yyyy"

   SYMBOL LIST SECTION (scrollable):
   - Vertical stack of symbol boxes
   - Symbols from selected watchlist in descending alphabetical order (Z to A at spec says descending)
   - Each box shows symbol name (initially collapsed)
   - Tappable to expand

3. STYLING:
   - Top section fixed/pinned while list scrolls
   - Dropdown buttons with consistent styling
   - Date selector with smooth transitions when expanding to 3 buttons
   - Symbol boxes with elevation and hover effects

IMPORTANT: Don't implement technical calculations yet - just the UI structure and selector logic. Expanded symbol view can be placeholder for now.
```

**Deliverables**:
- ✅ TechnicalsBloc with selection logic
- ✅ Top section with 3 selectors working
- ✅ Symbol list displaying from selected watchlist
- ✅ Date navigation working correctly
- ✅ Custom timeframe dialog

**Verification**: Select different watchlists, timeframes, dates. Symbol list should update correctly.

---

## Phase 6: Technicals Page - Part 2 (Calculations & Expanded View)

**Estimated Complexity**: Very High
**Goal**: Implement technical calculations, Syncfusion charts, and expanded symbol view.

### Prompt for Claude:
```
Now implement the technical calculations and expanded symbol view with Syncfusion charts:

1. IMPLEMENT DATA FETCHING in TechnicalsBloc:
   - When symbol expanded: Fetch historical OHLCV data from Yahoo Finance
   - Date range: selectedDate - (60 days) to selectedDate (need buffer for calculations)
   - Cache data in Hive with TTL (4 hours for intraday data, 24 hours for daily)
   - Run calculations in isolate using compute() to avoid blocking UI

2. CALCULATE INDICATORS:
   - Use the timeframe config to determine periods
   - Calculate: RSI, EMA/SMA, MACD, Bollinger Bands, VWAP, Dominant Cycle
   - Calculate up to selectedDate (not beyond)
   - Handle insufficient data gracefully

3. BUILD EXPANDED SYMBOL VIEW (features/technicals/presentation/widgets/symbol_detail_view.dart):

   LAYOUT (fills screen except navigation bar):

   A. Header:
      - Symbol name (large, bold) | Timeframe badge (tappable to change)
      - Close button or back gesture

   B. Indicators (vertical list):
      - RSI:
        * Current value with color (green if 30-70, red if overbought/oversold)
        * Small line chart showing last 20 RSI values

      - EMA/SMA:
        * Current values for each period
        * Relationship to current price (above/below)

      - MACD:
        * MACD line value
        * Signal line value
        * Histogram value
        * Small visualization (line + histogram)

      - Bollinger Bands:
        * Current price position relative to bands
        * Band width
        * % from middle

   C. Dominant Cycle (bottom):
      - "Dominant Cycle Period: XX.XX days"
      - Only shown if sufficient data (30+ days)

4. INTEGRATE SYNCFUSION CHARTS:
   - Add candlestick chart at top of expanded view
   - Overlay: Bollinger Bands, EMA/SMA lines, VWAP
   - Below main chart: RSI panel (with overbought/oversold lines)
   - Below RSI: MACD panel (line, signal, histogram)
   - Configure zoom/pan gestures
   - Use DateTimeAxis for x-axis
   - Format: Show last 30-60 candles by default, scrollable

5. OPTIMIZATION:
   - Wrap chart in RepaintBoundary
   - Use const constructors where possible
   - Lazy load data (only fetch when expanded)
   - Show loading spinner while calculating

IMPORTANT: Match the exact specifications for indicator display order and formatting. Test with multiple symbols and timeframes.
```

**Deliverables**:
- ✅ Historical data fetching from Yahoo Finance
- ✅ Technical calculations integrated
- ✅ Expanded symbol view with all indicators
- ✅ Syncfusion charts with multiple panels
- ✅ Dominant Cycle display
- ✅ Loading states and error handling

**Verification**: Expand different symbols, change timeframes and dates. Verify calculations match TradingView. Test with insufficient data.

---

## Phase 7: Sentiment Page - Part 1 (Profile & Structure)

**Estimated Complexity**: Medium
**Goal**: Build sentiment page structure with company profile from Finnhub.

### Prompt for Claude:
```
Implement the Sentiment page structure with company profile view:

1. CREATE BLOC (features/sentiment/presentation/bloc/):
   - sentiment_bloc.dart with events:
     * SelectWatchlist(watchlistId)
     * SelectSymbol(symbol)
     * LoadSentimentData(symbol)
     * CollapseSymbol()
     * TogglePeerList()
   - States: SentimentInitial, SentimentLoading, SentimentLoaded, SentimentError
   - Track: selectedWatchlist, selectedSymbol, profileData, newsData, earningsData

2. BUILD UI (features/sentiment/presentation/pages/sentiment_page.dart):

   TOP SECTION:
   - Watchlist selector (same as technicals page)

   SYMBOL LIST (collapsed view):
   - Vertical stack of symbol boxes
   - Show symbol name + quick sentiment score if available (from API)
   - Tappable to expand

3. BUILD EXPANDED SYMBOL VIEW (features/sentiment/presentation/widgets/sentiment_detail_view.dart):

   COMPANY PROFILE SECTION:
   - Layout:
     * Top left: Symbol (large, bold, all caps)
     * Below symbol: Current quote/price (indented)
     * Top right of symbol: Company name (underlined)
     * Below company name: Company logo (image from Finnhub)
     * Left of logo, under price: Company description (scrollable text, 3-4 lines visible)
     * Under description: Peer list (collapsed by default)
       - Shows "Peers >" when collapsed
       - Expands to show peer symbols as tappable chips

   - Data from Finnhub:
     * getCompanyProfile(symbol) - name, logo, description, industry
     * getQuote(symbol) - current price
     * getPeers(symbol) - peer list

4. IMPLEMENT DATA FETCHING:
   - Fetch from Finnhub when symbol expanded
   - Cache profile data (rarely changes) - 7 day TTL
   - Cache quote - 30 second TTL
   - Handle API rate limiting (60 calls/min)
   - Show loading states for each section

5. STYLING:
   - Professional layout with proper spacing
   - Company logo: 80x80px with rounded corners
   - Description: 2-3 line preview with "Read more" expansion
   - Peer chips: Small, tappable, with subtle background

IMPORTANT: Don't implement news/sentiment scores yet - just the profile section. Use placeholder for sentiment section.
```

**Deliverables**:
- ✅ SentimentBloc with selection logic
- ✅ Sentiment page structure with symbol list
- ✅ Expanded view with company profile
- ✅ Finnhub API integration for profile/quote/peers
- ✅ Loading and error states

**Verification**: Select different watchlists and symbols. Verify profile data loads correctly. Test peer list expansion.

---

## Phase 8: Sentiment Page - Part 2 (News & Earnings)

**Estimated Complexity**: High
**Goal**: Complete sentiment page with news, sentiment scores, and earnings data.

### Prompt for Claude:
```
Complete the Sentiment page by adding news, sentiment analysis, and earnings:

1. INTEGRATE MARKETAUX API:
   - Fetch news for selected symbol (last 7 days)
   - Extract sentiment_score from response
   - Cache news: 4 hour TTL
   - Handle 100 calls/day rate limit

2. INTEGRATE FINNHUB EARNINGS:
   - getEarningsSurprises(symbol) - last 4 quarters
   - getEarningsCalendar(symbol) - next 30 days
   - Cache: 24 hour TTL

3. ADD TO EXPANDED SYMBOL VIEW (below profile section):

   SENTIMENT SCORES SECTION:
   - Title: "Sentiment Analysis"
   - Show individual sentiment scores from each source:
     * MarketAux Sentiment: X.XX (scale: -1 to +1)
       - Color coded: green (>0.2), red (<-0.2), gray (neutral)
       - Show as gauge or colored bar
     * Finnhub sentiment if available from news
   - Show number of articles analyzed

   RECENT NEWS SECTION:
   - Title: "Recent News (Last 7 Days)"
   - List of news items (most recent first):
     * Headline (bold, 2 lines max)
     * Source + date (small text)
     * Sentiment indicator (colored dot or badge)
     * Tappable to expand
   - Expanded news item:
     * Full headline
     * News description/blurb (3-4 lines)
     * Sentiment score
     * "Read more" link (opens URL if available)
   - Show loading spinner while fetching
   - Handle no news available gracefully

   EARNINGS SECTION:
   - Title: "Earnings"

   - Recent Earnings (last 4 quarters):
     * Table format:
       | Quarter | Actual | Estimate | Surprise |
     * Color code surprise: green (beat), red (miss)

   - Earnings Calendar (next 30 days):
     * List format:
       - Date: MMM DD, YYYY
       - Estimated EPS
       - Time (if available)
     * Highlight if earnings within next 7 days

4. IMPLEMENT INFINITE SCROLL:
   - Initial load: Last 7 days of news (up to 20 articles)
   - Pagination: Load more if available (respect API limits)

5. ERROR HANDLING:
   - Graceful degradation if API fails
   - Show cached data with "Last updated: X hours ago"
   - Retry button for failed requests

IMPORTANT: Respect API rate limits. Show loading skeleton while fetching. News list should be performant with ListView.builder.
```

**Deliverables**:
- ✅ MarketAux API integration
- ✅ Sentiment scores display
- ✅ Recent news list with expansion
- ✅ Earnings surprises table
- ✅ Earnings calendar
- ✅ Rate limiting and caching
- ✅ Error handling

**Verification**: Test with multiple symbols. Verify sentiment scores, news, and earnings load correctly. Test with symbols that have no recent news.

---

## Phase 9: Settings Page

**Estimated Complexity**: Medium
**Goal**: Implement settings page for API key management.

### Prompt for Claude:
```
Implement the Settings page for API key management:

1. CREATE BLOC (features/settings/presentation/bloc/):
   - settings_bloc.dart with events:
     * LoadSettings
     * SaveApiKey(provider, key)
     * ValidateApiKey(provider, key)
     * ClearApiKey(provider)
   - States: SettingsInitial, SettingsLoading, SettingsLoaded, SettingsSaving, SettingsError

2. IMPLEMENT SECURE STORAGE:
   - Use flutter_secure_storage to store API keys
   - Keys to store:
     * finnhub_api_key
     * marketaux_api_key
     * alpha_vantage_api_key (optional for future)
   - Never log or expose keys in plain text

3. BUILD UI (features/settings/presentation/pages/settings_page.dart):

   LAYOUT:
   - App title and version at top

   - API Keys Section:
     * Section header: "API Configuration"
     * For each provider (Finnhub, MarketAux, Alpha Vantage):
       - Provider name with logo/icon
       - Status indicator: "Configured" (green) or "Not Set" (gray)
       - "Configure" button

   - Configuration Dialog (per provider):
     * Provider name and description
     * Text field for API key (obscured with ••••)
     * Show/hide toggle for key
     * "Get Free Key" link (opens provider signup page)
     * Test button (validates key with test API call)
     * Save button
     * Clear button (if key exists)

   - Additional Settings (future expansion):
     * Theme toggle (light/dark mode)
     * Data refresh intervals
     * Cache management

4. IMPLEMENT KEY VALIDATION:
   - Test Finnhub key: Call /quote?symbol=AAPL
   - Test MarketAux key: Call /news/all with limit=1
   - Show success/error message after test
   - Only save if validation passes (or allow override)

5. INTEGRATE WITH API CLIENTS:
   - API clients should read keys from secure storage
   - Show helpful error messages when keys missing
   - Provide deep link to settings from error states

6. STYLING:
   - Professional settings UI with sections
   - Clear visual feedback for configured vs unconfigured
   - Secure input fields with proper masking
   - Help text explaining where to get keys

IMPORTANT: Security is critical. Never store keys in plain SharedPreferences. Validate keys before saving. Provide clear instructions for users.
```

**Deliverables**:
- ✅ SettingsBloc with key management logic
- ✅ Secure storage implementation
- ✅ Settings page UI with key configuration
- ✅ API key validation
- ✅ Integration with API clients
- ✅ Help documentation

**Verification**: Configure API keys, test validation. Restart app and verify keys persist. Test API calls use configured keys.

---

## Phase 10: Navigation & Polish

**Estimated Complexity**: Medium
**Goal**: Finalize navigation, add polish, optimize performance.

### Prompt for Claude:
```
Finalize the app with navigation, polish, and optimization:

1. COMPLETE BOTTOM NAVIGATION:
   - Implement smooth page transitions
   - Persist navigation state on app restart
   - Visual indicator for current page (pressed effect)
   - Prevent redundant page reloads when tapping current page

2. ADD GLOBAL ERROR HANDLING:
   - Catch unhandled exceptions
   - Show user-friendly error dialogs
   - Log errors for debugging
   - Implement retry logic where appropriate

3. IMPLEMENT LOADING STATES:
   - Skeleton loaders for lists
   - Shimmer effects for cards
   - Progress indicators for calculations
   - Smooth transitions when data loads

4. OPTIMIZE PERFORMANCE:
   - Implement pagination for long symbol lists
   - Use ListView.builder for all scrollable lists
   - Wrap expensive widgets in RepaintBoundary
   - Use const constructors throughout
   - Profile app and fix any jank

5. ADD OFFLINE MODE:
   - Check connectivity before API calls
   - Show cached data when offline
   - Display "Offline" banner when no connection
   - Queue API calls for when connection restored

6. IMPLEMENT PULL-TO-REFRESH:
   - Add to all list views (watchlists, symbols, news)
   - Clear cache and fetch fresh data
   - Show refresh animation

7. ADD EMPTY STATES:
   - Watchlists page: "Create your first watchlist"
   - No symbols in watchlist: "Add symbols to get started"
   - No news: "No recent news for this symbol"
   - With helpful illustrations or icons

8. ADD SEARCH (optional but recommended):
   - Search bar for symbol lookup in large watchlists
   - Debounced search to avoid excessive filtering

9. POLISH UI:
   - Consistent spacing and padding throughout
   - Smooth animations for expansions/collapses
   - Haptic feedback for button presses (subtle)
   - Dark mode support with proper contrast
   - Accessibility: semantic labels, readable font sizes

10. ADD SPLASH SCREEN:
    - Professional splash screen with app logo
    - Initialize app while splash showing

IMPORTANT: Test on multiple screen sizes. Ensure smooth 60fps performance. All lists should handle hundreds of items efficiently.
```

**Deliverables**:
- ✅ Complete navigation system
- ✅ Global error handling
- ✅ Loading and empty states
- ✅ Performance optimizations
- ✅ Offline mode
- ✅ Pull-to-refresh
- ✅ UI polish and animations
- ✅ Splash screen

**Verification**: Test app flow end-to-end. Check performance with large watchlists. Test offline mode. Verify smooth animations.

---

## Phase 11: Testing & Final Polish

**Estimated Complexity**: Medium
**Goal**: Add tests, final bug fixes, and prepare for release.

### Prompt for Claude:
```
Final phase - testing, bug fixes, and release preparation:

1. ADD UNIT TESTS:
   - Test all technical indicator calculators
   - Test Dominant Cycle calculator
   - Test input validation (watchlist names, symbols)
   - Test data model serialization
   - Target: >70% code coverage for business logic

2. ADD WIDGET TESTS:
   - Test watchlist CRUD operations
   - Test navigation between pages
   - Test symbol expansion/collapse
   - Test timeframe and date selectors

3. ADD INTEGRATION TESTS:
   - Test complete user flows:
     * Create watchlist → View technicals → View sentiment
     * Configure API keys → Fetch data
     * Offline mode → Online mode transition

4. FIX BUGS:
   - Review all TODO comments
   - Fix any console warnings
   - Handle edge cases:
     * Empty watchlists
     * Invalid symbols
     * API failures
     * Insufficient historical data
     * Date selection edge cases

5. DOCUMENTATION:
   - Add README.md with:
     * App description
     * Setup instructions
     * How to get API keys
     * Screenshots
   - Add code documentation (dartdoc) for public APIs
   - Create CONTRIBUTING.md if open sourcing

6. PERFORMANCE PROFILING:
   - Use Flutter DevTools to profile
   - Fix any memory leaks
   - Optimize large builds
   - Ensure no jank in scrolling

7. PREPARE FOR RELEASE:
   - Update app version in pubspec.yaml
   - Generate app icons for all platforms
   - Configure Android manifest (permissions, internet)
   - Configure iOS Info.plist
   - Test build on physical devices (Android/iOS)

8. FINAL TESTING CHECKLIST:
   - [ ] All CRUD operations work
   - [ ] API integrations functional
   - [ ] Technical calculations accurate
   - [ ] Offline mode works
   - [ ] Error handling graceful
   - [ ] No console errors/warnings
   - [ ] Smooth performance (60fps)
   - [ ] Works on different screen sizes
   - [ ] Dark mode looks good
   - [ ] API rate limits respected

IMPORTANT: Don't skip testing. Real devices behave differently than simulators. Test with actual API keys and real data.
```

**Deliverables**:
- ✅ Comprehensive test suite
- ✅ All bugs fixed
- ✅ Documentation complete
- ✅ Performance optimized
- ✅ Release builds configured
- ✅ Ready for deployment

**Verification**: Run all tests. Build release APK/IPA. Test on physical devices. Verify app store requirements met.

---

## Additional Notes

### API Key Requirements
- **Finnhub**: Register at https://finnhub.io/register (free tier)
- **MarketAux**: Register at https://www.marketaux.com/register (free tier)
- **Yahoo Finance**: No key required (unofficial API)

### Syncfusion License
- Community License: <$1M revenue, <5 developers, <10 employees
- Register at: https://www.syncfusion.com/sales/communitylicense
- Add license key in main.dart before runApp()

### Development Best Practices
- Always run calculations in isolates
- Cache aggressively to reduce API calls
- Handle rate limits gracefully
- Test with edge cases (no data, API failures)
- Profile performance regularly
- Use const constructors everywhere possible

### Troubleshooting
- If Yahoo Finance breaks: Switch to Finnhub historical (limited free tier)
- If rate limits hit: Implement queue system or upgrade API tier
- If performance issues: Profile with DevTools, check for unnecessary rebuilds
- If Syncfusion issues: Check license registration, update package

---

## Completion Criteria

The app is complete when:
1. ✅ All 4 pages functional (Watchlists, Technicals, Sentiment, Settings)
2. ✅ All technical indicators calculate correctly
3. ✅ Dominant Cycle displays for supported symbols
4. ✅ Sentiment scores and news display
5. ✅ Offline mode works with cached data
6. ✅ API keys configurable in settings
7. ✅ Tests pass with good coverage
8. ✅ Performance is smooth (60fps)
9. ✅ No critical bugs
10. ✅ App builds successfully for Android/iOS

**Estimated Total Development Time**: 60-80 hours (for experienced Flutter developer)

Good luck with your build! 🚀
