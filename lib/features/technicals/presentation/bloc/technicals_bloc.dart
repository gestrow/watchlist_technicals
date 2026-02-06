import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../watchlist/domain/entities/watchlist.dart';
import '../../domain/entities/technical_indicators_result.dart';
import '../../domain/entities/timeframe_config.dart';
import '../../domain/usecases/calculate_technicals_usecase.dart';

part 'technicals_event.dart';
part 'technicals_state.dart';

/// BLoC for managing technicals page state.
class TechnicalsBloc extends Bloc<TechnicalsEvent, TechnicalsState> {
  final CalculateTechnicalsUsecase? _calculateTechnicalsUsecase;

  /// Cache of calculated results by symbol key.
  final Map<String, TechnicalIndicatorsResult> _resultsCache = {};

  TechnicalsBloc({
    CalculateTechnicalsUsecase? calculateTechnicalsUsecase,
  })  : _calculateTechnicalsUsecase = calculateTechnicalsUsecase,
        super(TechnicalsState.initial()) {
    on<SelectWatchlist>(_onSelectWatchlist);
    on<SelectTimeframe>(_onSelectTimeframe);
    on<SelectDate>(_onSelectDate);
    on<NavigateDateBack>(_onNavigateDateBack);
    on<NavigateDateForward>(_onNavigateDateForward);
    on<ExpandSymbol>(_onExpandSymbol);
    on<CollapseSymbol>(_onCollapseSymbol);
    on<UpdateAvailableWatchlists>(_onUpdateAvailableWatchlists);
    on<LoadTechnicals>(_onLoadTechnicals);
    on<ClearTechnicalsError>(_onClearTechnicalsError);
  }

  /// Generates a cache key for the result.
  String _getCacheKey(String symbol, DateTime date, TimeframeConfig config) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${symbol}_${dateStr}_${config.name}';
  }

  void _onSelectWatchlist(
    SelectWatchlist event,
    Emitter<TechnicalsState> emit,
  ) {
    emit(state.copyWith(selectedWatchlist: event.watchlist));
  }

  void _onSelectTimeframe(
    SelectTimeframe event,
    Emitter<TechnicalsState> emit,
  ) {
    // Clear cached result when timeframe changes
    emit(state.copyWith(
      selectedTimeframe: event.timeframe,
      clearTechnicalResult: true,
    ));
  }

  void _onSelectDate(
    SelectDate event,
    Emitter<TechnicalsState> emit,
  ) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Don't allow future dates
    if (event.date.isAfter(todayOnly)) {
      emit(state.copyWith(selectedDate: todayOnly, clearTechnicalResult: true));
    } else {
      emit(state.copyWith(selectedDate: event.date, clearTechnicalResult: true));
    }
  }

  void _onNavigateDateBack(
    NavigateDateBack event,
    Emitter<TechnicalsState> emit,
  ) {
    final newDate = state.selectedDate.subtract(const Duration(days: 1));
    emit(state.copyWith(selectedDate: newDate, clearTechnicalResult: true));
  }

  void _onNavigateDateForward(
    NavigateDateForward event,
    Emitter<TechnicalsState> emit,
  ) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final newDate = state.selectedDate.add(const Duration(days: 1));

    // Don't allow future dates
    if (!newDate.isAfter(todayOnly)) {
      emit(state.copyWith(selectedDate: newDate, clearTechnicalResult: true));
    }
  }

  void _onExpandSymbol(
    ExpandSymbol event,
    Emitter<TechnicalsState> emit,
  ) {
    emit(state.copyWith(expandedSymbol: event.symbol));

    // Automatically load technicals when expanding
    if (_calculateTechnicalsUsecase != null) {
      add(LoadTechnicals(event.symbol));
    }
  }

  void _onCollapseSymbol(
    CollapseSymbol event,
    Emitter<TechnicalsState> emit,
  ) {
    emit(state.copyWith(
      clearExpandedSymbol: true,
      clearTechnicalResult: true,
    ));
  }

  void _onUpdateAvailableWatchlists(
    UpdateAvailableWatchlists event,
    Emitter<TechnicalsState> emit,
  ) {
    // If currently selected watchlist is no longer available, clear selection
    Watchlist? newSelection = state.selectedWatchlist;
    if (newSelection != null) {
      final stillExists = event.watchlists.any((w) => w.id == newSelection!.id);
      if (!stillExists) {
        newSelection =
            event.watchlists.isNotEmpty ? event.watchlists.first : null;
      } else {
        // Update to the latest version of the watchlist
        newSelection =
            event.watchlists.firstWhere((w) => w.id == newSelection!.id);
      }
    } else if (event.watchlists.isNotEmpty) {
      // Auto-select first watchlist if none selected
      newSelection = event.watchlists.first;
    }

    emit(state.copyWith(
      availableWatchlists: event.watchlists,
      selectedWatchlist: newSelection,
    ));
  }

  Future<void> _onLoadTechnicals(
    LoadTechnicals event,
    Emitter<TechnicalsState> emit,
  ) async {
    if (_calculateTechnicalsUsecase == null) {
      emit(state.copyWith(
        technicalError: 'Technical calculations not available',
      ));
      return;
    }

    final symbol = event.symbol;
    final date = state.selectedDate;
    final config = state.selectedTimeframe;

    // Check cache first
    final cacheKey = _getCacheKey(symbol, date, config);
    final cachedResult = _resultsCache[cacheKey];
    if (cachedResult != null) {
      // Check if cached result is still fresh (within 5 minutes)
      final age = DateTime.now().difference(cachedResult.calculatedAt);
      if (age.inMinutes < 5) {
        emit(state.copyWith(technicalResult: cachedResult));
        return;
      }
    }

    // Start loading
    emit(state.copyWith(isLoadingTechnicals: true, clearTechnicalError: true));

    try {
      final result = await _calculateTechnicalsUsecase.execute(
        symbol: symbol,
        endDate: date,
        config: config,
      );

      // Cache the result
      _resultsCache[cacheKey] = result;

      // Only emit if still viewing the same symbol
      if (state.expandedSymbol == symbol) {
        emit(state.copyWith(
          technicalResult: result,
          isLoadingTechnicals: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        technicalError: e.toString(),
        isLoadingTechnicals: false,
      ));
    }
  }

  void _onClearTechnicalsError(
    ClearTechnicalsError event,
    Emitter<TechnicalsState> emit,
  ) {
    emit(state.copyWith(clearTechnicalError: true));
  }
}
