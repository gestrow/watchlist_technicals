import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../watchlist/domain/entities/watchlist.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/entities/earnings.dart';
import '../../domain/entities/earnings_calendar_entry.dart';
import '../../domain/entities/news_article.dart';
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
    on<ToggleNews>(_onToggleNews);
    on<ToggleNewsItem>(_onToggleNewsItem);
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
      clearNews: true,
      newsExpanded: false,
      clearExpandedNewsIndex: true,
      clearEarningsSurprises: true,
      clearEarningsCalendar: true,
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

    // Check cache first
    // Profile: 7 days, Quote: 30 seconds, News: 4 hours, Earnings: 24 hours
    final cached = _cache[symbol];
    if (cached != null) {
      final now = DateTime.now();
      final profileAge = now.difference(cached.profileFetchedAt);
      final quoteAge = now.difference(cached.quoteFetchedAt);
      final newsAge = now.difference(cached.newsFetchedAt);
      final earningsAge = now.difference(cached.earningsFetchedAt);

      final profileValid = profileAge.inDays < 7;
      final quoteValid = quoteAge.inSeconds < 30;
      final newsValid = newsAge.inHours < 4;
      final earningsValid = earningsAge.inHours < 24;

      if (profileValid && quoteValid && newsValid && earningsValid) {
        emit(state.copyWith(
          profile: cached.profile,
          quote: cached.quote,
          peers: cached.peers,
          news: cached.news,
          earningsSurprises: cached.earningsSurprises,
          earningsCalendar: cached.earningsCalendar,
        ));
        return;
      }
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final data = await _repository.getSentimentData(symbol);
      final now = DateTime.now();

      // Cache the result
      _cache[symbol] = _CachedSentimentData(
        profile: data.profile,
        quote: data.quote,
        peers: data.peers,
        news: data.news,
        earningsSurprises: data.earningsSurprises,
        earningsCalendar: data.earningsCalendar,
        profileFetchedAt: now,
        quoteFetchedAt: now,
        newsFetchedAt: now,
        earningsFetchedAt: now,
      );

      // Only emit if still viewing the same symbol
      if (state.selectedSymbol == symbol) {
        emit(state.copyWith(
          profile: data.profile,
          quote: data.quote,
          peers: data.peers,
          news: data.news,
          earningsSurprises: data.earningsSurprises,
          earningsCalendar: data.earningsCalendar,
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
      clearNews: true,
      newsExpanded: false,
      clearExpandedNewsIndex: true,
      clearEarningsSurprises: true,
      clearEarningsCalendar: true,
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
      clearNews: true,
      newsExpanded: false,
      clearExpandedNewsIndex: true,
      clearEarningsSurprises: true,
      clearEarningsCalendar: true,
    ));

    if (_repository != null) {
      add(LoadSentimentData(event.peerSymbol));
    }
  }

  void _onToggleNews(
    ToggleNews event,
    Emitter<SentimentState> emit,
  ) {
    emit(state.copyWith(newsExpanded: !state.newsExpanded));
  }

  void _onToggleNewsItem(
    ToggleNewsItem event,
    Emitter<SentimentState> emit,
  ) {
    // Toggle expansion: if same index, collapse; otherwise expand new index
    if (state.expandedNewsIndex == event.index) {
      emit(state.copyWith(clearExpandedNewsIndex: true));
    } else {
      emit(state.copyWith(expandedNewsIndex: event.index));
    }
  }
}

/// Cached sentiment data with timestamps.
class _CachedSentimentData {
  final CompanyProfile profile;
  final StockQuote quote;
  final List<String> peers;
  final List<NewsArticle> news;
  final List<Earnings> earningsSurprises;
  final List<EarningsCalendarEntry> earningsCalendar;
  final DateTime profileFetchedAt;
  final DateTime quoteFetchedAt;
  final DateTime newsFetchedAt;
  final DateTime earningsFetchedAt;

  _CachedSentimentData({
    required this.profile,
    required this.quote,
    required this.peers,
    required this.news,
    required this.earningsSurprises,
    required this.earningsCalendar,
    required this.profileFetchedAt,
    required this.quoteFetchedAt,
    required this.newsFetchedAt,
    required this.earningsFetchedAt,
  });
}
