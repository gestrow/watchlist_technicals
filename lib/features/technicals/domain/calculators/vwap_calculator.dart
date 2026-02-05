import '../../data/models/ohlc_model.dart';

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
