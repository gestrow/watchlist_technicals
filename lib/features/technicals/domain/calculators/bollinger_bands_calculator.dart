import 'dart:math';

import 'sma_calculator.dart';

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
