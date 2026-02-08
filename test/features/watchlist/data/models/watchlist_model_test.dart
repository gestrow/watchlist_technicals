import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/watchlist/data/models/watchlist_model.dart';
import 'package:watchlist_technicals/features/watchlist/domain/entities/watchlist.dart';

void main() {
  group('WatchlistModel', () {
    test('creates model with all required fields', () {
      const model = WatchlistModel(
        id: 'test-id-123',
        name: 'Tech Stocks',
        symbols: ['AAPL', 'GOOGL', 'MSFT'],
      );

      expect(model.id, 'test-id-123');
      expect(model.name, 'Tech Stocks');
      expect(model.symbols, ['AAPL', 'GOOGL', 'MSFT']);
    });

    test('serializes to JSON correctly', () {
      const model = WatchlistModel(
        id: 'test-id-123',
        name: 'Tech Stocks',
        symbols: ['AAPL', 'GOOGL', 'MSFT'],
      );

      final json = model.toJson();

      expect(json['id'], 'test-id-123');
      expect(json['name'], 'Tech Stocks');
      expect(json['symbols'], ['AAPL', 'GOOGL', 'MSFT']);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'test-id-123',
        'name': 'Tech Stocks',
        'symbols': ['AAPL', 'GOOGL', 'MSFT'],
      };

      final model = WatchlistModel.fromJson(json);

      expect(model.id, 'test-id-123');
      expect(model.name, 'Tech Stocks');
      expect(model.symbols, ['AAPL', 'GOOGL', 'MSFT']);
    });

    test('round-trips through JSON correctly', () {
      const original = WatchlistModel(
        id: 'uuid-abc-123',
        name: 'My Watchlist',
        symbols: ['NVDA', 'AMD', 'INTC', 'TSM'],
      );

      final json = original.toJson();
      final restored = WatchlistModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.symbols, original.symbols);
    });

    test('handles empty symbols list', () {
      const model = WatchlistModel(
        id: 'empty-list',
        name: 'Empty Watchlist',
        symbols: [],
      );

      final json = model.toJson();
      final restored = WatchlistModel.fromJson(json);

      expect(restored.symbols, isEmpty);
    });

    test('handles special characters in name', () {
      const model = WatchlistModel(
        id: 'special-chars',
        name: 'Tech & Finance (2024)',
        symbols: ['AAPL'],
      );

      final json = model.toJson();
      final restored = WatchlistModel.fromJson(json);

      expect(restored.name, 'Tech & Finance (2024)');
    });

    test('converts to entity correctly', () {
      const model = WatchlistModel(
        id: 'entity-test',
        name: 'Entity Test',
        symbols: ['AAPL', 'GOOGL'],
      );

      final entity = model.toEntity();

      expect(entity, isA<Watchlist>());
      expect(entity.id, 'entity-test');
      expect(entity.name, 'Entity Test');
      expect(entity.symbols, ['AAPL', 'GOOGL']);
    });

    test('converts from entity correctly', () {
      final entity = Watchlist(
        id: 'from-entity',
        name: 'From Entity',
        symbols: ['TSLA', 'META'],
      );

      final model = WatchlistModel.fromEntity(entity);

      expect(model.id, 'from-entity');
      expect(model.name, 'From Entity');
      expect(model.symbols, ['TSLA', 'META']);
    });

    test('entity round-trip preserves data', () {
      const original = WatchlistModel(
        id: 'round-trip',
        name: 'Round Trip Test',
        symbols: ['SPY', 'QQQ', 'DIA'],
      );

      final entity = original.toEntity();
      final restored = WatchlistModel.fromEntity(entity);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.symbols, original.symbols);
    });

    test('equality works for identical models', () {
      const model1 = WatchlistModel(
        id: 'test-id',
        name: 'Test',
        symbols: ['AAPL'],
      );

      const model2 = WatchlistModel(
        id: 'test-id',
        name: 'Test',
        symbols: ['AAPL'],
      );

      expect(model1, equals(model2));
    });

    test('symbols parsing: handles uppercase conversion', () {
      // Simulating what would happen if symbols came in lowercase
      final json = {
        'id': 'test',
        'name': 'Test',
        'symbols': ['aapl', 'googl', 'msft'],
      };

      final model = WatchlistModel.fromJson(json);
      // Note: The model doesn't auto-uppercase, that's done at input validation
      expect(model.symbols, ['aapl', 'googl', 'msft']);
    });
  });
}
