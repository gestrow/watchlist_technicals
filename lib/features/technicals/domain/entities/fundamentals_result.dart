import 'package:equatable/equatable.dart';

import '../../data/models/fundamentals_model.dart';

class FundamentalsResult extends Equatable {
  final String symbol;
  final CompanyOverviewModel? overview;
  final List<EarningsQuarterModel> quarterlyEarnings;
  final List<IncomeQuarterModel> quarterlyReports;
  final DateTime fetchedAt;

  const FundamentalsResult({
    required this.symbol,
    this.overview,
    this.quarterlyEarnings = const [],
    this.quarterlyReports = const [],
    required this.fetchedAt,
  });

  @override
  List<Object?> get props => [
        symbol,
        overview?.symbol,
        quarterlyEarnings.length,
        quarterlyReports.length,
        fetchedAt,
      ];
}
