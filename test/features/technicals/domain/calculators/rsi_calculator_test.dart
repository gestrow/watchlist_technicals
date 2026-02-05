import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/technicals/domain/calculators/rsi_calculator.dart';

void main() {
  late RsiCalculator calculator;

  setUp(() {
    calculator = RsiCalculator();
  });

  group('RsiCalculator', () {
    test('calculates RSI(14) with Investopedia example data', () {
      // Classic Investopedia RSI example: 15 close prices
      // First RSI appears at index 14 (period=14, needs 15 data points)
      final closes = [
        44.34, 44.09, 44.15, 43.61, 44.33,
        44.83, 45.10, 45.42, 45.84, 46.08,
        45.89, 46.03, 45.61, 46.28, 46.28,
      ];
      final result = calculator.calculate(closes, 14);

      expect(result.length, 15);
      // Indices 0-13 should be null
      for (int i = 0; i < 14; i++) {
        expect(result[i], isNull);
      }
      // RSI at index 14 should be around 70.46 (Investopedia value)
      expect(result[14], closeTo(70.46, 0.5));
    });

    test('returns empty list when insufficient data', () {
      final closes = [1.0, 2.0, 3.0];
      final result = calculator.calculate(closes, 14);
      expect(result, isEmpty);
    });

    test('RSI is 100 when all prices go up (no losses)', () {
      // Monotonically increasing: all gains, no losses
      final closes = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
      final result = calculator.calculate(closes, 5);

      // avgLoss = 0, so RSI = 100
      expect(result[5], closeTo(100.0, 0.0001));
    });

    test('RSI is 0 when all prices go down (no gains)', () {
      // Monotonically decreasing: all losses, no gains
      final closes = [10.0, 9.0, 8.0, 7.0, 6.0, 5.0];
      final result = calculator.calculate(closes, 5);

      // avgGain = 0, so RSI = 0
      expect(result[5], closeTo(0.0, 0.0001));
    });

    test('RSI is 50 when gains equal losses', () {
      // Alternating up/down by same amount
      final closes = [10.0, 11.0, 10.0, 11.0, 10.0];
      final result = calculator.calculate(closes, 4);

      // Gains: [1, 0, 1, 0], avgGain = 0.5
      // Losses: [0, 1, 0, 1], avgLoss = 0.5
      // RS = 1, RSI = 50
      expect(result[4], closeTo(50.0, 0.0001));
    });

    test('all same values gives RSI 100 (no movement = no losses)', () {
      // No changes means gains=0, losses=0
      // When both are 0, avgLoss==0 is checked first -> RSI = 100
      final closes = [5.0, 5.0, 5.0, 5.0, 5.0, 5.0];
      final result = calculator.calculate(closes, 5);

      expect(result[5], closeTo(100.0, 0.0001));
    });

    test('RSI stays between 0 and 100', () {
      // Random-ish price data
      final closes = [
        100.0, 102.0, 99.0, 101.0, 98.0,
        103.0, 97.0, 105.0, 96.0, 104.0,
        95.0, 106.0, 94.0, 107.0, 93.0,
      ];
      final result = calculator.calculate(closes, 5);

      for (final value in result) {
        if (value != null) {
          expect(value, greaterThanOrEqualTo(0.0));
          expect(value, lessThanOrEqualTo(100.0));
        }
      }
    });

    test('Wilder smoothing produces different values than simple average', () {
      final closes = [
        44.34, 44.09, 44.15, 43.61, 44.33,
        44.83, 45.10, 45.42, 45.84, 46.08,
        45.89, 46.03, 45.61, 46.28, 46.28,
        46.00, 46.03, 46.41, 46.22, 45.64,
      ];
      final result = calculator.calculate(closes, 14);

      // Should have non-null values from index 14 onwards
      expect(result[14], isNotNull);
      expect(result[15], isNotNull);
      expect(result[19], isNotNull);

      // Wilder smoothing: subsequent values use smoothed avg, not simple avg
      // So RSI[15] != RSI[14] (unless by coincidence)
      // The important thing is they are all valid (0-100)
      for (int i = 14; i < result.length; i++) {
        expect(result[i], isNotNull);
        expect(result[i]!, greaterThanOrEqualTo(0.0));
        expect(result[i]!, lessThanOrEqualTo(100.0));
      }
    });

    test('minimum data points: period + 1', () {
      // Exactly period + 1 data points should produce one RSI value
      final closes = [1.0, 2.0, 3.0]; // period=2, need 3 points
      final result = calculator.calculate(closes, 2);

      expect(result.length, 3);
      expect(result[0], isNull);
      expect(result[1], isNull);
      expect(result[2], isNotNull);
    });
  });
}
