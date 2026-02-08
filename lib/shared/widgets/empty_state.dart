import 'package:flutter/material.dart';

/// Reusable empty state widget with icon, message, and optional action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.customAction,
  });

  /// Empty state for no watchlists.
  factory EmptyState.noWatchlists({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.list_alt_outlined,
      title: 'No Watchlists Yet',
      subtitle: 'Create a watchlist to track your favorite stocks',
      actionLabel: 'Create Watchlist',
      onAction: onAdd,
    );
  }

  /// Empty state for no symbols in watchlist.
  factory EmptyState.noSymbols({String? watchlistName}) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: 'No Symbols',
      subtitle: watchlistName != null
          ? '$watchlistName has no symbols yet'
          : 'This watchlist has no symbols',
    );
  }

  /// Empty state for no news.
  factory EmptyState.noNews({String? symbol}) {
    return EmptyState(
      icon: Icons.article_outlined,
      title: 'No Recent News',
      subtitle: symbol != null
          ? 'No recent news for $symbol'
          : 'No news available',
    );
  }

  /// Empty state for no earnings.
  factory EmptyState.noEarnings({String? symbol}) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: 'No Earnings Data',
      subtitle: symbol != null
          ? 'Earnings data not available for $symbol'
          : 'Earnings data not available',
    );
  }

  /// Empty state for select watchlist.
  factory EmptyState.selectWatchlist() {
    return const EmptyState(
      icon: Icons.list_alt_outlined,
      title: 'Select a Watchlist',
      subtitle: 'Choose a watchlist to view symbols',
    );
  }

  /// Empty state for offline mode.
  factory EmptyState.offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off_outlined,
      title: 'You\'re Offline',
      subtitle: 'Check your internet connection and try again',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  /// Empty state for error.
  factory EmptyState.error({String? message, VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Something Went Wrong',
      subtitle: message ?? 'An unexpected error occurred',
      actionLabel: 'Try Again',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: 32),
              customAction!,
            ] else if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add, size: 24),
                  label: Text(
                    actionLabel!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
