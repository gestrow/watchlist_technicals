import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/technicals/data/models/ohlc_model.dart';

void main() {
  group('OhlcModel', () {
    test('creates model with all required fields', () {
      final model = OhlcModel(
        date: DateTime(2024, 1, 15),
        open: 100.0,
        high: 105.0,
        low: 98.0,
        close: 103.0,
        volume: 1000000,
      );

      expect(model.date, DateTime(2024, 1, 15));
      expect(model.open, 100.0);
      expect(model.high, 105.0);
      expect(model.low, 98.0);
      expect(model.close, 103.0);
      expect(model.volume, 1000000);
    });

    test('serializes to JSON correctly', () {
      final model = OhlcModel(
        date: DateTime(2024, 1, 15),
        open: 100.0,
        high: 105.0,
        low: 98.0,
        close: 103.0,
        volume: 1000000,
      );

      final json = model.toJson();

      expect(json['date'], '2024-01-15T00:00:00.000');
      expect(json['open'], 100.0);
      expect(json['high'], 105.0);
      expect(json['low'], 98.0);
      expect(json['close'], 103.0);
      expect(json['volume'], 1000000);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'date': '2024-01-15T00:00:00.000',
        'open': 100.0,
        'high': 105.0,
        'low': 98.0,
        'close': 103.0,
        'volume': 1000000,
      };

      final model = OhlcModel.fromJson(json);

      expect(model.date, DateTime(2024, 1, 15));
      expect(model.open, 100.0);
      expect(model.high, 105.0);
      expect(model.low, 98.0);
      expect(model.close, 103.0);
      expect(model.volume, 1000000);
    });

    test('round-trips through JSON correctly', () {
      final original = OhlcModel(
        date: DateTime(2024, 6, 20, 14, 30),
        open: 150.25,
        high: 155.50,
        low: 149.00,
        close: 154.75,
        volume: 5000000,
      );

      final json = original.toJson();
      final restored = OhlcModel.fromJson(json);

      expect(restored.date, original.date);
      expect(restored.open, original.open);
      expect(restored.high, original.high);
      expect(restored.low, original.low);
      expect(restored.close, original.close);
      expect(restored.volume, original.volume);
    });

    test('handles zero values', () {
      final model = OhlcModel(
        date: DateTime(2024, 1, 1),
        open: 0.0,
        high: 0.0,
        low: 0.0,
        close: 0.0,
        volume: 0,
      );

      final json = model.toJson();
      final restored = OhlcModel.fromJson(json);

      expect(restored.open, 0.0);
      expect(restored.volume, 0);
    });

    test('handles large volume values', () {
      final model = OhlcModel(
        date: DateTime(2024, 1, 1),
        open: 100.0,
        high: 100.0,
        low: 100.0,
        close: 100.0,
        volume: 9999999999,
      );

      final json = model.toJson();
      final restored = OhlcModel.fromJson(json);

      expect(restored.volume, 9999999999);
    });

    test('handles decimal precision', () {
      final model = OhlcModel(
        date: DateTime(2024, 1, 1),
        open: 123.456789,
        high: 125.999999,
        low: 122.000001,
        close: 124.123456,
        volume: 1000,
      );

      final json = model.toJson();
      final restored = OhlcModel.fromJson(json);

      expect(restored.open, closeTo(123.456789, 0.000001));
      expect(restored.high, closeTo(125.999999, 0.000001));
      expect(restored.low, closeTo(122.000001, 0.000001));
      expect(restored.close, closeTo(124.123456, 0.000001));
    });

    test('equality works for identical models', () {
      final model1 = OhlcModel(
        date: DateTime(2024, 1, 15),
        open: 100.0,
        high: 105.0,
        low: 98.0,
        close: 103.0,
        volume: 1000000,
      );

      final model2 = OhlcModel(
        date: DateTime(2024, 1, 15),
        open: 100.0,
        high: 105.0,
        low: 98.0,
        close: 103.0,
        volume: 1000000,
      );

      expect(model1, equals(model2));
    });
  });
}
