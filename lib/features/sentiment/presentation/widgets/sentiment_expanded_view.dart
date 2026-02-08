import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/company_profile.dart';
import '../../domain/entities/earnings.dart';
import '../../domain/entities/earnings_calendar_entry.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/stock_quote.dart';
import 'company_description.dart';
import 'earnings_table.dart';
import 'news_item.dart';
import 'peer_list.dart';
import 'sentiment_gauge.dart';

/// Expanded view showing company profile and sentiment data.
class SentimentExpandedView extends StatelessWidget {
  final String symbol;
  final CompanyProfile? profile;
  final StockQuote? quote;
  final List<String>? peers;
  final bool peersExpanded;
  final List<NewsArticle>? news;
  final bool newsExpanded;
  final int? expandedNewsIndex;
  final List<Earnings>? earningsSurprises;
  final List<EarningsCalendarEntry>? earningsCalendar;
  final bool isLoading;
  final String? error;
  final VoidCallback onClose;
  final VoidCallback onTogglePeers;
  final ValueChanged<String> onPeerTap;
  final VoidCallback onToggleNews;
  final ValueChanged<int> onToggleNewsItem;

  const SentimentExpandedView({
    super.key,
    required this.symbol,
    this.profile,
    this.quote,
    this.peers,
    this.peersExpanded = false,
    this.news,
    this.newsExpanded = false,
    this.expandedNewsIndex,
    this.earningsSurprises,
    this.earningsCalendar,
    this.isLoading = false,
    this.error,
    required this.onClose,
    required this.onTogglePeers,
    required this.onPeerTap,
    required this.onToggleNews,
    required this.onToggleNewsItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onClose,
        ),
        title: Text(symbol),
        centerTitle: false,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading company data...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    if (profile == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company profile section
          _buildCompanyProfileSection(context),

          const SizedBox(height: 24),

          // Peers section
          if (peers != null && peers!.isNotEmpty)
            PeerList(
              peers: peers!,
              isExpanded: peersExpanded,
              onToggle: onTogglePeers,
              onPeerTap: onPeerTap,
            ),

          const SizedBox(height: 24),

          // Sentiment Analysis section
          _buildSentimentSection(context),

          const SizedBox(height: 24),

          // Recent News section
          _buildNewsSection(context),

          const SizedBox(height: 24),

          // Earnings section
          EarningsSection(
            earningsSurprises: earningsSurprises,
            earningsCalendar: earningsCalendar,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSentimentSection(BuildContext context) {
    final theme = Theme.of(context);

    if (news == null || news!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sentiment Analysis',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No recent news for $symbol',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate average sentiment
    final sum = news!.fold<double>(0, (acc, n) => acc + n.sentimentScore);
    final avgSentiment = sum / news!.length;

    return SentimentGauge(
      score: avgSentiment,
      articleCount: news!.length,
    );
  }

  Widget _buildNewsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          InkWell(
            onTap: onToggleNews,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent News (Last 7 Days)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (news != null && news!.isNotEmpty)
                    Text(
                      '${news!.length} article${news!.length == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: newsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // News list (animated)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildNewsList(context),
            crossFadeState:
                newsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(BuildContext context) {
    final theme = Theme.of(context);

    if (news == null || news!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text(
          'No recent news available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: news!.asMap().entries.map((entry) {
          final index = entry.key;
          final article = entry.value;
          return NewsItem(
            news: article,
            isExpanded: expandedNewsIndex == index,
            onToggle: () => onToggleNewsItem(index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompanyProfileSection(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Symbol, Quote, Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symbol name (large, bold, all caps)
              Text(
                symbol.toUpperCase(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // Quote price (indented)
              if (quote != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildQuoteDisplay(context),
                ),

              const SizedBox(height: 16),

              // Company description
              if (profile != null)
                CompanyDescription(
                  description: profile!.description,
                  maxLines: 4,
                ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Right column: Company name and logo
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Company name (underlined)
            if (profile != null)
              Container(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  profile!.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 12),

            // Company logo (80x80, rounded corners)
            _buildCompanyLogo(context),
          ],
        ),
      ],
    );
  }

  Widget _buildQuoteDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = quote!.isPositive;
    final changeColor = isPositive
        ? Colors.green.shade600
        : Colors.red.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current price
        Text(
          quote!.formattedPrice,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        // Change
        Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: changeColor,
            ),
            const SizedBox(width: 4),
            Text(
              quote!.formattedFullChange,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: changeColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompanyLogo(BuildContext context) {
    final theme = Theme.of(context);

    if (profile == null || !profile!.hasLogo) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            symbol.isNotEmpty ? symbol[0].toUpperCase() : '?',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: CachedNetworkImage(
          imageUrl: profile!.logo,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: Text(
                symbol.isNotEmpty ? symbol[0].toUpperCase() : '?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
