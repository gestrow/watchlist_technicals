import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/news_article.dart';

/// A single news item with expandable details.
class NewsItem extends StatelessWidget {
  final NewsArticle news;
  final bool isExpanded;
  final VoidCallback onToggle;

  const NewsItem({
    super.key,
    required this.news,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Collapsed view: headline, source, date, sentiment dot
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sentiment indicator dot
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getSentimentColor(),
                    ),
                  ),
                  // Headline and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isExpanded ? news.headline : news.shortHeadline,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: isExpanded ? null : 2,
                          overflow:
                              isExpanded ? null : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              news.source,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              news.timeAgo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expand/collapse icon
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),

              // Expanded view: description, sentiment score, read more link
              if (isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Description
                if (news.description.isNotEmpty) ...[
                  Text(
                    news.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Sentiment score
                Row(
                  children: [
                    Text(
                      'Sentiment: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getSentimentColor().withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getSentimentLabel(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getSentimentColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${news.sentimentScore.toStringAsFixed(2)})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Read full article button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _launchUrl(news.url),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Read full article'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getSentimentColor() {
    if (news.isPositive) return Colors.green.shade600;
    if (news.isNegative) return Colors.red.shade600;
    return Colors.grey.shade600;
  }

  String _getSentimentLabel() {
    if (news.isPositive) return 'Positive';
    if (news.isNegative) return 'Negative';
    return 'Neutral';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
