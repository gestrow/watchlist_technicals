import 'package:flutter/material.dart';

/// A visual gauge showing sentiment score with color coding.
class SentimentGauge extends StatelessWidget {
  final double score;
  final int articleCount;

  const SentimentGauge({
    super.key,
    required this.score,
    required this.articleCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Sentiment Analysis',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Sentiment score row
            Row(
              children: [
                Text(
                  'MarketAux Sentiment:',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                // Colored indicator with score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getSentimentColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    score.toStringAsFixed(2),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Visual gauge bar
            _buildGaugeBar(theme),

            const SizedBox(height: 8),

            // Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Negative',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade600,
                  ),
                ),
                Text(
                  'Neutral',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Positive',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Article count
            Text(
              'Based on $articleCount article${articleCount == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            // Sentiment description
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getSentimentIcon(),
                  size: 18,
                  color: _getSentimentColor(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getSentimentDescription(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeBar(ThemeData theme) {
    // Score ranges from -1 to +1, we need to map to 0 to 1 for the gauge
    final normalizedScore = (score + 1) / 2;
    final clampedScore = normalizedScore.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final indicatorPosition =
            (constraints.maxWidth - 4) * clampedScore;

        return Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                Colors.red.shade400,
                Colors.red.shade200,
                Colors.grey.shade300,
                Colors.green.shade200,
                Colors.green.shade400,
              ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Indicator
              Positioned(
                left: indicatorPosition,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getSentimentColor() {
    if (score > 0.2) return Colors.green.shade600;
    if (score < -0.2) return Colors.red.shade600;
    return Colors.grey.shade600;
  }

  IconData _getSentimentIcon() {
    if (score > 0.2) return Icons.trending_up;
    if (score < -0.2) return Icons.trending_down;
    return Icons.trending_flat;
  }

  String _getSentimentDescription() {
    if (score > 0.5) return 'Very positive sentiment in recent news';
    if (score > 0.2) return 'Positive sentiment in recent news';
    if (score < -0.5) return 'Very negative sentiment in recent news';
    if (score < -0.2) return 'Negative sentiment in recent news';
    return 'Neutral sentiment in recent news';
  }
}
