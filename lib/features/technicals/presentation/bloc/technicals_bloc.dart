import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/av_call_tracker.dart';
import '../../../watchlist/domain/entities/watchlist.dart';
import '../../domain/entities/fundamentals_result.dart';
import '../../domain/entities/technical_indicators_result.dart';
import '../../domain/entities/timeframe_config.dart';
import '../../domain/usecases/calculate_technicals_usecase.dart';
import '../../domain/usecases/fetch_fundamentals_usecase.dart';

part 'technicals_event.dart';
part 'technicals_state.dart';

/// BLoC for managing technicals page state.
class TechnicalsBloc extends Bloc<TechnicalsEvent, TechnicalsState> {
  final CalculateTechnicalsUsecase? _calculateTechnicalsUsecase;
  final FetchFundamentalsUsecase? _fetchFundamentalsUsecase;
  final AvCallTracker? _avCallTracker;
  final Box? _settingsBox;

  /// Cache of calculated results by symbol key.
  final Map<String, TechnicalIndicatorsResult> _resultsCache = {};

  TechnicalsBloc({
    CalculateTechnicalsUsecase? calculateTechnicalsUsecase,
    FetchFundamentalsUsecase? fetchFundamentalsUsecase,
    AvCallTracker? avCallTracker,
    Box? settingsBox,
  })  : _calculateTechnicalsUsecase = calculateTechnicalsUsecase,
        _fetchFundamentalsUsecase = fetchFundamentalsUsecase,
        _avCallTracker = avCallTracker,
        _settingsBox = settingsBox,
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
    on<LoadFundamentals>(_onLoadFundamentals);
    on<SyncAvMode>(_onSyncAvMode);

    // Sync AV mode on creation
    add(const SyncAvMode());
  }

  /// Generates a cache key for the result.
  String _getCacheKey(String symbol, DateTime date, TimeframeConfig config) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${symbol}_${dateStr}_${config.name}';
  }

  void _onSyncAvMode(
    SyncAvMode event,
    Emitter<TechnicalsState> emit,
  ) {
    final avMode = _settingsBox?.get(AppConstants.avModeKey, defaultValue: false)
            as bool? ??
        false;
    final remaining = _avCallTracker?.remainingCalls ?? 25;
    emit(state.copyWith(
      useAvForTechnicals: avMode,
      avCallsRemaining: remaining,
    ));
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
    // Re-sync AV mode in case it changed on settings page
    add(const SyncAvMode());

    emit(state.copyWith(
      expandedSymbol: event.symbol,
      clearFundamentalsResult: true,
    ));

    // Automatically load technicals when expanding
    if (_calculateTechnicalsUsecase != null) {
      add(LoadTechnicals(event.symbol));
    }

    // Load fundamentals if AV is configured
    if (_fetchFundamentalsUsecase != null) {
      add(LoadFundamentals(event.symbol));
    }
  }

  void _onCollapseSymbol(
    CollapseSymbol event,
    Emitter<TechnicalsState> emit,
  ) {
    emit(state.copyWith(
      clearExpandedSymbol: true,
      clearTechnicalResult: true,
      clearFundamentalsResult: true,
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
      TechnicalIndicatorsResult result;

      if (state.useAvForTechnicals) {
        result = await _calculateTechnicalsUsecase.executeWithAv(
          symbol: symbol,
          endDate: date,
          config: config,
        );
      } else {
        result = await _calculateTechnicalsUsecase.execute(
          symbol: symbol,
          endDate: date,
          config: config,
        );
      }

      // Cache the result
      _resultsCache[cacheKey] = result;

      // Update AV call count
      final remaining = _avCallTracker?.remainingCalls ?? 25;

      // Only emit if still viewing the same symbol
      if (state.expandedSymbol == symbol) {
        emit(state.copyWith(
          technicalResult: result,
          isLoadingTechnicals: false,
          avCallsRemaining: remaining,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        technicalError: e.toString(),
        isLoadingTechnicals: false,
      ));
    }
  }

  Future<void> _onLoadFundamentals(
    LoadFundamentals event,
    Emitter<TechnicalsState> emit,
  ) async {
    if (_fetchFundamentalsUsecase == null) return;

    emit(state.copyWith(
      isLoadingFundamentals: true,
      clearFundamentalsError: true,
    ));

    try {
      final result = await _fetchFundamentalsUsecase.execute(
        symbol: event.symbol,
      );

      final remaining = _avCallTracker?.remainingCalls ?? 25;

      if (state.expandedSymbol == event.symbol) {
        emit(state.copyWith(
          fundamentalsResult: result,
          isLoadingFundamentals: false,
          avCallsRemaining: remaining,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        fundamentalsError: e.toString(),
        isLoadingFundamentals: false,
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
