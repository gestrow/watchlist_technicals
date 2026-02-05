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
