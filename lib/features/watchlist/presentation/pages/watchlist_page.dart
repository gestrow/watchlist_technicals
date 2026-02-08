import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/watchlist.dart';
import '../bloc/watchlist_bloc.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/watchlist_card.dart';
import '../widgets/watchlist_dialog.dart';

/// The main page displaying all watchlists with CRUD operations.
class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlists'),
      ),
      body: BlocConsumer<WatchlistBloc, WatchlistState>(
        listener: (context, state) {
          if (state is WatchlistError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WatchlistInitial || state is WatchlistLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is WatchlistLoaded) {
            return _WatchlistContent(
              watchlists: state.watchlists,
            );
          }

          if (state is WatchlistError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load watchlists',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      context.read<WatchlistBloc>().add(const LoadWatchlists());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          // Only show FAB when loaded and has watchlists
          if (state is WatchlistLoaded && state.watchlists.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => _showAddDialog(context),
              tooltip: 'Add watchlist',
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await WatchlistDialog.show(context);
    if (result != null && context.mounted) {
      context.read<WatchlistBloc>().add(AddWatchlist(
            name: result.name,
            symbols: result.symbols,
          ));
    }
  }
}

/// Content widget showing the list of watchlists or empty state.
class _WatchlistContent extends StatelessWidget {
  final List<Watchlist> watchlists;

  const _WatchlistContent({required this.watchlists});

  @override
  Widget build(BuildContext context) {
    if (watchlists.isEmpty) {
      return _EmptyState(
        onAdd: () => _showAddDialog(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<WatchlistBloc>().add(const LoadWatchlists());
        // Wait for state to update
        await context.read<WatchlistBloc>().stream.firstWhere(
              (state) => state is WatchlistLoaded || state is WatchlistError,
            );
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: watchlists.length,
        itemBuilder: (context, index) {
          final watchlist = watchlists[index];
          return WatchlistCard(
            watchlist: watchlist,
            onEdit: () => _showEditDialog(context, watchlist),
            onDelete: () => _showDeleteDialog(context, watchlist),
          );
        },
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await WatchlistDialog.show(context);
    if (result != null && context.mounted) {
      context.read<WatchlistBloc>().add(AddWatchlist(
            name: result.name,
            symbols: result.symbols,
          ));
    }
  }

  Future<void> _showEditDialog(BuildContext context, Watchlist watchlist) async {
    final result = await WatchlistDialog.show(context, watchlist: watchlist);
    if (result != null && context.mounted) {
      context.read<WatchlistBloc>().add(UpdateWatchlist(
            id: watchlist.id,
            name: result.name,
            symbols: result.symbols,
          ));
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, Watchlist watchlist) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      watchlistName: watchlist.name,
    );
    if (confirmed == true && context.mounted) {
      context.read<WatchlistBloc>().add(DeleteWatchlist(watchlist.id));
    }
  }
}

/// Empty state widget shown when there are no watchlists.
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

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
              Icons.list_alt_outlined,
              size: 80,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 24),
            Text(
              'No Watchlists Yet',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a watchlist to track your favorite stocks',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Large add button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
                  'Create Watchlist',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
