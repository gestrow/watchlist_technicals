import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../watchlist/domain/entities/watchlist.dart';
import '../../../watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../domain/repositories/sentiment_repository.dart';
import '../bloc/sentiment_bloc.dart';
import '../widgets/sentiment_expanded_view.dart';

/// Main page for sentiment analysis.
class SentimentPage extends StatelessWidget {
  const SentimentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Try to get the repository from DI
    SentimentRepository? repository;
    try {
      repository = sl<SentimentRepository>();
    } catch (_) {
      // Repository not registered, will work without API calls
    }

    return BlocProvider(
      create: (_) => SentimentBloc(repository: repository),
      child: const _SentimentPageContent(),
    );
  }
}

class _SentimentPageContent extends StatefulWidget {
  const _SentimentPageContent();

  @override
  State<_SentimentPageContent> createState() => _SentimentPageContentState();
}

class _SentimentPageContentState extends State<_SentimentPageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWatchlists();
    });
  }

  void _syncWatchlists() {
    final watchlistState = context.read<WatchlistBloc>().state;
    if (watchlistState is WatchlistLoaded) {
      context.read<SentimentBloc>().add(
            UpdateAvailableWatchlists(watchlistState.watchlists),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchlistBloc, WatchlistState>(
      listener: (context, state) {
        if (state is WatchlistLoaded) {
          context.read<SentimentBloc>().add(
                UpdateAvailableWatchlists(state.watchlists),
              );
        }
      },
      child: BlocBuilder<SentimentBloc, SentimentState>(
        builder: (context, state) {
          // Show expanded view if a symbol is selected
          if (state.isExpanded) {
            return SentimentExpandedView(
              symbol: state.selectedSymbol!,
              profile: state.profile,
              quote: state.quote,
              peers: state.peers,
              peersExpanded: state.peersExpanded,
              news: state.news,
              newsExpanded: state.newsExpanded,
              expandedNewsIndex: state.expandedNewsIndex,
              earningsSurprises: state.earningsSurprises,
              earningsCalendar: state.earningsCalendar,
              isLoading: state.isLoading,
              error: state.error,
              onClose: () {
                context.read<SentimentBloc>().add(const CollapseSentiment());
              },
              onTogglePeers: () {
                context.read<SentimentBloc>().add(const TogglePeers());
              },
              onPeerTap: (peer) {
                context.read<SentimentBloc>().add(SelectPeer(peer));
              },
              onToggleNews: () {
                context.read<SentimentBloc>().add(const ToggleNews());
              },
              onToggleNewsItem: (index) {
                context.read<SentimentBloc>().add(ToggleNewsItem(index));
              },
            );
          }

          // Show normal list view
          return Scaffold(
            appBar: AppBar(
              title: const Text('Sentiment'),
            ),
            body: Column(
              children: [
                // Watchlist selector
                _buildWatchlistSelector(context, state),

                // Symbol list
                Expanded(
                  child: _buildSymbolList(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWatchlistSelector(BuildContext context, SentimentState state) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: _buildWatchlistDropdown(context, state),
    );
  }

  Widget _buildWatchlistDropdown(BuildContext context, SentimentState state) {
    final theme = Theme.of(context);

    if (state.availableWatchlists.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'No watchlists',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      );
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Watchlist',
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Watchlist>(
          value: state.selectedWatchlist,
          isExpanded: true,
          isDense: true,
          items: state.availableWatchlists.map((watchlist) {
            return DropdownMenuItem<Watchlist>(
              value: watchlist,
              child: Text(
                watchlist.name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (watchlist) {
            if (watchlist != null) {
              context.read<SentimentBloc>().add(SelectWatchlist(watchlist));
            }
          },
        ),
      ),
    );
  }

  Widget _buildSymbolList(BuildContext context, SentimentState state) {
    final theme = Theme.of(context);
    final symbols = state.sortedSymbols;

    if (state.selectedWatchlist == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 64,
              color: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a watchlist',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a watchlist to view symbols',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    if (symbols.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'No symbols',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This watchlist has no symbols',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: symbols.length,
      itemBuilder: (context, index) {
        final symbol = symbols[index];
        return _buildSymbolCard(context, symbol: symbol);
      },
    );
  }

  Widget _buildSymbolCard(BuildContext context, {required String symbol}) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          context.read<SentimentBloc>().add(SelectSymbol(symbol));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                symbol,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Placeholder for sentiment badge (future feature)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'View',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
