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
