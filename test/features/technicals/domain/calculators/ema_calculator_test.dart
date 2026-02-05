import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/technicals/domain/calculators/ema_calculator.dart';

void main() {
  late EmaCalculator calculator;

  setUp(() {
    calculator = EmaCalculator();
  });

  group('EmaCalculator', () {
    test('first EMA equals SMA of first N periods', () {
      final values = [1.0, 2.0, 3.0, 4.0, 5.0];
      final result = calculator.calculate(values, 3);

      // First EMA at index 2 = SMA(3) = (1+2+3)/3 = 2.0
      expect(result[2], closeTo(2.0, 0.0001));
    });

    test('calculates EMA correctly with known values', () {
      // Period 3, multiplier = 2/(3+1) = 0.5
      final values = [1.0, 2.0, 3.0, 4.0, 5.0];
      final result = calculator.calculate(values, 3);

      expect(result.length, 5);
      expect(result[0], isNull);
      expect(result[1], isNull);
      // EMA[2] = SMA = (1+2+3)/3 = 2.0
      expect(result[2], closeTo(2.0, 0.0001));
      // EMA[3] = (4 - 2.0) * 0.5 + 2.0 = 3.0
      expect(result[3], closeTo(3.0, 0.0001));
      // EMA[4] = (5 - 3.0) * 0.5 + 3.0 = 4.0
      expect(result[4], closeTo(4.0, 0.0001));
    });

    test('returns empty list when insufficient data', () {
      final values = [1.0, 2.0];
      final result = calculator.calculate(values, 5);
      expect(result, isEmpty);
    });

    test('handles period equal to data length', () {
      final values = [2.0, 4.0, 6.0];
      final result = calculator.calculate(values, 3);

      expect(result.length, 3);
      expect(result[0], isNull);
      expect(result[1], isNull);
      // Only SMA, no subsequent EMA values
      expect(result[2], closeTo(4.0, 0.0001));
    });

    test('handles all same values', () {
      final values = [5.0, 5.0, 5.0, 5.0, 5.0];
      final result = calculator.calculate(values, 3);

      // When all values are the same, EMA should equal that value
      for (int i = 2; i < result.length; i++) {
        expect(result[i], closeTo(5.0, 0.0001));
      }
    });

    test('handles all zeros', () {
      final values = [0.0, 0.0, 0.0, 0.0];
      final result = calculator.calculate(values, 2);

      for (int i = 1; i < result.length; i++) {
        expect(result[i], closeTo(0.0, 0.0001));
      }
    });

    test('EMA(10) with real-like stock prices', () {
      // Classic Investopedia RSI example close prices (first 11)
      final prices = [
        44.34, 44.09, 44.15, 43.61, 44.33,
        44.83, 45.10, 45.42, 45.84, 46.08,
        45.89,
      ];
      final result = calculator.calculate(prices, 10);

      // EMA[9] = SMA of first 10 = average of prices[0..9]
      final sma10 = prices.sublist(0, 10).reduce((a, b) => a + b) / 10;
      expect(result[9], closeTo(sma10, 0.0001));

      // EMA[10] = (45.89 - sma10) * (2/11) + sma10
      final multiplier = 2.0 / 11;
      final expected = (45.89 - sma10) * multiplier + sma10;
      expect(result[10], closeTo(expected, 0.0001));
    });

    test('EMA reacts faster than SMA to price changes', () {
      // Prices with a sharp jump
      final values = [10.0, 10.0, 10.0, 10.0, 10.0, 20.0];
      final ema = calculator.calculate(values, 5);

      // EMA[4] = SMA = 10.0
      // EMA[5] = (20 - 10) * (2/6) + 10 = 13.333...
      expect(ema[5]!, greaterThan(10.0));
      expect(ema[5]!, closeTo(13.333, 0.01));
    });
  });
}
