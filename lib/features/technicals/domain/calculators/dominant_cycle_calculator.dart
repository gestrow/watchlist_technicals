import 'dart:math' as math;

import '../../data/models/ohlc_model.dart';

class DominantCycleCalculator {
  /// Calculates the Dominant Cycle Period using the Homodyne Discriminator.
  /// Needs at least 15-20 bars to stabilize; 30-50 bars is recommended.
  double calculate(List<double> prices) {
    if (prices.length < 15) return 0.0; // Not enough data to process filters

    int n = prices.length;

    // Arrays to store intermediate values for the filter taps
    List<double> detrender = List.filled(n, 0.0);
    List<double> i1 = List.filled(n, 0.0);
    List<double> q1 = List.filled(n, 0.0);
    List<double> period = List.filled(n, 0.0);

    // Smoothed real and imaginary components
    double smoothRe = 0.0;
    double smoothIm = 0.0;
    double currentPeriod = 20.0; // Initial seed value

    // Loop through prices starting after the 7-bar filter warm-up
    for (int i = 7; i < n; i++) {
      // 1. Detrend the signal (Remove the price trend to find the wave)
      // Using a 7-tap Hilbert Transform filter
      detrender[i] = (0.0962 * prices[i] +
                      0.5769 * prices[i - 2] -
                      0.5769 * prices[i - 4] -
                      0.0962 * prices[i - 6]) *
          (0.1 * currentPeriod + 0.8);

      // 2. Compute In-Phase (I) and Quadrature (Q) components
      // I is the detrended signal delayed; Q is the Hilbert Transform of I
      i1[i] = detrender[i - 3];
      q1[i] = (0.0962 * detrender[i] +
               0.5769 * detrender[i - 2] -
               0.5769 * detrender[i - 4] -
               0.0962 * detrender[i - 6]) *
          (0.1 * currentPeriod + 0.8);

      // 3. Homodyne Discriminator (Phase calculation)
      // We calculate the complex product of current (I,Q) and previous (I,Q)
      double re = i1[i] * i1[i - 1] + q1[i] * q1[i - 1];
      double im = i1[i] * q1[i - 1] - q1[i] * i1[i - 1];

      // 4. Smooth the Re and Im parts with an Alpha-Beta filter (Smoothing Factor = 0.2)
      smoothRe = 0.2 * re + 0.8 * smoothRe;
      smoothIm = 0.2 * im + 0.8 * smoothIm;

      // 5. Convert phase change to period
      double tempPeriod = 0.0;
      if (smoothIm != 0 && smoothRe != 0) {
        // Calculate the phase change using ArcTangent
        // result is in radians, convert to degrees
        tempPeriod =
            360 / (math.atan(smoothIm / smoothRe) * (180 / math.pi));
      }

      // Constrain the period to realistic market cycles (6 to 50 bars)
      if (tempPeriod > 1.5 * currentPeriod) tempPeriod = 1.5 * currentPeriod;
      if (tempPeriod < 0.67 * currentPeriod) tempPeriod = 0.67 * currentPeriod;
      if (tempPeriod < 6) tempPeriod = 6;
      if (tempPeriod > 50) tempPeriod = 50;

      // 6. Final Smoothing of the period value
      currentPeriod = 0.33 * tempPeriod + 0.67 * currentPeriod;
      period[i] = currentPeriod;
    }

    return period.last;
  }
}

class DominantCycleFacade {
  final DominantCycleCalculator _calculator = DominantCycleCalculator();

  /// Calculate dominant cycle from OHLC data
  /// Requires minimum 30-40 bars for stable results
  /// Returns cycle period in days (xx.xx format)
  double? calculate(List<OhlcModel> candles) {
    if (candles.length < 30) return null; // Insufficient data

    // Calculate midpoint prices: (High + Low) / 2
    List<double> midpoints = candles.map((c) => (c.high + c.low) / 2).toList();

    // Calculate dominant cycle
    double period = _calculator.calculate(midpoints);

    // Return null if result is invalid
    return (period > 0 && period <= 50) ? period : null;
  }
}
