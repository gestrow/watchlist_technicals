import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/technicals/domain/calculators/sma_calculator.dart';

void main() {
  late SmaCalculator calculator;

  setUp(() {
    calculator = SmaCalculator();
  });

  group('SmaCalculator', () {
    test('calculates SMA correctly for known values', () {
      // 10 data points, period 3
      final values = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
      final result = calculator.calculate(values, 3);

      expect(result.length, 10);
      // First 2 should be null (not enough data)
      expect(result[0], isNull);
      expect(result[1], isNull);
      // SMA(3) at index 2: (1+2+3)/3 = 2.0
      expect(result[2], closeTo(2.0, 0.0001));
      // SMA(3) at index 3: (2+3+4)/3 = 3.0
      expect(result[3], closeTo(3.0, 0.0001));
      // SMA(3) at index 9: (8+9+10)/3 = 9.0
      expect(result[9], closeTo(9.0, 0.0001));
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
      expect(result[2], closeTo(4.0, 0.0001)); // (2+4+6)/3
    });

    test('handles all same values', () {
      final values = [5.0, 5.0, 5.0, 5.0, 5.0];
      final result = calculator.calculate(values, 3);

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

    test('calculates SMA(5) with real-like prices', () {
      final prices = [44.34, 44.09, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84];
      final result = calculator.calculate(prices, 5);

      expect(result.length, 8);
      // SMA(5) at index 4: (44.34+44.09+43.61+44.33+44.83)/5 = 44.24
      expect(result[4], closeTo(44.24, 0.01));
      // SMA(5) at index 5: (44.09+43.61+44.33+44.83+45.10)/5 = 44.392
      expect(result[5], closeTo(44.392, 0.01));
    });

    test('period of 1 returns original values', () {
      final values = [3.0, 7.0, 2.0, 9.0];
      final result = calculator.calculate(values, 1);

      expect(result.length, 4);
      expect(result[0], closeTo(3.0, 0.0001));
      expect(result[1], closeTo(7.0, 0.0001));
      expect(result[2], closeTo(2.0, 0.0001));
      expect(result[3], closeTo(9.0, 0.0001));
    });
  });
}
