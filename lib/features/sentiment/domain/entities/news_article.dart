import 'package:intl/intl.dart';

import '../../data/models/news_model.dart';

/// Domain entity representing a news article with sentiment.
class NewsArticle {
  final String headline;
  final String description;
  final String url;
  final DateTime publishedAt;
  final double sentimentScore;
  final String source;
  final String? imageUrl;

  const NewsArticle({
    required this.headline,
    required this.description,
    required this.url,
    required this.publishedAt,
    required this.sentimentScore,
    required this.source,
    this.imageUrl,
  });

  /// Creates a [NewsArticle] from a [NewsModel].
  factory NewsArticle.fromModel(NewsModel model) {
    return NewsArticle(
      headline: model.headline,
      description: model.description,
      url: model.url,
      publishedAt: model.publishedAt,
      sentimentScore: model.sentimentScore,
      source: model.source,
      imageUrl: model.imageUrl,
    );
  }

  /// Returns true if sentiment is positive (> 0.2).
  bool get isPositive => sentimentScore > 0.2;

  /// Returns true if sentiment is negative (< -0.2).
  bool get isNegative => sentimentScore < -0.2;

  /// Returns true if sentiment is neutral (-0.2 to 0.2).
  bool get isNeutral => !isPositive && !isNegative;

  /// Formatted date string (e.g., "Feb 8, 2026").
  String get formattedDate => DateFormat('MMM d, yyyy').format(publishedAt);

  /// Formatted time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(publishedAt);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Truncated headline for display.
  String get shortHeadline {
    if (headline.length <= 80) return headline;
    return '${headline.substring(0, 77)}...';
  }

  /// Returns true if this article has a valid image.
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}
