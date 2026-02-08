import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/sentiment/data/models/quote_model.dart';

void main() {
  group('QuoteModel', () {
    test('creates model with all required fields', () {
      const model = QuoteModel(
        current: 150.25,
        high: 152.00,
        low: 148.50,
        open: 149.00,
        previousClose: 148.75,
        change: 1.50,
        percentChange: 1.01,
      );

      expect(model.current, 150.25);
      expect(model.high, 152.00);
      expect(model.low, 148.50);
      expect(model.open, 149.00);
      expect(model.previousClose, 148.75);
      expect(model.change, 1.50);
      expect(model.percentChange, 1.01);
    });

    test('serializes to JSON with correct Finnhub field names', () {
      const model = QuoteModel(
        current: 150.25,
        high: 152.00,
        low: 148.50,
        open: 149.00,
        previousClose: 148.75,
        change: 1.50,
        percentChange: 1.01,
      );

      final json = model.toJson();

      // Finnhub API uses single-letter keys
      expect(json['c'], 150.25);
      expect(json['h'], 152.00);
      expect(json['l'], 148.50);
      expect(json['o'], 149.00);
      expect(json['pc'], 148.75);
      expect(json['d'], 1.50);
      expect(json['dp'], 1.01);
    });

    test('deserializes from Finnhub API JSON format', () {
      // Simulating actual Finnhub API response
      final json = {
        'c': 150.25,
        'h': 152.00,
        'l': 148.50,
        'o': 149.00,
        'pc': 148.75,
        'd': 1.50,
        'dp': 1.01,
        't': 1705329600, // Extra field from API (timestamp)
      };

      final model = QuoteModel.fromJson(json);

      expect(model.current, 150.25);
      expect(model.high, 152.00);
      expect(model.low, 148.50);
      expect(model.open, 149.00);
      expect(model.previousClose, 148.75);
      expect(model.change, 1.50);
      expect(model.percentChange, 1.01);
    });

    test('round-trips through JSON correctly', () {
      const original = QuoteModel(
        current: 175.50,
        high: 180.00,
        low: 170.00,
        open: 172.25,
        previousClose: 171.00,
        change: 4.50,
        percentChange: 2.63,
      );

      final json = original.toJson();
      final restored = QuoteModel.fromJson(json);

      expect(restored.current, original.current);
      expect(restored.high, original.high);
      expect(restored.low, original.low);
      expect(restored.open, original.open);
      expect(restored.previousClose, original.previousClose);
      expect(restored.change, original.change);
      expect(restored.percentChange, original.percentChange);
    });

    test('handles negative change values', () {
      const model = QuoteModel(
        current: 95.00,
        high: 100.00,
        low: 94.00,
        open: 98.00,
        previousClose: 100.00,
        change: -5.00,
        percentChange: -5.00,
      );

      final json = model.toJson();
      final restored = QuoteModel.fromJson(json);

      expect(restored.change, -5.00);
      expect(restored.percentChange, -5.00);
    });

    test('handles zero change values', () {
      const model = QuoteModel(
        current: 100.00,
        high: 100.00,
        low: 100.00,
        open: 100.00,
        previousClose: 100.00,
        change: 0.0,
        percentChange: 0.0,
      );

      final json = model.toJson();
      final restored = QuoteModel.fromJson(json);

      expect(restored.change, 0.0);
      expect(restored.percentChange, 0.0);
    });

    test('handles decimal precision', () {
      const model = QuoteModel(
        current: 123.456789,
        high: 125.999999,
        low: 122.000001,
        open: 124.123456,
        previousClose: 123.654321,
        change: 0.123456,
        percentChange: 0.098765,
      );

      final json = model.toJson();
      final restored = QuoteModel.fromJson(json);

      expect(restored.current, closeTo(123.456789, 0.000001));
      expect(restored.change, closeTo(0.123456, 0.000001));
    });

    test('handles integer values from API', () {
      // Some API responses may return integers instead of doubles
      final json = {
        'c': 150,
        'h': 152,
        'l': 148,
        'o': 149,
        'pc': 148,
        'd': 2,
        'dp': 1,
      };

      final model = QuoteModel.fromJson(json);

      expect(model.current, 150.0);
      expect(model.high, 152.0);
      expect(model.change, 2.0);
    });

    test('equality works for identical models', () {
      const model1 = QuoteModel(
        current: 150.25,
        high: 152.00,
        low: 148.50,
        open: 149.00,
        previousClose: 148.75,
        change: 1.50,
        percentChange: 1.01,
      );

      const model2 = QuoteModel(
        current: 150.25,
        high: 152.00,
        low: 148.50,
        open: 149.00,
        previousClose: 148.75,
        change: 1.50,
        percentChange: 1.01,
      );

      expect(model1, equals(model2));
    });
  });
}
