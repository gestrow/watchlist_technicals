part of 'technicals_bloc.dart';

/// State for the technicals page.
class TechnicalsState extends Equatable {
  final List<Watchlist> availableWatchlists;
  final Watchlist? selectedWatchlist;
  final TimeframeConfig selectedTimeframe;
  final DateTime selectedDate;
  final String? expandedSymbol;

  /// Technical calculation result for the expanded symbol.
  final TechnicalIndicatorsResult? technicalResult;

  /// Whether technical calculations are in progress.
  final bool isLoadingTechnicals;

  /// Error message from technical calculation.
  final String? technicalError;

  /// Fundamentals data for the expanded symbol.
  final FundamentalsResult? fundamentalsResult;

  /// Whether fundamentals are being loaded.
  final bool isLoadingFundamentals;

  /// Error message from fundamentals fetch.
  final String? fundamentalsError;

  /// Whether Alpha Vantage server-side technicals mode is enabled.
  final bool useAvForTechnicals;

  /// Remaining Alpha Vantage API calls for today.
  final int avCallsRemaining;

  const TechnicalsState({
    required this.availableWatchlists,
    required this.selectedWatchlist,
    required this.selectedTimeframe,
    required this.selectedDate,
    this.expandedSymbol,
    this.technicalResult,
    this.isLoadingTechnicals = false,
    this.technicalError,
    this.fundamentalsResult,
    this.isLoadingFundamentals = false,
    this.fundamentalsError,
    this.useAvForTechnicals = false,
    this.avCallsRemaining = 25,
  });

  /// Creates the initial state with default values.
  factory TechnicalsState.initial() {
    final today = DateTime.now();
    return TechnicalsState(
      availableWatchlists: const [],
      selectedWatchlist: null,
      selectedTimeframe: TimeframeConfig.intraday,
      selectedDate: DateTime(today.year, today.month, today.day),
    );
  }

  /// Returns true if the selected date is today.
  bool get isToday {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return selectedDate.year == todayOnly.year &&
        selectedDate.month == todayOnly.month &&
        selectedDate.day == todayOnly.day;
  }

  /// Returns the symbols from the selected watchlist, sorted Z to A.
  List<String> get sortedSymbols {
    if (selectedWatchlist == null) return [];
    final symbols = List<String>.from(selectedWatchlist!.symbols);
    symbols.sort((a, b) => b.compareTo(a)); // Z to A (descending)
    return symbols;
  }

  /// Creates a copy of this state with the given fields replaced.
  TechnicalsState copyWith({
    List<Watchlist>? availableWatchlists,
    Watchlist? selectedWatchlist,
    TimeframeConfig? selectedTimeframe,
    DateTime? selectedDate,
    String? expandedSymbol,
    bool clearExpandedSymbol = false,
    TechnicalIndicatorsResult? technicalResult,
    bool clearTechnicalResult = false,
    bool? isLoadingTechnicals,
    String? technicalError,
    bool clearTechnicalError = false,
    FundamentalsResult? fundamentalsResult,
    bool clearFundamentalsResult = false,
    bool? isLoadingFundamentals,
    String? fundamentalsError,
    bool clearFundamentalsError = false,
    bool? useAvForTechnicals,
    int? avCallsRemaining,
  }) {
    return TechnicalsState(
      availableWatchlists: availableWatchlists ?? this.availableWatchlists,
      selectedWatchlist: selectedWatchlist ?? this.selectedWatchlist,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      selectedDate: selectedDate ?? this.selectedDate,
      expandedSymbol:
          clearExpandedSymbol ? null : (expandedSymbol ?? this.expandedSymbol),
      technicalResult: clearTechnicalResult
          ? null
          : (technicalResult ?? this.technicalResult),
      isLoadingTechnicals: isLoadingTechnicals ?? this.isLoadingTechnicals,
      technicalError:
          clearTechnicalError ? null : (technicalError ?? this.technicalError),
      fundamentalsResult: clearFundamentalsResult
          ? null
          : (fundamentalsResult ?? this.fundamentalsResult),
      isLoadingFundamentals:
          isLoadingFundamentals ?? this.isLoadingFundamentals,
      fundamentalsError: clearFundamentalsError
          ? null
          : (fundamentalsError ?? this.fundamentalsError),
      useAvForTechnicals: useAvForTechnicals ?? this.useAvForTechnicals,
      avCallsRemaining: avCallsRemaining ?? this.avCallsRemaining,
    );
  }

  @override
  List<Object?> get props => [
        availableWatchlists,
        selectedWatchlist,
        selectedTimeframe,
        selectedDate,
        expandedSymbol,
        technicalResult,
        isLoadingTechnicals,
        technicalError,
        fundamentalsResult,
        isLoadingFundamentals,
        fundamentalsError,
        useAvForTechnicals,
        avCallsRemaining,
      ];
}
