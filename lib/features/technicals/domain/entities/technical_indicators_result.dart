import 'package:equatable/equatable.dart';

import '../../data/models/ohlc_model.dart';
import '../calculators/bollinger_bands_calculator.dart';
import '../calculators/macd_calculator.dart';

/// Result of technical indicator calculations for a symbol.
class TechnicalIndicatorsResult extends Equatable {
  /// The original OHLCV candle data.
  final List<OhlcModel> candles;

  /// RSI values aligned with candle indices.
  final List<double?> rsi;

  /// EMA values by period (e.g., {9: [...], 13: [...], 50: [...]}).
  final Map<int, List<double?>> emas;

  /// SMA values (only populated when useSMA is true).
  final List<double?> sma;

  /// MACD line, signal line, and histogram.
  final MacdResult macd;

  /// Bollinger Bands upper, middle, and lower.
  final BollingerBandsResult bollinger;

  /// VWAP values.
  final List<double?> vwap;

  /// Dominant cycle period in days (null if insufficient data).
  final double? dominantCycle;

  /// The symbol this result is for.
  final String symbol;

  /// The end date used for calculation.
  final DateTime endDate;

  /// Timestamp when this result was calculated.
  final DateTime calculatedAt;

  const TechnicalIndicatorsResult({
    required this.candles,
    required this.rsi,
    required this.emas,
    required this.sma,
    required this.macd,
    required this.bollinger,
    required this.vwap,
    required this.dominantCycle,
    required this.symbol,
    required this.endDate,
    required this.calculatedAt,
  });

  /// Returns true if there's enough data for reliable calculations.
  bool get hasEnoughData => candles.length >= 30;

  /// Returns the most recent RSI value.
  double? get currentRsi => rsi.isNotEmpty ? rsi.last : null;

  /// Returns the most recent close price.
  double? get currentPrice => candles.isNotEmpty ? candles.last.close : null;

  /// Returns the most recent EMA values by period.
  Map<int, double?> get currentEmas {
    return emas.map((period, values) => MapEntry(
          period,
          values.isNotEmpty ? values.last : null,
        ));
  }

  /// Returns the most recent SMA value.
  double? get currentSma => sma.isNotEmpty ? sma.last : null;

  /// Returns the most recent MACD values.
  ({double? macdLine, double? signalLine, double? histogram}) get currentMacd {
    return (
      macdLine: macd.macdLine.isNotEmpty ? macd.macdLine.last : null,
      signalLine: macd.signalLine.isNotEmpty ? macd.signalLine.last : null,
      histogram: macd.histogram.isNotEmpty ? macd.histogram.last : null,
    );
  }

  /// Returns the most recent Bollinger Bands values.
  ({double? upper, double? middle, double? lower}) get currentBollinger {
    return (
      upper: bollinger.upper.isNotEmpty ? bollinger.upper.last : null,
      middle: bollinger.middle.isNotEmpty ? bollinger.middle.last : null,
      lower: bollinger.lower.isNotEmpty ? bollinger.lower.last : null,
    );
  }

  /// Returns the most recent VWAP value.
  double? get currentVwap => vwap.isNotEmpty ? vwap.last : null;

  @override
  List<Object?> get props => [
        symbol,
        endDate,
        calculatedAt,
        candles.length,
      ];
}
