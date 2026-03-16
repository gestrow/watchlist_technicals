import 'package:flutter/material.dart';

import '../../domain/entities/fundamentals_result.dart';

class FundamentalsSection extends StatelessWidget {
  final FundamentalsResult result;

  const FundamentalsSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Fundamentals',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (result.overview != null) _buildOverviewCard(context, theme),
        if (result.quarterlyEarnings.isNotEmpty)
          _buildEarningsCard(context, theme),
        if (result.quarterlyReports.isNotEmpty)
          _buildRevenueCard(context, theme),
      ],
    );
  }

  Widget _buildOverviewCard(BuildContext context, ThemeData theme) {
    final overview = result.overview!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    overview.name.isNotEmpty ? overview.name : result.symbol,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (overview.sector.isNotEmpty && overview.sector != 'None') ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  _buildBadge(overview.sector, theme),
                  if (overview.industry.isNotEmpty &&
                      overview.industry != 'None')
                    _buildBadge(overview.industry, theme),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _buildMetricsGrid(theme, overview),
            if (overview.description.isNotEmpty &&
                overview.description != 'None') ...[
              const SizedBox(height: 12),
              Text(
                overview.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(ThemeData theme, overview) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildMetric('Market Cap', _formatMarketCap(overview.marketCap), theme),
        _buildMetric('P/E', _formatValue(overview.peRatio), theme),
        _buildMetric('EPS', _formatValue(overview.eps), theme),
        _buildMetric(
            'Div Yield', _formatPercent(overview.dividendYield), theme),
        _buildMetric('Beta', _formatValue(overview.beta), theme),
        _buildMetric(
          '52W Range',
          '${_formatPrice(overview.weekLow52)} - ${_formatPrice(overview.weekHigh52)}',
          theme,
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, size: 20, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Earnings (Last ${result.quarterlyEarnings.length}Q)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Header row
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Quarter',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600))),
                Expanded(
                    child: Text('Reported',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
                Expanded(
                    child: Text('Est.',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
                Expanded(
                    child: Text('Surprise',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
              ],
            ),
            const Divider(height: 8),
            ...result.quarterlyEarnings.map((e) {
              final surprisePct =
                  double.tryParse(e.surprisePercentage) ?? 0.0;
              final isPositive = surprisePct >= 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        e.fiscalDateEnding,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatValue(e.reportedEPS),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatValue(e.estimatedEPS),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${isPositive ? '+' : ''}${surprisePct.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(BuildContext context, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, size: 20, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Income (Last ${result.quarterlyReports.length}Q)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Header row
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Quarter',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600))),
                Expanded(
                    child: Text('Revenue',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
                Expanded(
                    child: Text('Profit',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
                Expanded(
                    child: Text('Net Inc.',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
              ],
            ),
            const Divider(height: 8),
            ...result.quarterlyReports.map((r) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        r.fiscalDateEnding,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatLargeNumber(r.totalRevenue),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatLargeNumber(r.grossProfit),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatLargeNumber(r.netIncome),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _isNegative(r.netIncome)
                              ? Colors.red
                              : null,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Formatting helpers
  // ---------------------------------------------------------------------------

  String _formatMarketCap(String raw) {
    final value = double.tryParse(raw);
    if (value == null) return raw;
    if (value >= 1e12) return '\$${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(1)}M';
    return '\$${value.toStringAsFixed(0)}';
  }

  String _formatLargeNumber(String raw) {
    final value = double.tryParse(raw);
    if (value == null || raw == 'None') return '-';
    final absValue = value.abs();
    final prefix = value < 0 ? '-' : '';
    if (absValue >= 1e9) return '$prefix\$${(absValue / 1e9).toStringAsFixed(1)}B';
    if (absValue >= 1e6) return '$prefix\$${(absValue / 1e6).toStringAsFixed(0)}M';
    return '$prefix\$${absValue.toStringAsFixed(0)}';
  }

  String _formatValue(String raw) {
    if (raw == 'None' || raw.isEmpty) return '-';
    final value = double.tryParse(raw);
    if (value == null) return raw;
    return value.toStringAsFixed(2);
  }

  String _formatPercent(String raw) {
    if (raw == 'None' || raw == '0' || raw.isEmpty) return '-';
    final value = double.tryParse(raw);
    if (value == null) return raw;
    return '${(value * 100).toStringAsFixed(2)}%';
  }

  String _formatPrice(String raw) {
    final value = double.tryParse(raw);
    if (value == null) return raw;
    return '\$${value.toStringAsFixed(2)}';
  }

  bool _isNegative(String raw) {
    final value = double.tryParse(raw);
    return value != null && value < 0;
  }
}
