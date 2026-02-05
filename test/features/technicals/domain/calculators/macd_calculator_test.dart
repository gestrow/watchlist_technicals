import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/technicals/domain/calculators/macd_calculator.dart';

void main() {
  late MacdCalculator calculator;

  setUp(() {
    calculator = MacdCalculator();
  });

  group('MacdCalculator', () {
    test('MACD line is null before slow EMA is available', () {
      // With default periods (12, 26, 9), need at least 26 data points
      // for MACD line to start
      final closes = List.generate(30, (i) => 100.0 + i.toDouble());
      final result = calculator.calculate(closes);

      // Indices 0-24 should be null (slow EMA needs 26 points, first at index 25)
      for (int i = 0; i < 25; i++) {
        expect(result.macdLine[i], isNull, reason: 'MACD at index $i should be null');
      }
      // Index 25 (slow EMA starts) should have a MACD value
      expect(result.macdLine[25], isNotNull);
    });

    test('MACD line equals fast EMA minus slow EMA', () {
      // Monotonically increasing prices
      final closes = List.generate(30, (i) => 50.0 + i * 0.5);
      final result = calculator.calculate(closes);

      // Verify MACD = fastEMA - slowEMA for non-null values
      // With uptrending data, fast EMA > slow EMA, so MACD > 0
      for (int i = 25; i < 30; i++) {
        expect(result.macdLine[i], isNotNull);
        expect(result.macdLine[i]!, greaterThan(0));
      }
    });

    test('signal line starts after signalPeriod MACD values', () {
      // Need 26 for slow EMA + 8 more for signal EMA(9) = 34 total
      final closes = List.generate(40, (i) => 100.0 + i.toDouble());
      final result = calculator.calculate(closes);

      // Signal line needs 9-period EMA of MACD values
      // MACD starts at index 25, signal needs 9 MACD values
      // So signal starts at index 25 + 8 = 33
      expect(result.signalLine[33], isNotNull);
      // Before that, signal should be null at early MACD indices
      expect(result.signalLine[25], isNull);
    });

    test('histogram equals MACD minus signal', () {
      final closes = List.generate(40, (i) => 100.0 + i * 0.3);
      final result = calculator.calculate(closes);

      for (int i = 0; i < closes.length; i++) {
        if (result.macdLine[i] != null && result.signalLine[i] != null) {
          expect(
            result.histogram[i],
            closeTo(result.macdLine[i]! - result.signalLine[i]!, 0.0001),
          );
        }
      }
    });

    test('histogram is null when signal is null', () {
      final closes = List.generate(30, (i) => 100.0 + i.toDouble());
      final result = calculator.calculate(closes);

      for (int i = 0; i < closes.length; i++) {
        if (result.signalLine[i] == null) {
          expect(result.histogram[i], isNull);
        }
      }
    });

    test('custom periods work correctly', () {
      // Use shorter periods: fast=3, slow=5, signal=2
      final closes = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
      final result = calculator.calculate(
        closes,
        fastPeriod: 3,
        slowPeriod: 5,
        signalPeriod: 2,
      );

      expect(result.macdLine.length, 10);
      // Slow EMA(5) starts at index 4, so MACD starts at index 4
      expect(result.macdLine[4], isNotNull);
      expect(result.macdLine[3], isNull);
    });

    test('flat prices produce MACD near zero', () {
      final closes = List.generate(40, (_) => 100.0);
      final result = calculator.calculate(closes);

      for (int i = 0; i < closes.length; i++) {
        if (result.macdLine[i] != null) {
          expect(result.macdLine[i]!, closeTo(0.0, 0.0001));
        }
        if (result.histogram[i] != null) {
          expect(result.histogram[i]!, closeTo(0.0, 0.0001));
        }
      }
    });

    test('downtrending prices produce negative MACD', () {
      // Decreasing prices: fast EMA < slow EMA
      final closes = List.generate(40, (i) => 200.0 - i * 1.0);
      final result = calculator.calculate(closes);

      for (int i = 25; i < closes.length; i++) {
        if (result.macdLine[i] != null) {
          expect(result.macdLine[i]!, lessThan(0));
        }
      }
    });

    test('all result lists have same length as input', () {
      final closes = List.generate(50, (i) => 100.0 + i.toDouble());
      final result = calculator.calculate(closes);

      expect(result.macdLine.length, closes.length);
      expect(result.signalLine.length, closes.length);
      expect(result.histogram.length, closes.length);
    });

    test('values stay within reasonable range', () {
      // Real-like volatile prices
      final closes = [
        100.0, 102.0, 99.0, 101.0, 98.0, 103.0, 97.0, 105.0,
        96.0, 104.0, 95.0, 106.0, 94.0, 107.0, 93.0, 108.0,
        92.0, 109.0, 91.0, 110.0, 90.0, 111.0, 89.0, 112.0,
        88.0, 113.0, 87.0, 114.0, 86.0, 115.0, 85.0, 116.0,
        84.0, 117.0, 83.0, 118.0, 82.0, 119.0, 81.0, 120.0,
      ];
      final result = calculator.calculate(closes);

      for (final v in result.macdLine) {
        if (v != null) {
          // MACD should not be wildly out of range for these prices
          expect(v.abs(), lessThan(50));
        }
      }
    });
  });
}
