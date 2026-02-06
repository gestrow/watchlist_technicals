import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../watchlist/domain/entities/watchlist.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/entities/stock_quote.dart';
import '../../domain/repositories/sentiment_repository.dart';

part 'sentiment_event.dart';
part 'sentiment_state.dart';

/// BLoC for managing sentiment page state.
class SentimentBloc extends Bloc<SentimentEvent, SentimentState> {
  final SentimentRepository? _repository;

  /// Cache of sentiment data by symbol.
  final Map<String, _CachedSentimentData> _cache = {};

  SentimentBloc({
    SentimentRepository? repository,
  })  : _repository = repository,
        super(SentimentState.initial()) {
    on<UpdateAvailableWatchlists>(_onUpdateAvailableWatchlists);
    on<SelectWatchlist>(_onSelectWatchlist);
    on<SelectSymbol>(_onSelectSymbol);
    on<LoadSentimentData>(_onLoadSentimentData);
    on<TogglePeers>(_onTogglePeers);
    on<CollapseSentiment>(_onCollapseSentiment);
    on<ClearSentimentError>(_onClearSentimentError);
    on<SelectPeer>(_onSelectPeer);
  }

  void _onUpdateAvailableWatchlists(
    UpdateAvailableWatchlists event,
    Emitter<SentimentState> emit,
  ) {
    Watchlist? newSelection = state.selectedWatchlist;
    if (newSelection != null) {
      final stillExists = event.watchlists.any((w) => w.id == newSelection!.id);
      if (!stillExists) {
        newSelection =
            event.watchlists.isNotEmpty ? event.watchlists.first : null;
      } else {
        newSelection =
            event.watchlists.firstWhere((w) => w.id == newSelection!.id);
      }
    } else if (event.watchlists.isNotEmpty) {
      newSelection = event.watchlists.first;
    }

    emit(state.copyWith(
      availableWatchlists: event.watchlists,
      selectedWatchlist: newSelection,
    ));
  }

  void _onSelectWatchlist(
    SelectWatchlist event,
    Emitter<SentimentState> emit,
  ) {
    emit(state.copyWith(
      selectedWatchlist: event.watchlist,
      clearSelectedSymbol: true,
      clearProfile: true,
      clearQuote: true,
      clearPeers: true,
    ));
  }

  void _onSelectSymbol(
    SelectSymbol event,
    Emitter<SentimentState> emit,
  ) {
    emit(state.copyWith(
      selectedSymbol: event.symbol,
      clearProfile: true,
      clearQuote: true,
      clearPeers: true,
      peersExpanded: false,
    ));

    // Automatically load sentiment data
    if (_repository != null) {
      add(LoadSentimentData(event.symbol));
    }
  }

  Future<void> _onLoadSentimentData(
    LoadSentimentData event,
    Emitter<SentimentState> emit,
  ) async {
    if (_repository == null) {
      emit(state.copyWith(
        error: 'Sentiment data not available. API key may not be configured.',
      ));
      return;
    }

    final symbol = event.symbol;

    // Check cache first (7 days for profile, 30 seconds for quote)
    final cached = _cache[symbol];
    if (cached != null) {
      final now = DateTime.now();
      final profileAge = now.difference(cached.profileFetchedAt);
      final quoteAge = now.difference(cached.quoteFetchedAt);

      // Profile cache: 7 days, Quote cache: 30 seconds
      if (profileAge.inDays < 7 && quoteAge.inSeconds < 30) {
        emit(state.copyWith(
          profile: cached.profile,
          quote: cached.quote,
          peers: cached.peers,
        ));
        return;
      }
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final data = await _repository.getSentimentData(symbol);

      // Cache the result
      _cache[symbol] = _CachedSentimentData(
        profile: data.profile,
        quote: data.quote,
        peers: data.peers,
        profileFetchedAt: DateTime.now(),
        quoteFetchedAt: DateTime.now(),
      );

      // Only emit if still viewing the same symbol
      if (state.selectedSymbol == symbol) {
        emit(state.copyWith(
          profile: data.profile,
          quote: data.quote,
          peers: data.peers,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  void _onTogglePeers(
    TogglePeers event,
    Emitter<SentimentState> emit,
  ) {
    emit(state.copyWith(peersExpanded: !state.peersExpanded));
  }

  void _onCollapseSentiment(
    CollapseSentiment event,
    Emitter<SentimentState> emit,
  ) {
    emit(state.copyWith(
      clearSelectedSymbol: true,
      clearProfile: true,
      clearQuote: true,
      clearPeers: true,
      peersExpanded: false,
    ));
  }

  void _onClearSentimentError(
    ClearSentimentError event,
    Emitter<SentimentState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  void _onSelectPeer(
    SelectPeer event,
    Emitter<SentimentState> emit,
  ) {
    // Select the peer symbol and load its data
    emit(state.copyWith(
      selectedSymbol: event.peerSymbol,
      clearProfile: true,
      clearQuote: true,
      clearPeers: true,
      peersExpanded: false,
    ));

    if (_repository != null) {
      add(LoadSentimentData(event.peerSymbol));
    }
  }
}

/// Cached sentiment data with timestamps.
class _CachedSentimentData {
  final CompanyProfile profile;
  final StockQuote quote;
  final List<String> peers;
  final DateTime profileFetchedAt;
  final DateTime quoteFetchedAt;

  _CachedSentimentData({
    required this.profile,
    required this.quote,
    required this.peers,
    required this.profileFetchedAt,
    required this.quoteFetchedAt,
  });
}
