import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/fundamentals_result.dart';
import '../../domain/entities/technical_indicators_result.dart';
import '../../domain/entities/timeframe_config.dart';
import '../bloc/technicals_bloc.dart';
import 'custom_timeframe_dialog.dart';
import 'fundamentals_section.dart';
import 'technical_chart.dart';

/// Expanded view for a symbol showing full technical analysis.
class SymbolExpandedView extends StatelessWidget {
  final String symbol;
  final TimeframeConfig config;
  final TechnicalIndicatorsResult? result;
  final bool isLoading;
  final String? error;
  final VoidCallback onClose;
  final Function(TimeframeConfig) onTimeframeChanged;
  final FundamentalsResult? fundamentals;
  final bool isLoadingFundamentals;
  final String? fundamentalsError;
  final bool useAvForTechnicals;
  final int avCallsRemaining;

  const SymbolExpandedView({
    super.key,
    required this.symbol,
    required this.config,
    required this.result,
    required this.isLoading,
    required this.error,
    required this.onClose,
    required this.onTimeframeChanged,
    this.fundamentals,
    this.isLoadingFundamentals = false,
    this.fundamentalsError,
    this.useAvForTechnicals = false,
    this.avCallsRemaining = 25,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
        title: Row(
          children: [
            Text(
              symbol,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            _buildTimeframeBadge(context),
          ],
        ),
        actions: [
          if (useAvForTechnicals)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                avatar: Icon(Icons.cloud, size: 14,
                    color: avCallsRemaining <= 5 ? Colors.red : Colors.green),
                label: Text(
                  '$avCallsRemaining/25',
                  style: const TextStyle(fontSize: 11),
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
            ),
          if (result != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<TechnicalsBloc>().add(LoadTechnicals(symbol));
              },
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _buildBody(context, theme),
    );
  }

  Widget _buildTimeframeBadge(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final newConfig = await CustomTimeframeDialog.show(
          context,
          initialConfig: config,
        );
        if (newConfig != null) {
          onTimeframeChanged(newConfig);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              config.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Calculating indicators...'),
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
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading data',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<TechnicalsBloc>().add(LoadTechnicals(symbol));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (result == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    if (!result!.hasEnoughData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Insufficient data',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Need at least 30 days of data for reliable calculations.\nCurrently have ${result!.candles.length} days.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TechnicalChart(
                result: result!,
                config: config,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Indicator cards
          _buildIndicatorCards(context, theme),

          // Fundamentals section
          const SizedBox(height: 16),
          _buildFundamentalsArea(context, theme),
        ],
      ),
    );
  }

  Widget _buildFundamentalsArea(BuildContext context, ThemeData theme) {
    if (isLoadingFundamentals) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8, width: 8, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(height: 8),
              Text('Loading fundamentals...', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (fundamentalsError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Fundamentals unavailable',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (fundamentals != null) {
      return FundamentalsSection(result: fundamentals!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildIndicatorCards(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indicator Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // RSI Card
        _buildRsiCard(theme),
        const SizedBox(height: 8),

        // EMA/SMA Card
        _buildMaCard(theme),
        const SizedBox(height: 8),

        // MACD Card
        _buildMacdCard(theme),
        const SizedBox(height: 8),

        // Dominant Cycle Card
        if (result!.dominantCycle != null) ...[
          _buildDominantCycleCard(theme),
          const SizedBox(height: 8),
        ],

        // Bollinger Bands Card
        _buildBollingerCard(theme),
        const SizedBox(height: 8),

        // VWAP Card
        _buildVwapCard(theme),
      ],
    );
  }

  Widget _buildRsiCard(ThemeData theme) {
    final rsi = result!.currentRsi;
    final isOverbought = rsi != null && rsi > config.rsiOverbought;
    final isOversold = rsi != null && rsi < config.rsiOversold;

    Color statusColor;
    String status;
    if (isOverbought) {
      statusColor = AppColors.rsiOverbought;
      status = 'Overbought';
    } else if (isOversold) {
      statusColor = AppColors.rsiOversold;
      status = 'Oversold';
    } else {
      statusColor = AppColors.neutral;
      status = 'Neutral';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'RSI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RSI(${config.rsiPeriod})',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rsi != null ? rsi.toStringAsFixed(2) : 'N/A',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaCard(ThemeData theme) {
    final price = result!.currentPrice;
    final emas = result!.currentEmas;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      config.useSMA ? 'SMA' : 'EMA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  config.useSMA ? 'Simple Moving Average' : 'Exponential Moving Average',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...emas.entries.map((entry) {
              final period = entry.key;
              final value = entry.value;
              final isAbove = price != null && value != null && price > value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${config.useSMA ? 'SMA' : 'EMA'}($period)'),
                    Row(
                      children: [
                        Text(
                          value != null ? value.toStringAsFixed(2) : 'N/A',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (value != null)
                          Icon(
                            isAbove ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                            color: isAbove ? AppColors.bullish : AppColors.bearish,
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            if (price != null)
              Text(
                'Current Price: ${price.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacdCard(ThemeData theme) {
    final macd = result!.currentMacd;
    final isPositive = (macd.histogram ?? 0) >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.macdHistogram.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'MACD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.macdHistogram,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'MACD(${config.macdFast},${config.macdSlow},${config.macdSignal})',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacdValue('MACD', macd.macdLine, AppColors.macdLine, theme),
                _buildMacdValue('Signal', macd.signalLine, AppColors.macdSignal, theme),
                _buildMacdValue(
                  'Histogram',
                  macd.histogram,
                  isPositive ? AppColors.bullish : AppColors.bearish,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacdValue(String label, double? value, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value != null ? value.toStringAsFixed(3) : 'N/A',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDominantCycleCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.waves,
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dominant Cycle',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result!.dominantCycle!.toStringAsFixed(2)} days',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBollingerCard(ThemeData theme) {
    final bb = result!.currentBollinger;
    final price = result!.currentPrice;

    String position = 'N/A';
    Color positionColor = AppColors.neutral;

    if (price != null && bb.upper != null && bb.lower != null) {
      if (price >= bb.upper!) {
        position = 'At Upper Band';
        positionColor = AppColors.bearish;
      } else if (price <= bb.lower!) {
        position = 'At Lower Band';
        positionColor = AppColors.bullish;
      } else {
        final range = bb.upper! - bb.lower!;
        final posInRange = (price - bb.lower!) / range;
        position = '${(posInRange * 100).toStringAsFixed(0)}% from lower';
        positionColor = AppColors.neutral;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.bbMiddle.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'BB',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.bbMiddle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Bollinger Bands(${config.bollingerPeriod}, ${config.bollingerStdDev})',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upper'),
                Text(
                  bb.upper != null ? bb.upper!.toStringAsFixed(2) : 'N/A',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Middle'),
                Text(
                  bb.middle != null ? bb.middle!.toStringAsFixed(2) : 'N/A',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lower'),
                Text(
                  bb.lower != null ? bb.lower!.toStringAsFixed(2) : 'N/A',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: positionColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                position,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: positionColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVwapCard(ThemeData theme) {
    final vwap = result!.currentVwap;
    final price = result!.currentPrice;
    final isAbove = price != null && vwap != null && price > vwap;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'VWAP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VWAP(${config.vwapPeriod})',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        vwap != null ? vwap.toStringAsFixed(2) : 'N/A',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vwap != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          isAbove ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 20,
                          color: isAbove ? AppColors.bullish : AppColors.bearish,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAbove ? 'Above' : 'Below',
                          style: TextStyle(
                            fontSize: 12,
                            color: isAbove ? AppColors.bullish : AppColors.bearish,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
