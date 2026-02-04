import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/datasources/marketaux_api.dart';
import '../../data/models/news_model.dart';

/// Test page to verify MarketAux API integration
/// Fetches news for AAPL from the last 7 days
class MarketAuxTestPage extends StatefulWidget {
  const MarketAuxTestPage({super.key});

  @override
  State<MarketAuxTestPage> createState() => _MarketAuxTestPageState();
}

class _MarketAuxTestPageState extends State<MarketAuxTestPage> {
  final MarketAuxApi _api = sl<MarketAuxApi>();
  List<NewsModel>? _news;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final news = await _api.getRecentNews('AAPL', days: 7, limit: 20);

      // Print to console for verification
      print('\n=== MarketAux API Test Results ===');
      print('Fetched ${news.length} articles for AAPL (last 7 days)');
      print('=====================================\n');

      for (var i = 0; i < news.length; i++) {
        final article = news[i];
        print('Article ${i + 1}:');
        print('  Headline: ${article.headline}');
        print('  Sentiment: ${article.sentimentScore.toStringAsFixed(2)} '
            '(${_getSentimentLabel(article.sentimentScore)})');
        print('  Source: ${article.source}');
        print('  Published: ${article.publishedAt}');
        print('  URL: ${article.url}');
        print('---');
      }

      if (news.isNotEmpty) {
        final avgSentiment = news
            .map((e) => e.sentimentScore)
            .reduce((a, b) => a + b) / news.length;
        print('\nAverage Sentiment: ${avgSentiment.toStringAsFixed(2)} '
            '(${_getSentimentLabel(avgSentiment)})');
      }

      print('\n=== Test Complete ===\n');

      setState(() {
        _news = news;
        _isLoading = false;
      });
    } catch (e) {
      print('\n=== MarketAux API Error ===');
      print('Error: $e');
      print('=========================\n');

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getSentimentLabel(double score) {
    if (score > 0.3) return 'Positive';
    if (score < -0.3) return 'Negative';
    return 'Neutral';
  }

  Color _getSentimentColor(double score) {
    if (score > 0.3) return Colors.green;
    if (score < -0.3) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MarketAux API Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchNews,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching news from MarketAux...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error fetching news',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchNews,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_news == null || _news!.isEmpty) {
      return const Center(
        child: Text('No news found'),
      );
    }

    final avgSentiment = _news!
        .map((e) => e.sentimentScore)
        .reduce((a, b) => a + b) / _news!.length;

    return Column(
      children: [
        // Summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Column(
            children: [
              const Text(
                'AAPL - Last 7 Days',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${_news!.length} articles',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Avg Sentiment: ', style: TextStyle(fontSize: 16)),
                  Text(
                    avgSentiment.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getSentimentColor(avgSentiment),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${_getSentimentLabel(avgSentiment)})',
                    style: TextStyle(
                      color: _getSentimentColor(avgSentiment),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // News list
        Expanded(
          child: ListView.builder(
            itemCount: _news!.length,
            itemBuilder: (context, index) {
              final article = _news![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSentimentColor(article.sentimentScore)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.sentimentScore.toStringAsFixed(2),
                      style: TextStyle(
                        color: _getSentimentColor(article.sentimentScore),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    article.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        article.source,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(article.publishedAt),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      _getSentimentLabel(article.sentimentScore),
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: _getSentimentColor(article.sentimentScore)
                        .withOpacity(0.2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

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
}
