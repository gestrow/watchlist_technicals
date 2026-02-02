# Building a Flutter technical analysis app: APIs, charts, and AI workflows

**Finnhub emerges as the clear winner for free-tier financial data** with 60 API calls/minute and WebSocket streaming—critical for a real-time mobile app. Twelve Data offers the best technical indicator coverage (100+ built-in) at $29/month when you outgrow free tiers. For charting, **Syncfusion Flutter Charts delivers the most complete financial charting solution** with 10+ built-in technical indicators, though fl_chart's recent v0.73.0 candlestick support makes it a viable MIT-licensed alternative. AI-assisted development with Claude Code works best when you provide exact mathematical formulas for indicators and explicit BLoC conventions—AI will hallucinate RSI and MACD calculations without precise specifications.

---

## Financial data APIs: Finnhub dominates the free tier landscape

The free API landscape has shifted dramatically. **IEX Cloud shut down in August 2024**, leaving Finnhub as the standout choice for mobile apps making direct API calls. Alpha Vantage's free tier dropped to just **25 calls/day**—essentially unusable for real-time applications.

| API | Free Rate Limit | Real-time Data | Technical Indicators | Historical Depth | Best Use Case |
|-----|-----------------|----------------|---------------------|------------------|---------------|
| **Finnhub** | **60/min** (no daily cap) | ✅ WebSocket (50 symbols) | 30+ via API | 1 year | Real-time apps |
| **Twelve Data** | 800/day, 8/min | Paid only | **100+ built-in** | 30+ years | TA-focused apps |
| **Alpha Vantage** | **25/day**, 5/min | Paid only | 50+ built-in | 20+ years | Historical analysis |
| **Yahoo Finance** | ~360/hour (unofficial) | 15-min delay | None | 30+ years | Prototyping only |
| **Polygon.io** | EOD only, 5/min | $199/month | Limited | 10+ years | US equities only |
| **EODHD** | 20/day | ❌ | None | 30+ years | International EOD |

**Finnhub's WebSocket capability is the differentiator.** You can stream real-time prices for 50 symbols simultaneously on the free tier—essential for watchlists and live charts. The API also includes **built-in candlestick pattern recognition** (hammer, engulfing, doji) and aggregate technical signals, reducing client-side computation.

**Twelve Data deserves serious consideration** despite its 800/day free limit. Its 100+ pre-computed technical indicators mean you avoid implementing RSI, MACD, and Bollinger Bands from scratch. At $29/month for the Grow plan, it becomes the most cost-effective option for production apps needing comprehensive indicator coverage.

### API implementation strategy for mobile

Direct API calls from a mobile app create specific challenges: shared API keys risk aggregate rate limit exhaustion across users, and embedded keys in APKs are easily extracted. The recommended architecture uses a **lightweight backend proxy** that caches frequently requested data, manages per-user rate limiting, and keeps API credentials server-side.

```
Mobile App → Backend Proxy (caches + rate limits) → Finnhub/Twelve Data
```

For development and testing, Finnhub's 60 calls/minute allows refreshing 10 stocks every 10 seconds—adequate for building and debugging. WebSocket connections should use exponential backoff reconnection logic, and all REST calls need **HTTP 429 handling with automatic retry after the cooldown period**.

### Yahoo Finance: understand the risks

Yahoo Finance's unofficial API provides excellent historical data (decades of OHLCV) but carries significant reliability risks. The endpoints change without notice—yfinance broke multiple times in 2024-2025. Yahoo actively blocks heavy usage and can ban IP ranges. For Flutter/Dart, the `yahoo_finance_data_reader` package on pub.dev wraps query2.finance.yahoo.com, but **commercial use violates Yahoo's Terms of Service**.

Use Yahoo only for prototyping or personal projects, never as a primary data source for production apps.

---

## Flutter charting libraries: Syncfusion leads, but licensing matters

Syncfusion Flutter Charts provides the most complete financial charting solution—native candlestick charts, **10+ built-in technical indicators**, multi-panel support for RSI/MACD below price charts, and excellent zoom/pan gestures. However, the Community License requires annual revenue under $1 million, fewer than 5 developers, and fewer than 10 total employees.

| Library | Candlesticks | Built-in Indicators | Multi-Panel | Zoom/Pan | License | Best For |
|---------|--------------|---------------------|-------------|----------|---------|----------|
| **Syncfusion** | ✅ Native | RSI, MACD, Bollinger, 7+ more | ✅ Native | ✅ Excellent | Community* | Full-featured apps |
| **fl_chart** | ✅ New (v0.73.0) | ❌ Manual | ❌ Manual | ✅ v1.0+ | MIT | General charting |
| **financial_chart** | ✅ Native | ❌ Manual | ✅ Resizable | ✅ Full | MIT | MIT alternative |
| **k_chart_plus** | ✅ Native | MACD, RSI, BOLL, KDJ, WR | ✅ Native | ✅ Full | Unknown | Crypto apps |
| **interactive_chart** | ✅ Native | Moving averages only | ❌ | ✅ Excellent | MIT | Simple charts |

*Community License: <$1M revenue, <5 developers, <10 employees

### Syncfusion's built-in indicators eliminate complexity

Syncfusion includes pre-built `BollingerBandIndicator`, `RsiIndicator`, `MacdIndicator`, `SmaIndicator`, `EmaIndicator`, and more. You pass your OHLCV data source, and the library handles all calculations:

```dart
SfCartesianChart(
  series: [CandleSeries<Candle, DateTime>(dataSource: candles, ...)],
  indicators: [
    BollingerBandIndicator<Candle, DateTime>(period: 20, standardDeviation: 2),
    RsiIndicator<Candle, DateTime>(period: 14, overbought: 70, oversold: 30),
  ],
)
```

For performance with **1000+ candles**, Syncfusion's `FastLineSeries` handles millions of points, and `updateDataSource()` enables efficient real-time updates without rebuilding the entire widget tree. Use `NumericAxis` or `DateTimeAxis`—never `CategoryAxis`—for large datasets.

### fl_chart's new candlestick support

Version 0.73.0 (January 2025) added native `CandlestickChart`, ending the workaround of stacking bar charts. The library remains the most popular open-source Flutter charting package with 7,200+ GitHub stars and excellent documentation at flchart.dev. **However, you'll implement technical indicators manually**—calculate RSI values in your BLoC and overlay as `LineSeries`.

### financial_chart: the emerging MIT alternative

This newer package (MIT licensed, December 2024) was purpose-built for financial applications with **native multi-panel support and resizable panel dividers**. While it lacks pre-computed indicators, its marker system enables custom overlays for fair value gaps, order blocks, and trend lines. Worth watching as the community grows.

### Performance optimization patterns

- **Run indicator calculations in isolates** using `compute()` to avoid blocking the UI thread
- **Implement on-demand loading**: fetch visible range plus 50-candle buffer, lazy-load on scroll
- **Wrap charts in `RepaintBoundary`** to isolate repaints from surrounding widgets
- **Use const constructors** throughout the chart widget tree

---

## AI-assisted Flutter development: specification precision prevents hallucination

Claude Code produces dramatically better Flutter/Dart output when specifications follow a structured PRD format with **explicit constraints, exact formulas, and three-tier boundaries**. The most common failures occur when AI must invent technical indicator mathematics or BLoC architectural patterns without guidance.

### The CLAUDE.md specification pattern

Create a `CLAUDE.md` file in your project root that Claude Code automatically reads for context:

```markdown
# Technical Analysis App

## Tech Stack
- Flutter 3.x, Dart 3.x
- State Management: flutter_bloc ^8.x (Cubit for simple, Bloc for complex)
- Navigation: go_router
- Serialization: freezed + json_serializable
- HTTP: dio with interceptors for auth and logging

## Project Structure
lib/
├── core/           # Theme, constants, utilities
├── features/       # Feature modules (auth, chart, watchlist)
│   └── chart/
│       ├── data/       # Repository, API data source, DTOs
│       ├── domain/     # Entities, indicator calculations
│       └── presentation/ # BLoC, pages, widgets
└── shared/         # Reusable widgets, services

## BLoC Conventions
- Events: Past tense for user actions (ChartTimeframeChanged)
- States: Sealed classes with Initial, Loading, Loaded, Error subtypes
- Always dispose StreamSubscriptions in close()
- Check mounted before setState after async operations

## Boundaries
✅ Always: Dispose controllers, use mounted checks, handle errors
⚠️ Ask First: Adding dependencies, changing database schema
🚫 Never: Business logic in widgets, setState for complex state, skip error handling
```

### Specifying technical indicators to prevent hallucination

**AI will generate incorrect RSI and MACD formulas without exact mathematical definitions.** Always include the complete algorithm:

```markdown
## RSI (Relative Strength Index) - EXACT IMPLEMENTATION

1. Calculate price changes: `change = close[i] - close[i-1]`
2. Separate gains (positive) and losses (absolute value of negative)
3. First average: Simple mean of first 14 periods
4. Subsequent averages (Wilder's smoothing):
   `avgGain = (prevAvgGain * 13 + currentGain) / 14`
5. RS = avgGain / avgLoss
6. RSI = 100 - (100 / (1 + RS))

Edge cases:
- avgLoss == 0 → RSI = 100
- avgGain == 0 → RSI = 0  
- Minimum data points: period + 1
```

Include similar precision for MACD (EMA multiplier = 2/(period+1), signal line as 9-period EMA of MACD line), Bollinger Bands (middle = 20-period SMA, bands = middle ± 2*stdDev), and any pattern recognition rules.

### Common AI mistakes in Flutter apps

Without explicit guidance, AI frequently generates:

- **Memory leaks**: Controllers created without `dispose()` calls
- **setState after async gap**: Missing `if (!mounted) return;` checks
- **BLoC anti-patterns**: Business logic in widgets, BLoC instances created inside `build()`
- **BuildContext misuse**: Accessing context after async operations or storing it in services

Your specification should include explicit rules:

```markdown
## Resource Management
- ALL TextEditingController, ScrollController, AnimationController must be disposed
- ALL StreamSubscriptions must be canceled in dispose() or BLoC.close()
- After ANY await, check `if (!mounted) return;` before calling setState
- Use FutureBuilder/StreamBuilder for async UI, not manual setState
```

### BLoC documentation that prevents deviation

Specify when to use Cubit versus full Bloc:

```markdown
## Cubit vs Bloc Decision

Use CUBIT:
- Simple state transitions (toggle theme, increment counter)
- Direct method calls sufficient
- Example: ThemeCubit, CounterCubit

Use BLOC:
- Event streams need transformation (debounce search, throttle scroll)
- Audit trail of events needed
- Complex multi-step flows
- Example: SearchBloc (with debounce), ChartDataBloc (with stream transforms)

Default: Start with Cubit, upgrade to Bloc only when event transformation is needed.
```

### UI layout specification format

Describe **intent and constraints**, not exact widget trees:

```markdown
## Chart Screen Layout

### Structure
- Persistent header: Symbol ticker, price, change percentage
- Main area: Candlestick chart with overlay indicators (MA lines)
- Below main: Resizable panel for RSI/MACD (user-selectable)
- Bottom toolbar: Timeframe buttons (1m, 5m, 15m, 1H, 4H, 1D)

### Responsiveness
- Portrait: Full-width chart, toolbar as horizontal scroll
- Landscape: Chart 70% width, indicator panel 30% (side-by-side)

### Constraints
- No hardcoded sizes—use Expanded, Flexible, FractionallySizedBox
- All spacing via theme tokens: theme.spacing.sm, theme.spacing.md
- Chart must maintain 16:9 aspect ratio minimum
```

### Testing specifications for BLoCs

Include test templates that AI should follow:

```markdown
## BLoC Testing Pattern

blocTest<ChartBloc, ChartState>(
  'emits [Loading, Loaded] when FetchCandles succeeds',
  build: () {
    when(() => mockRepo.getCandles(any(), any()))
        .thenAnswer((_) async => Right(testCandles));
    return ChartBloc(repository: mockRepo);
  },
  act: (bloc) => bloc.add(FetchCandlesRequested('AAPL', '1D')),
  expect: () => [ChartLoading(), ChartLoaded(testCandles)],
);

Every event must have success and failure test cases.
```

---

## Recommended architecture for your app

Based on this research, the optimal stack combines **Finnhub for real-time data** (free tier development, WebSocket for production), **Twelve Data for technical indicators** (when you need pre-computed values or exceed Finnhub limits), and **Syncfusion Flutter Charts** (if you qualify for Community License) or **fl_chart + custom indicator calculations** (for MIT licensing).

### Data layer
- Repository pattern abstracting API sources
- Local caching with Hive for offline candlestick history
- Indicator calculations in isolates to avoid UI jank

### Presentation layer
- BLoC for chart state (candle data, timeframe, active indicators)
- Cubit for simpler states (watchlist, theme toggle)
- Syncfusion or fl_chart for rendering

### AI development workflow
1. Create comprehensive CLAUDE.md with tech stack, conventions, boundaries
2. Write feature specs with exact indicator formulas and edge cases
3. Use Claude Code's Plan Mode before implementation
4. Review generated code for dispose() calls, mounted checks, and error handling

The combination of Finnhub's generous free tier, Syncfusion's built-in indicators (or manual implementation with fl_chart), and well-structured AI specifications gives you a clear path from prototype to production-ready technical analysis app.