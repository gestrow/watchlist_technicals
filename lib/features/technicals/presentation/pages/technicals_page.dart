import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/av_call_tracker.dart';
import '../../../watchlist/domain/entities/watchlist.dart';
import '../../../watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../domain/entities/timeframe_config.dart';
import '../../domain/usecases/calculate_technicals_usecase.dart';
import '../../domain/usecases/fetch_fundamentals_usecase.dart';
import '../bloc/technicals_bloc.dart';
import '../widgets/custom_timeframe_dialog.dart';
import '../widgets/date_selector.dart';
import '../widgets/symbol_expanded_view.dart';

/// Main page for technical analysis.
class TechnicalsPage extends StatelessWidget {
  const TechnicalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    CalculateTechnicalsUsecase? usecase;
    FetchFundamentalsUsecase? fundamentalsUsecase;
    AvCallTracker? avCallTracker;
    Box? settingsBox;

    try {
      usecase = sl<CalculateTechnicalsUsecase>();
    } catch (_) {}
    try {
      fundamentalsUsecase = sl<FetchFundamentalsUsecase>();
    } catch (_) {}
    try {
      avCallTracker = sl<AvCallTracker>();
    } catch (_) {}
    try {
      settingsBox = sl<Box>(instanceName: AppConstants.settingsBoxName);
    } catch (_) {}

    return BlocProvider(
      create: (_) => TechnicalsBloc(
        calculateTechnicalsUsecase: usecase,
        fetchFundamentalsUsecase: fundamentalsUsecase,
        avCallTracker: avCallTracker,
        settingsBox: settingsBox,
      ),
      child: const _TechnicalsPageContent(),
    );
  }
}

class _TechnicalsPageContent extends StatefulWidget {
  const _TechnicalsPageContent();

  @override
  State<_TechnicalsPageContent> createState() => _TechnicalsPageContentState();
}

class _TechnicalsPageContentState extends State<_TechnicalsPageContent> {
  @override
  void initState() {
    super.initState();
    // Sync watchlists when watchlist state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWatchlists();
    });
  }

  void _syncWatchlists() {
    final watchlistState = context.read<WatchlistBloc>().state;
    if (watchlistState is WatchlistLoaded) {
      context.read<TechnicalsBloc>().add(
            UpdateAvailableWatchlists(watchlistState.watchlists),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchlistBloc, WatchlistState>(
      listener: (context, state) {
        if (state is WatchlistLoaded) {
          context.read<TechnicalsBloc>().add(
                UpdateAvailableWatchlists(state.watchlists),
              );
        }
      },
      child: BlocBuilder<TechnicalsBloc, TechnicalsState>(
        builder: (context, state) {
          // Show expanded view if a symbol is expanded
          if (state.expandedSymbol != null) {
            return SymbolExpandedView(
              symbol: state.expandedSymbol!,
              config: state.selectedTimeframe,
              result: state.technicalResult,
              isLoading: state.isLoadingTechnicals,
              error: state.technicalError,
              fundamentals: state.fundamentalsResult,
              isLoadingFundamentals: state.isLoadingFundamentals,
              fundamentalsError: state.fundamentalsError,
              useAvForTechnicals: state.useAvForTechnicals,
              avCallsRemaining: state.avCallsRemaining,
              onClose: () {
                context.read<TechnicalsBloc>().add(const CollapseSymbol());
              },
              onTimeframeChanged: (newConfig) {
                context.read<TechnicalsBloc>().add(SelectTimeframe(newConfig));
                // Reload technicals with new timeframe
                context
                    .read<TechnicalsBloc>()
                    .add(LoadTechnicals(state.expandedSymbol!));
              },
            );
          }

          // Show normal list view
          return Scaffold(
            appBar: AppBar(
              title: const Text('Technicals'),
            ),
            body: Column(
              children: [
                // Top section - pinned selectors
                _buildSelectorSection(context, state),

                // Symbol list - scrollable
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

  Widget _buildSelectorSection(BuildContext context, TechnicalsState state) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Watchlist and Timeframe selectors row
          Row(
            children: [
              // Watchlist selector
              Expanded(
                child: _buildWatchlistDropdown(context, state),
              ),
              const SizedBox(width: 12),
              // Timeframe selector
              Expanded(
                child: _buildTimeframeDropdown(context, state),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date selector row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DateSelector(
                selectedDate: state.selectedDate,
                isToday: state.isToday,
                enabled: !state.useAvForTechnicals,
                onBack: () {
                  context.read<TechnicalsBloc>().add(const NavigateDateBack());
                },
                onForward: () {
                  context
                      .read<TechnicalsBloc>()
                      .add(const NavigateDateForward());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistDropdown(BuildContext context, TechnicalsState state) {
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
              context.read<TechnicalsBloc>().add(SelectWatchlist(watchlist));
            }
          },
        ),
      ),
    );
  }

  Widget _buildTimeframeDropdown(BuildContext context, TechnicalsState state) {
    // Combine presets with current custom config if applicable
    final items = <_TimeframeOption>[
      ...TimeframeConfig.presets
          .map((config) => _TimeframeOption(config: config)),
      const _TimeframeOption(isCustomOption: true),
    ];

    // Check if current selection is a custom config
    final isCustomSelection =
        !TimeframeConfig.presets.contains(state.selectedTimeframe);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Timeframe',
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_TimeframeOption>(
          value: isCustomSelection
              ? _TimeframeOption(config: state.selectedTimeframe)
              : items
                  .firstWhere((item) => item.config == state.selectedTimeframe),
          isExpanded: true,
          isDense: true,
          items: [
            ...items.map((option) {
              if (option.isCustomOption) {
                return DropdownMenuItem<_TimeframeOption>(
                  value: option,
                  child: const Text('Custom...'),
                );
              }
              return DropdownMenuItem<_TimeframeOption>(
                value: option,
                child: Text(option.config!.name),
              );
            }),
            // Add current custom config if selected
            if (isCustomSelection)
              DropdownMenuItem<_TimeframeOption>(
                value: _TimeframeOption(config: state.selectedTimeframe),
                child: Text('Custom (${state.selectedTimeframe.rsiPeriod})'),
              ),
          ],
          onChanged: (option) async {
            if (option == null) return;

            if (option.isCustomOption) {
              final customConfig = await CustomTimeframeDialog.show(
                context,
                initialConfig: state.selectedTimeframe,
              );
              if (customConfig != null && context.mounted) {
                context
                    .read<TechnicalsBloc>()
                    .add(SelectTimeframe(customConfig));
              }
            } else if (option.config != null) {
              context
                  .read<TechnicalsBloc>()
                  .add(SelectTimeframe(option.config!));
            }
          },
        ),
      ),
    );
  }

  Widget _buildSymbolList(BuildContext context, TechnicalsState state) {
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

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh watchlists which will update symbols
        _syncWatchlists();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: symbols.length,
        itemBuilder: (context, index) {
          final symbol = symbols[index];

          return _buildSymbolCard(
            context,
            symbol: symbol,
          );
        },
      ),
    );
  }

  Widget _buildSymbolCard(
    BuildContext context, {
    required String symbol,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          context.read<TechnicalsBloc>().add(ExpandSymbol(symbol));
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

/// Helper class for timeframe dropdown options.
class _TimeframeOption {
  final TimeframeConfig? config;
  final bool isCustomOption;

  const _TimeframeOption({
    this.config,
    this.isCustomOption = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _TimeframeOption) return false;
    if (isCustomOption && other.isCustomOption) return true;
    return config == other.config;
  }

  @override
  int get hashCode => isCustomOption ? 0 : config.hashCode;
}
