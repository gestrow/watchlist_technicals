import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A date selector widget with animated transitions between modes.
///
/// When the date is today: shows [< Date | "up-to-date"]
/// When the date is before today: shows [< Date >]
class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final bool isToday;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final bool enabled;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.isToday,
    required this.onBack,
    required this.onForward,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left arrow - always visible
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: enabled ? onBack : null,
            tooltip: 'Previous day',
            visualDensity: VisualDensity.compact,
          ),

          // Date display
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateFormat.format(selectedDate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isToday)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isToday ? 1.0 : 0.0,
                      child: Text(
                        'up-to-date',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Right arrow - animated visibility
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isToday
                ? const SizedBox(width: 8)
                : IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: enabled ? onForward : null,
                    tooltip: 'Next day',
                    visualDensity: VisualDensity.compact,
                  ),
          ),
        ],
      ),
    );
  }
}
