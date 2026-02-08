import 'package:flutter/material.dart';

import '../../domain/entities/earnings.dart';
import '../../domain/entities/earnings_calendar_entry.dart';

/// Widget displaying recent earnings and upcoming earnings calendar.
class EarningsSection extends StatelessWidget {
  final List<Earnings>? earningsSurprises;
  final List<EarningsCalendarEntry>? earningsCalendar;

  const EarningsSection({
    super.key,
    this.earningsSurprises,
    this.earningsCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasEarnings =
        earningsSurprises != null && earningsSurprises!.isNotEmpty;
    final hasCalendar =
        earningsCalendar != null && earningsCalendar!.isNotEmpty;

    if (!hasEarnings && !hasCalendar) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earnings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Earnings data not available',
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Earnings section
            if (hasEarnings) ...[
              Text(
                'Recent Earnings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildEarningsTable(context),
            ],

            // Spacing between sections
            if (hasEarnings && hasCalendar) const SizedBox(height: 24),

            // Upcoming Earnings section
            if (hasCalendar) ...[
              Text(
                'Upcoming Earnings (Next 30 Days)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildEarningsCalendar(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsTable(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 0,
        headingRowHeight: 40,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 48,
        columns: const [
          DataColumn(label: Text('Quarter')),
          DataColumn(label: Text('Actual'), numeric: true),
          DataColumn(label: Text('Estimate'), numeric: true),
          DataColumn(label: Text('Surprise'), numeric: true),
        ],
        rows: earningsSurprises!.asMap().entries.map((entry) {
          final index = entry.key;
          final earnings = entry.value;
          final isAlternate = index % 2 == 1;

          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (isAlternate) {
                  return theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3);
                }
                return null;
              },
            ),
            cells: [
              DataCell(Text(earnings.quarterDisplay)),
              DataCell(Text(earnings.formattedActual)),
              DataCell(Text(earnings.formattedEstimate)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      earnings.isBeat
                          ? Icons.arrow_upward
                          : earnings.isMiss
                              ? Icons.arrow_downward
                              : Icons.remove,
                      size: 14,
                      color: earnings.isBeat
                          ? Colors.green.shade600
                          : earnings.isMiss
                              ? Colors.red.shade600
                              : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      earnings.formattedSurprise,
                      style: TextStyle(
                        color: earnings.isBeat
                            ? Colors.green.shade600
                            : earnings.isMiss
                                ? Colors.red.shade600
                                : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEarningsCalendar(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: earningsCalendar!.length,
      itemBuilder: (context, index) {
        final entry = earningsCalendar![index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: entry.isNear
                ? Colors.orange.withValues(alpha: 0.1)
                : null,
            borderRadius: BorderRadius.circular(8),
            border: entry.isNear
                ? Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: entry.isNear
                    ? Colors.orange.withValues(alpha: 0.2)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today,
                size: 20,
                color: entry.isNear
                    ? Colors.orange.shade700
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              entry.formattedDate,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Est. EPS: ${entry.formattedEpsEstimate}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: entry.isNear
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.daysUntilDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : Text(
                    entry.daysUntilDisplay,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
