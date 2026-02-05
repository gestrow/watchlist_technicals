import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/technicals/domain/calculators/bollinger_bands_calculator.dart';

void main() {
  late BollingerBandsCalculator calculator;

  setUp(() {
    calculator = BollingerBandsCalculator();
  });

  group('BollingerBandsCalculator', () {
    test('middle band equals SMA', () {
      final closes = List.generate(25, (i) => 100.0 + i.toDouble());
      final result = calculator.calculate(closes);

      // Middle band at index 19 (period=20) should be SMA of first 20 values
      double sma = closes.sublist(0, 20).reduce((a, b) => a + b) / 20;
      expect(result.middle[19], closeTo(sma, 0.0001));
    });

    test('bands are null before period', () {
      final closes = List.generate(25, (i) => 100.0 + i.toDouble());
      final result = calculator.calculate(closes);

      for (int i = 0; i < 19; i++) {
        expect(result.upper[i], isNull);
        expect(result.middle[i], isNull);
        expect(result.lower[i], isNull);
      }
    });

    test('upper band is above middle, lower band is below', () {
      // Prices with some variance
      final closes = [
        100.0, 102.0, 99.0, 101.0, 98.0,
        103.0, 97.0, 105.0, 96.0, 104.0,
        95.0, 106.0, 94.0, 107.0, 93.0,
        108.0, 92.0, 109.0, 91.0, 110.0,
        90.0, 111.0, 89.0, 112.0, 88.0,
      ];
      final result = calculator.calculate(closes);

      for (int i = 19; i < closes.length; i++) {
        expect(result.upper[i]!, greaterThan(result.middle[i]!));
        expect(result.lower[i]!, lessThan(result.middle[i]!));
      }
    });

    test('bands are symmetric around middle', () {
      final closes = [
        100.0, 102.0, 99.0, 101.0, 98.0,
        103.0, 97.0, 105.0, 96.0, 104.0,
        95.0, 106.0, 94.0, 107.0, 93.0,
        108.0, 92.0, 109.0, 91.0, 110.0,
      ];
      final result = calculator.calculate(closes);

      for (int i = 19; i < closes.length; i++) {
        double upperDist = result.upper[i]! - result.middle[i]!;
        double lowerDist = result.middle[i]! - result.lower[i]!;
        expect(upperDist, closeTo(lowerDist, 0.0001));
      }
    });

    test('flat prices produce bands equal to price', () {
      final closes = List.generate(25, (_) => 50.0);
      final result = calculator.calculate(closes);

      // StdDev = 0, so upper = middle = lower = 50.0
      for (int i = 19; i < closes.length; i++) {
        expect(result.upper[i], closeTo(50.0, 0.0001));
        expect(result.middle[i], closeTo(50.0, 0.0001));
        expect(result.lower[i], closeTo(50.0, 0.0001));
      }
    });

    test('custom period and multiplier', () {
      // period=5, multiplier=1.0
      final closes = [10.0, 12.0, 11.0, 13.0, 14.0, 15.0, 13.0];
      final result = calculator.calculate(closes, period: 5, stdDevMultiplier: 1.0);

      expect(result.middle.length, 7);
      // Middle at index 4 = SMA(5) = (10+12+11+13+14)/5 = 12.0
      expect(result.middle[4], closeTo(12.0, 0.0001));

      // StdDev at index 4
      double mean = 12.0;
      double variance = ([10.0, 12.0, 11.0, 13.0, 14.0]
          .map((v) => (v - mean) * (v - mean))
          .reduce((a, b) => a + b)) / 5;
      double stdDev = variance > 0 ? _sqrt(variance) : 0;

      expect(result.upper[4], closeTo(mean + stdDev, 0.0001));
      expect(result.lower[4], closeTo(mean - stdDev, 0.0001));
    });

    test('higher multiplier produces wider bands', () {
      final closes = [
        100.0, 102.0, 99.0, 101.0, 98.0,
        103.0, 97.0, 105.0, 96.0, 104.0,
        95.0, 106.0, 94.0, 107.0, 93.0,
        108.0, 92.0, 109.0, 91.0, 110.0,
      ];
      final narrow = calculator.calculate(closes, stdDevMultiplier: 1.0);
      final wide = calculator.calculate(closes, stdDevMultiplier: 3.0);

      // At index 19, wide bands should be wider
      double narrowWidth = narrow.upper[19]! - narrow.lower[19]!;
      double wideWidth = wide.upper[19]! - wide.lower[19]!;
      expect(wideWidth, greaterThan(narrowWidth));
      // Width should scale with multiplier: 3x vs 1x
      expect(wideWidth, closeTo(narrowWidth * 3, 0.0001));
    });

    test('all result lists have same length as input', () {
      final closes = List.generate(30, (i) => 100.0 + i.toDouble());
      final result = calculator.calculate(closes);

      expect(result.upper.length, closes.length);
      expect(result.middle.length, closes.length);
      expect(result.lower.length, closes.length);
    });

    test('returns empty lists when insufficient data', () {
      final closes = [1.0, 2.0, 3.0]; // Less than default period=20
      final result = calculator.calculate(closes);

      // SMA calculator returns empty for insufficient data
      expect(result.middle, isEmpty);
    });

    test('bandwidth increases with volatility', () {
      // Low volatility data
      final lowVol = List.generate(25, (i) => 100.0 + (i % 2 == 0 ? 0.1 : -0.1));
      // High volatility data
      final highVol = List.generate(25, (i) => 100.0 + (i % 2 == 0 ? 5.0 : -5.0));

      final lowResult = calculator.calculate(lowVol);
      final highResult = calculator.calculate(highVol);

      double lowBandwidth = lowResult.upper[24]! - lowResult.lower[24]!;
      double highBandwidth = highResult.upper[24]! - highResult.lower[24]!;

      expect(highBandwidth, greaterThan(lowBandwidth));
    });
  });
}

double _sqrt(double value) {
  // Using Newton's method as a simple sqrt for test
  if (value <= 0) return 0;
  double x = value;
  for (int i = 0; i < 50; i++) {
    x = (x + value / x) / 2;
  }
  return x;
}
