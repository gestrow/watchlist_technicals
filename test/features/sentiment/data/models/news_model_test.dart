import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_technicals/features/sentiment/data/models/news_model.dart';

void main() {
  group('NewsModel', () {
    test('creates model with all required fields', () {
      final model = NewsModel(
        headline: 'Apple Reports Record Quarter',
        description: 'Apple Inc. announced record revenue...',
        url: 'https://example.com/news/apple-record',
        publishedAt: DateTime(2024, 1, 15, 10, 30),
        sentimentScore: 0.75,
        source: 'Financial Times',
        imageUrl: 'https://example.com/images/apple.jpg',
      );

      expect(model.headline, 'Apple Reports Record Quarter');
      expect(model.description, 'Apple Inc. announced record revenue...');
      expect(model.url, 'https://example.com/news/apple-record');
      expect(model.publishedAt, DateTime(2024, 1, 15, 10, 30));
      expect(model.sentimentScore, 0.75);
      expect(model.source, 'Financial Times');
      expect(model.imageUrl, 'https://example.com/images/apple.jpg');
    });

    test('allows null imageUrl', () {
      final model = NewsModel(
        headline: 'Test Headline',
        description: 'Test Description',
        url: 'https://example.com',
        publishedAt: DateTime(2024, 1, 1),
        sentimentScore: 0.0,
        source: 'Test Source',
        imageUrl: null,
      );

      expect(model.imageUrl, isNull);
    });

    test('deserializes from MarketAux API JSON format', () {
      // Simulating actual MarketAux API response
      final json = {
        'title': 'Tech Stocks Rally on AI News',
        'description': 'Major tech companies see gains...',
        'url': 'https://marketaux.com/news/tech-rally',
        'published_at': '2024-01-15T14:30:00.000Z',
        'sentiment_score': 0.85,
        'source': 'MarketAux',
        'image_url': 'https://marketaux.com/images/tech.jpg',
      };

      final model = NewsModel.fromJson(json);

      expect(model.headline, 'Tech Stocks Rally on AI News');
      expect(model.description, 'Major tech companies see gains...');
      expect(model.url, 'https://marketaux.com/news/tech-rally');
      expect(model.publishedAt, DateTime.utc(2024, 1, 15, 14, 30));
      expect(model.sentimentScore, 0.85);
      expect(model.source, 'MarketAux');
      expect(model.imageUrl, 'https://marketaux.com/images/tech.jpg');
    });

    test('handles missing optional fields in API response', () {
      final json = {
        'title': 'Breaking News',
        'description': null,
        'url': 'https://example.com',
        'published_at': '2024-01-15T12:00:00.000Z',
        'sentiment_score': null,
        'source': null,
        'image_url': null,
      };

      final model = NewsModel.fromJson(json);

      expect(model.headline, 'Breaking News');
      expect(model.description, ''); // Defaults to empty string
      expect(model.sentimentScore, 0.0); // Defaults to 0.0
      expect(model.source, ''); // Defaults to empty string
      expect(model.imageUrl, isNull);
    });

    test('handles missing title in API response', () {
      final json = {
        'title': null,
        'description': 'Some description',
        'url': 'https://example.com',
        'published_at': '2024-01-15T12:00:00.000Z',
        'sentiment_score': 0.5,
        'source': 'Test',
        'image_url': null,
      };

      final model = NewsModel.fromJson(json);

      expect(model.headline, ''); // Defaults to empty string
    });

    test('handles positive sentiment score', () {
      final json = {
        'title': 'Positive News',
        'description': '',
        'url': 'https://example.com',
        'published_at': '2024-01-15T12:00:00.000Z',
        'sentiment_score': 1.0,
        'source': 'Test',
      };

      final model = NewsModel.fromJson(json);

      expect(model.sentimentScore, 1.0);
    });

    test('handles negative sentiment score', () {
      final json = {
        'title': 'Negative News',
        'description': '',
        'url': 'https://example.com',
        'published_at': '2024-01-15T12:00:00.000Z',
        'sentiment_score': -1.0,
        'source': 'Test',
      };

      final model = NewsModel.fromJson(json);

      expect(model.sentimentScore, -1.0);
    });

    test('handles neutral sentiment score', () {
      final json = {
        'title': 'Neutral News',
        'description': '',
        'url': 'https://example.com',
        'published_at': '2024-01-15T12:00:00.000Z',
        'sentiment_score': 0.0,
        'source': 'Test',
      };

      final model = NewsModel.fromJson(json);

      expect(model.sentimentScore, 0.0);
    });

    test('handles integer sentiment score from API', () {
      final json = {
        'title': 'Test',
        'description': '',
        'url': 'https://example.com',
        'published_at': '2024-01-15T12:00:00.000Z',
        'sentiment_score': 1, // Integer instead of double
        'source': 'Test',
      };

      final model = NewsModel.fromJson(json);

      expect(model.sentimentScore, 1.0);
    });

    test('parses various datetime formats', () {
      final json = {
        'title': 'Test',
        'description': '',
        'url': 'https://example.com',
        'published_at': '2024-06-20T09:15:30.123Z',
        'sentiment_score': 0.5,
        'source': 'Test',
      };

      final model = NewsModel.fromJson(json);

      expect(model.publishedAt.year, 2024);
      expect(model.publishedAt.month, 6);
      expect(model.publishedAt.day, 20);
      expect(model.publishedAt.hour, 9);
      expect(model.publishedAt.minute, 15);
    });

    test('equality works for identical models', () {
      final date = DateTime(2024, 1, 15);

      final model1 = NewsModel(
        headline: 'Test',
        description: 'Desc',
        url: 'https://test.com',
        publishedAt: date,
        sentimentScore: 0.5,
        source: 'Source',
        imageUrl: null,
      );

      final model2 = NewsModel(
        headline: 'Test',
        description: 'Desc',
        url: 'https://test.com',
        publishedAt: date,
        sentimentScore: 0.5,
        source: 'Source',
        imageUrl: null,
      );

      expect(model1, equals(model2));
    });

    test('handles empty strings in API response', () {
      final json = {
        'title': '',
        'description': '',
        'url': '',
        'published_at': '2024-01-15T12:00:00.000Z',
        'sentiment_score': 0.0,
        'source': '',
        'image_url': '',
      };

      final model = NewsModel.fromJson(json);

      expect(model.headline, '');
      expect(model.description, '');
      expect(model.url, '');
      expect(model.source, '');
      expect(model.imageUrl, '');
    });
  });
}
