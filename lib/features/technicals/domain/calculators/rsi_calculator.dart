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
