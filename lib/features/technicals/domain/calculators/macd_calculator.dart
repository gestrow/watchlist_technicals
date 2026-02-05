import 'ema_calculator.dart';

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
