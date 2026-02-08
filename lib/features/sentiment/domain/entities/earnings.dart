import '../../data/models/earnings_model.dart';

/// Domain entity representing earnings surprise data.
class Earnings {
  final double actual;
  final double estimate;
  final String period;
  final double surprise;

  const Earnings({
    required this.actual,
    required this.estimate,
    required this.period,
    required this.surprise,
  });

  /// Creates an [Earnings] from an [EarningsModel].
  factory Earnings.fromModel(EarningsModel model) {
    return Earnings(
      actual: model.actual,
      estimate: model.estimate,
      period: model.period,
      surprise: model.surprise,
    );
  }

  /// Returns true if earnings beat estimates.
  bool get isBeat => surprise > 0;

  /// Returns true if earnings missed estimates.
  bool get isMiss => surprise < 0;

  /// Returns true if earnings met estimates.
  bool get isMet => surprise == 0;

  /// Formatted actual EPS.
  String get formattedActual => '\$${actual.toStringAsFixed(2)}';

  /// Formatted estimate EPS.
  String get formattedEstimate => '\$${estimate.toStringAsFixed(2)}';

  /// Formatted surprise with sign.
  String get formattedSurprise {
    final sign = surprise >= 0 ? '+' : '';
    return '$sign\$${surprise.toStringAsFixed(2)}';
  }

  /// Formatted surprise percentage.
  String get formattedSurprisePercent {
    if (estimate == 0) return 'N/A';
    final percent = (surprise / estimate.abs()) * 100;
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(1)}%';
  }

  /// Quarter display (e.g., "Q1 2024" from "2024-03-31").
  String get quarterDisplay {
    final parts = period.split('-');
    if (parts.length >= 2) {
      final year = parts[0];
      final month = int.tryParse(parts[1]) ?? 0;
      final quarter = ((month - 1) ~/ 3) + 1;
      return 'Q$quarter $year';
    }
    return period;
  }
}
