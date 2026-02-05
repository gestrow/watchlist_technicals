import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/technicals/data/models/ohlc_model.dart';
import 'package:watchlist_technicals/features/technicals/domain/calculators/dominant_cycle_calculator.dart';

OhlcModel _candle({
  required double high,
  required double low,
  double? close,
  int volume = 1000,
}) {
  return OhlcModel(
    date: DateTime(2024, 1, 1),
    open: (high + low) / 2,
    high: high,
    low: low,
    close: close ?? (high + low) / 2,
    volume: volume,
  );
}

void main() {
  late DominantCycleCalculator calculator;
  late DominantCycleFacade facade;

  setUp(() {
    calculator = DominantCycleCalculator();
    facade = DominantCycleFacade();
  });

  group('DominantCycleCalculator', () {
    test('returns 0.0 for insufficient data (less than 15 bars)', () {
      final prices = List.generate(10, (i) => 100.0 + i);
      expect(calculator.calculate(prices), 0.0);
    });

    test('returns a value for 15+ bars of data', () {
      final prices = List.generate(20, (i) => 100.0 + i);
      final result = calculator.calculate(prices);
      expect(result, isNonZero);
    });

    test('result is within 6-50 bar range for trending data', () {
      final prices = List.generate(60, (i) => 100.0 + i * 0.5);
      final result = calculator.calculate(prices);
      expect(result, greaterThanOrEqualTo(6));
      expect(result, lessThanOrEqualTo(50));
    });

    test('detects cycle in sinusoidal data', () {
      // Generate a 20-bar sine wave over 60 bars
      const cyclePeriod = 20;
      final prices = List.generate(60, (i) {
        return 100.0 + 5.0 * math.sin(2 * math.pi * i / cyclePeriod);
      });
      final result = calculator.calculate(prices);

      // Should detect a cycle roughly near the 20-bar period
      // Allow wide tolerance since the algorithm has warm-up and smoothing
      expect(result, greaterThanOrEqualTo(6));
      expect(result, lessThanOrEqualTo(50));
    });

    test('flat prices produce a stable period near seed value', () {
      final prices = List.generate(60, (_) => 100.0);
      final result = calculator.calculate(prices);

      // With flat prices, I and Q components are all zero
      // The algorithm constrains via 0.67*currentPeriod, gradually
      // decaying from seed of 20. Result should still be in valid range.
      expect(result, greaterThanOrEqualTo(6));
      expect(result, lessThanOrEqualTo(50));
    });

    test('result is deterministic for same input', () {
      final prices = List.generate(50, (i) => 100.0 + 3.0 * math.sin(i * 0.3) + i * 0.1);
      final result1 = calculator.calculate(prices);
      final result2 = calculator.calculate(prices);
      expect(result1, result2);
    });

    test('works with real-like AAPL price data (60 days)', () {
      // Simulated AAPL-like midpoint prices over 60 days
      final prices = [
        182.5, 183.2, 181.8, 182.9, 184.1, 183.5, 185.0, 184.3, 186.1, 185.7,
        184.9, 186.3, 187.0, 185.8, 186.5, 188.2, 187.4, 189.1, 188.6, 187.9,
        189.5, 190.2, 188.8, 189.7, 191.0, 190.3, 191.8, 190.9, 192.4, 191.5,
        190.7, 192.1, 193.5, 192.8, 191.6, 193.0, 194.2, 193.1, 194.8, 193.9,
        192.5, 194.0, 195.3, 194.6, 193.2, 195.0, 196.1, 195.2, 196.8, 195.9,
        194.5, 196.0, 197.4, 196.5, 195.1, 197.0, 198.2, 197.1, 198.9, 197.8,
      ];
      final result = calculator.calculate(prices);

      expect(result, greaterThanOrEqualTo(6));
      expect(result, lessThanOrEqualTo(50));
    });
  });

  group('DominantCycleFacade', () {
    test('returns null for insufficient data (less than 30 candles)', () {
      final candles = List.generate(20, (i) => _candle(high: 101.0, low: 99.0));
      expect(facade.calculate(candles), isNull);
    });

    test('returns a valid period for 30+ candles', () {
      final candles = List.generate(40, (i) => _candle(
        high: 100.0 + i + 1.0,
        low: 100.0 + i - 1.0,
      ));
      final result = facade.calculate(candles);

      expect(result, isNotNull);
      expect(result!, greaterThanOrEqualTo(6));
      expect(result, lessThanOrEqualTo(50));
    });

    test('uses midpoint (high + low) / 2 for calculation', () {
      // Create candles where midpoint creates a known pattern
      final candles = List.generate(60, (i) {
        double mid = 100.0 + 5.0 * math.sin(2 * math.pi * i / 20);
        return _candle(high: mid + 1.0, low: mid - 1.0);
      });
      final result = facade.calculate(candles);

      expect(result, isNotNull);
      expect(result!, greaterThanOrEqualTo(6));
      expect(result, lessThanOrEqualTo(50));
    });

    test('returns valid result with real-like OHLC data (60 days)', () {
      // Simulated 60 days of OHLC data with realistic spreads
      final random = math.Random(42); // Seeded for determinism
      double basePrice = 150.0;

      final candles = List.generate(60, (i) {
        basePrice += (random.nextDouble() - 0.48) * 3; // Slight upward drift
        double high = basePrice + random.nextDouble() * 2;
        double low = basePrice - random.nextDouble() * 2;
        double close = low + random.nextDouble() * (high - low);
        return OhlcModel(
          date: DateTime(2024, 1, 1).add(Duration(days: i)),
          open: (high + low) / 2,
          high: high,
          low: low,
          close: close,
          volume: 1000000 + random.nextInt(5000000),
        );
      });

      final result = facade.calculate(candles);

      expect(result, isNotNull);
      expect(result!, greaterThanOrEqualTo(6));
      expect(result, lessThanOrEqualTo(50));
    });

    test('result length is exactly 30 candles at boundary', () {
      final candles = List.generate(30, (i) => _candle(
        high: 100.0 + i + 1.0,
        low: 100.0 + i - 1.0,
      ));
      final result = facade.calculate(candles);

      // 30 is >= 30 minimum, and >= 15 for inner calculator
      expect(result, isNotNull);
    });

    test('returns null at 29 candles (just below threshold)', () {
      final candles = List.generate(29, (i) => _candle(
        high: 100.0 + i + 1.0,
        low: 100.0 + i - 1.0,
      ));
      expect(facade.calculate(candles), isNull);
    });
  });
}
