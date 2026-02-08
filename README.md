# Watchlist Technicals

A Flutter app for tracking stock technical indicators and sentiment analysis.

## Features

- **Multiple Watchlists** - Create and manage custom watchlists with stock symbols
- **Technical Indicators** - Calculate and visualize key technical indicators:
  - RSI (Relative Strength Index)
  - EMA/SMA (Exponential/Simple Moving Averages)
  - MACD (Moving Average Convergence Divergence)
  - Bollinger Bands
  - VWAP (Volume Weighted Average Price)
  - Dominant Cycle Period (Hilbert Transform / Homodyne Discriminator)
- **Sentiment Analysis** - News sentiment from MarketAux API
- **Company Profiles** - Company information and earnings data from Finnhub
- **Offline Mode** - Local caching with Hive for offline access
- **Dark Mode** - Full dark theme support
- **Pull-to-Refresh** - Refresh data on all list views

## Screenshots

[Add screenshots here]

## Setup

### Prerequisites

- Flutter SDK 3.10.7 or higher
- Dart SDK 3.0+
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd watchlist_technicals
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (Freezed models, Hive adapters):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### API Keys

The app requires API keys for external data sources. Configure these in the Settings page:

1. **Finnhub** (Required for quotes, company profiles, earnings)
   - Register at: https://finnhub.io/register
   - Free tier: 60 API calls/minute

2. **MarketAux** (Required for news sentiment)
   - Register at: https://www.marketaux.com/register
   - Free tier: 100 requests/day (Basic plan recommended for more)

3. **Yahoo Finance** (OHLC data)
   - No API key required - uses public endpoints

## Architecture

The app follows **Clean Architecture** with a feature-first structure:

```
lib/
├── core/                    # Shared utilities, theme, constants
│   ├── constants/           # API endpoints, app constants
│   ├── di/                  # Dependency injection (GetIt)
│   ├── error/               # Failure classes
│   ├── router/              # GoRouter configuration
│   ├── services/            # Connectivity, navigation persistence
│   └── theme/               # App colors, themes
├── features/
│   ├── technicals/          # Technical indicators feature
│   │   ├── data/            # Data sources, models, repositories
│   │   ├── domain/          # Entities, calculators, use cases
│   │   └── presentation/    # BLoC, pages, widgets
│   ├── sentiment/           # News & sentiment feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── settings/            # App settings & API keys
│   └── watchlist/           # Watchlist management
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/                  # Shared widgets (navigation, loading, etc.)
```

### Key Patterns

- **BLoC** for state management (`flutter_bloc`)
- **Repository Pattern** for data access abstraction
- **Dependency Injection** with `GetIt`
- **Functional Error Handling** with `dartz` (Either<Failure, Success>)
- **Immutable Models** with `Freezed`

## Technical Indicators

### Timeframe Presets

| Preset | EMA Periods | RSI | MACD | Use Case |
|--------|-------------|-----|------|----------|
| Intraday | 9, 21 | 14 | 12/26/9 | Day trading |
| Swing | 20, 50 | 14 | 12/26/9 | Swing trading |
| Long | 50, 200 | 14 | 12/26/9 | Position trading |

### Calculation Notes

- All indicators use standard formulas (compatible with TradingView)
- RSI uses Wilder's smoothing method
- EMA uses the standard multiplier: 2 / (period + 1)
- MACD default: 12-day fast, 26-day slow, 9-day signal
- Dominant Cycle uses Homodyne Discriminator algorithm

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/features/technicals/domain/calculators/rsi_calculator_test.dart
```

### Test Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Building for Release

### Android

```bash
# APK
flutter build apk --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Generate Splash Screen

```bash
dart run flutter_native_splash:create
```

### Generate App Icons

1. Add `assets/app_icon.png` (1024x1024 recommended)
2. Uncomment `flutter_launcher_icons` section in `pubspec.yaml`
3. Run:
   ```bash
   dart run flutter_launcher_icons
   ```

## Dependencies

### Core

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `get_it` | Dependency injection |
| `go_router` | Navigation |
| `dartz` | Functional programming |
| `freezed` | Immutable models |

### Data

| Package | Purpose |
|---------|---------|
| `dio` | HTTP client |
| `hive` | Local storage |
| `flutter_secure_storage` | API key storage |

### UI

| Package | Purpose |
|---------|---------|
| `syncfusion_flutter_charts` | Charts & candlesticks |
| `shimmer` | Loading effects |
| `cached_network_image` | Image caching |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Run analyzer: `flutter analyze`
6. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [Syncfusion Flutter Charts](https://www.syncfusion.com/flutter-widgets/flutter-charts) for charting
- [Finnhub](https://finnhub.io/) for financial data API
- [MarketAux](https://www.marketaux.com/) for news sentiment API
