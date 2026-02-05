import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/technicals/data/models/ohlc_model.dart';
import 'package:watchlist_technicals/features/technicals/domain/calculators/vwap_calculator.dart';

OhlcModel _candle({
  required double high,
  required double low,
  required double close,
  required int volume,
  double open = 0,
}) {
  return OhlcModel(
    date: DateTime(2024, 1, 1),
    open: open,
    high: high,
    low: low,
    close: close,
    volume: volume,
  );
}

void main() {
  late VwapCalculator calculator;

  setUp(() {
    calculator = VwapCalculator();
  });

  group('VwapCalculator - Cumulative', () {
    test('single candle VWAP equals typical price', () {
      final candles = [
        _candle(high: 110.0, low: 90.0, close: 100.0, volume: 1000),
      ];
      final result = calculator.calculate(candles);

      // Typical price = (110 + 90 + 100) / 3 = 100.0
      expect(result[0], closeTo(100.0, 0.0001));
    });

    test('cumulative VWAP with equal volumes equals average of typical prices', () {
      final candles = [
        _candle(high: 12.0, low: 10.0, close: 11.0, volume: 100),
        _candle(high: 15.0, low: 13.0, close: 14.0, volume: 100),
      ];
      final result = calculator.calculate(candles);

      // TP1 = (12+10+11)/3 = 11.0, TP2 = (15+13+14)/3 = 14.0
      // VWAP[0] = 11.0 * 100 / 100 = 11.0
      expect(result[0], closeTo(11.0, 0.0001));
      // VWAP[1] = (11.0*100 + 14.0*100) / 200 = 12.5
      expect(result[1], closeTo(12.5, 0.0001));
    });

    test('cumulative VWAP weights by volume', () {
      final candles = [
        _candle(high: 10.0, low: 10.0, close: 10.0, volume: 100), // TP = 10
        _candle(high: 20.0, low: 20.0, close: 20.0, volume: 300), // TP = 20
      ];
      final result = calculator.calculate(candles);

      // VWAP[0] = 10.0
      expect(result[0], closeTo(10.0, 0.0001));
      // VWAP[1] = (10*100 + 20*300) / 400 = 7000/400 = 17.5
      expect(result[1], closeTo(17.5, 0.0001));
    });

    test('cumulative VWAP all values are non-null', () {
      final candles = [
        _candle(high: 10.0, low: 9.0, close: 9.5, volume: 500),
        _candle(high: 11.0, low: 10.0, close: 10.5, volume: 600),
        _candle(high: 12.0, low: 11.0, close: 11.5, volume: 700),
        _candle(high: 13.0, low: 12.0, close: 12.5, volume: 800),
      ];
      final result = calculator.calculate(candles);

      expect(result.length, 4);
      for (final v in result) {
        expect(v, isNotNull);
      }
    });

    test('zero volume candle produces null', () {
      final candles = [
        _candle(high: 10.0, low: 10.0, close: 10.0, volume: 0),
      ];
      final result = calculator.calculate(candles);

      expect(result[0], isNull);
    });

    test('cumulative VWAP with known hand-calculated values', () {
      final candles = [
        _candle(high: 30.0, low: 27.0, close: 28.0, volume: 1000),
        _candle(high: 29.0, low: 26.0, close: 27.0, volume: 2000),
        _candle(high: 31.0, low: 28.0, close: 30.0, volume: 1500),
      ];
      final result = calculator.calculate(candles);

      // TP1 = (30+27+28)/3 = 28.333...
      // TP2 = (29+26+27)/3 = 27.333...
      // TP3 = (31+28+30)/3 = 29.666...
      double tp1 = (30 + 27 + 28) / 3;
      double tp2 = (29 + 26 + 27) / 3;
      double tp3 = (31 + 28 + 30) / 3;

      // VWAP[0] = tp1
      expect(result[0], closeTo(tp1, 0.0001));
      // VWAP[1] = (tp1*1000 + tp2*2000) / 3000
      double vwap1 = (tp1 * 1000 + tp2 * 2000) / 3000;
      expect(result[1], closeTo(vwap1, 0.0001));
      // VWAP[2] = (tp1*1000 + tp2*2000 + tp3*1500) / 4500
      double vwap2 = (tp1 * 1000 + tp2 * 2000 + tp3 * 1500) / 4500;
      expect(result[2], closeTo(vwap2, 0.0001));
    });
  });

  group('VwapCalculator - Rolling', () {
    test('rolling VWAP with period=1 equals typical price', () {
      final candles = [
        _candle(high: 10.0, low: 8.0, close: 9.0, volume: 100),
        _candle(high: 12.0, low: 10.0, close: 11.0, volume: 200),
      ];
      final result = calculator.calculate(candles, rollingPeriod: 1);

      expect(result[0], closeTo(9.0, 0.0001)); // (10+8+9)/3
      expect(result[1], closeTo(11.0, 0.0001)); // (12+10+11)/3
    });

    test('rolling VWAP nulls before period', () {
      final candles = [
        _candle(high: 10.0, low: 8.0, close: 9.0, volume: 100),
        _candle(high: 12.0, low: 10.0, close: 11.0, volume: 200),
        _candle(high: 14.0, low: 12.0, close: 13.0, volume: 300),
      ];
      final result = calculator.calculate(candles, rollingPeriod: 2);

      expect(result[0], isNull);
      expect(result[1], isNotNull);
      expect(result[2], isNotNull);
    });

    test('rolling VWAP with period=2', () {
      final candles = [
        _candle(high: 10.0, low: 10.0, close: 10.0, volume: 100), // TP=10
        _candle(high: 20.0, low: 20.0, close: 20.0, volume: 100), // TP=20
        _candle(high: 30.0, low: 30.0, close: 30.0, volume: 100), // TP=30
      ];
      final result = calculator.calculate(candles, rollingPeriod: 2);

      // VWAP[1] = (10*100 + 20*100) / 200 = 15.0
      expect(result[1], closeTo(15.0, 0.0001));
      // VWAP[2] = (20*100 + 30*100) / 200 = 25.0
      expect(result[2], closeTo(25.0, 0.0001));
    });

    test('rolling VWAP weights by volume within window', () {
      final candles = [
        _candle(high: 10.0, low: 10.0, close: 10.0, volume: 100), // TP=10
        _candle(high: 20.0, low: 20.0, close: 20.0, volume: 900), // TP=20
        _candle(high: 30.0, low: 30.0, close: 30.0, volume: 100), // TP=30
      ];
      final result = calculator.calculate(candles, rollingPeriod: 2);

      // VWAP[1] = (10*100 + 20*900) / 1000 = 19.0
      expect(result[1], closeTo(19.0, 0.0001));
      // VWAP[2] = (20*900 + 30*100) / 1000 = 21.0
      expect(result[2], closeTo(21.0, 0.0001));
    });
  });

  group('VwapCalculator - Edge Cases', () {
    test('empty candle list returns empty', () {
      final result = calculator.calculate([]);
      expect(result, isEmpty);
    });

    test('result length matches input length', () {
      final candles = List.generate(10, (i) =>
        _candle(high: 100.0 + i, low: 98.0 + i, close: 99.0 + i, volume: 1000),
      );
      final cumResult = calculator.calculate(candles);
      final rollResult = calculator.calculate(candles, rollingPeriod: 3);

      expect(cumResult.length, 10);
      expect(rollResult.length, 10);
    });
  });
}
