import 'package:intl/intl.dart';

import '../../data/models/earnings_calendar_model.dart';

/// Domain entity representing an upcoming earnings calendar entry.
class EarningsCalendarEntry {
  final DateTime date;
  final double epsEstimate;
  final String symbol;

  const EarningsCalendarEntry({
    required this.date,
    required this.epsEstimate,
    required this.symbol,
  });

  /// Creates an [EarningsCalendarEntry] from an [EarningsCalendarModel].
  factory EarningsCalendarEntry.fromModel(EarningsCalendarModel model) {
    return EarningsCalendarEntry(
      date: DateTime.parse(model.date),
      epsEstimate: model.epsEstimate,
      symbol: model.symbol,
    );
  }

  /// Returns true if earnings are within 7 days.
  bool get isNear {
    final daysUntil = date.difference(DateTime.now()).inDays;
    return daysUntil >= 0 && daysUntil <= 7;
  }

  /// Returns true if earnings are today.
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Days until earnings.
  int get daysUntil => date.difference(DateTime.now()).inDays;

  /// Formatted date (e.g., "Feb 15, 2026").
  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);

  /// Formatted EPS estimate.
  String get formattedEpsEstimate => '\$${epsEstimate.toStringAsFixed(2)}';

  /// Display string for days until.
  String get daysUntilDisplay {
    if (isToday) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    if (daysUntil < 0) return '${-daysUntil}d ago';
    return 'In $daysUntil days';
  }
}
