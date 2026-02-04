import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_model.freezed.dart';

/// Model for news articles from MarketAux API
/// Maps MarketAux response to app model
/// Custom fromJson to handle MarketAux field name mapping
@freezed
class NewsModel with _$NewsModel {
  const factory NewsModel({
    required String headline,
    required String description,
    required String url,
    required DateTime publishedAt,
    required double sentimentScore, // -1 to +1 from MarketAux
    required String source,
    String? imageUrl,
  }) = _NewsModel;

  /// Custom fromJson that maps MarketAux API fields:
  /// - title -> headline
  /// - published_at -> publishedAt
  /// - sentiment_score -> sentimentScore
  /// - image_url -> imageUrl
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      headline: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      publishedAt: DateTime.parse(json['published_at'] as String),
      sentimentScore: (json['sentiment_score'] as num?)?.toDouble() ?? 0.0,
      source: json['source'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
    );
  }
}
