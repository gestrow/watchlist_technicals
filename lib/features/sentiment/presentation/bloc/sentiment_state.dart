part of 'sentiment_bloc.dart';

/// State for the sentiment page.
class SentimentState extends Equatable {
  final List<Watchlist> availableWatchlists;
  final Watchlist? selectedWatchlist;
  final String? selectedSymbol;
  final CompanyProfile? profile;
  final StockQuote? quote;
  final List<String>? peers;
  final bool peersExpanded;
  final List<NewsArticle>? news;
  final bool newsExpanded;
  final int? expandedNewsIndex;
  final List<Earnings>? earningsSurprises;
  final List<EarningsCalendarEntry>? earningsCalendar;
  final bool isLoading;
  final String? error;

  const SentimentState({
    required this.availableWatchlists,
    this.selectedWatchlist,
    this.selectedSymbol,
    this.profile,
    this.quote,
    this.peers,
    this.peersExpanded = false,
    this.news,
    this.newsExpanded = false,
    this.expandedNewsIndex,
    this.earningsSurprises,
    this.earningsCalendar,
    this.isLoading = false,
    this.error,
  });

  /// Creates the initial state.
  factory SentimentState.initial() {
    return const SentimentState(
      availableWatchlists: [],
      selectedWatchlist: null,
      selectedSymbol: null,
      profile: null,
      quote: null,
      peers: null,
      peersExpanded: false,
      news: null,
      newsExpanded: false,
      expandedNewsIndex: null,
      earningsSurprises: null,
      earningsCalendar: null,
      isLoading: false,
      error: null,
    );
  }

  /// Returns true if a symbol is selected (expanded view).
  bool get isExpanded => selectedSymbol != null;

  /// Returns the symbols from the selected watchlist, sorted Z to A.
  List<String> get sortedSymbols {
    if (selectedWatchlist == null) return [];
    final symbols = List<String>.from(selectedWatchlist!.symbols);
    symbols.sort((a, b) => b.compareTo(a));
    return symbols;
  }

  /// Calculates average sentiment score from news articles.
  double get averageSentiment {
    if (news == null || news!.isEmpty) return 0.0;
    final sum = news!.fold<double>(0, (acc, n) => acc + n.sentimentScore);
    return sum / news!.length;
  }

  /// Returns true if sentiment is positive (> 0.2).
  bool get isSentimentPositive => averageSentiment > 0.2;

  /// Returns true if sentiment is negative (< -0.2).
  bool get isSentimentNegative => averageSentiment < -0.2;

  /// Returns true if there are any upcoming earnings in the calendar.
  bool get hasUpcomingEarnings =>
      earningsCalendar != null && earningsCalendar!.isNotEmpty;

  /// Returns true if there's an earnings date within 7 days.
  bool get hasNearEarnings =>
      earningsCalendar != null && earningsCalendar!.any((e) => e.isNear);

  /// Creates a copy with updated fields.
  SentimentState copyWith({
    List<Watchlist>? availableWatchlists,
    Watchlist? selectedWatchlist,
    String? selectedSymbol,
    bool clearSelectedSymbol = false,
    CompanyProfile? profile,
    bool clearProfile = false,
    StockQuote? quote,
    bool clearQuote = false,
    List<String>? peers,
    bool clearPeers = false,
    bool? peersExpanded,
    List<NewsArticle>? news,
    bool clearNews = false,
    bool? newsExpanded,
    int? expandedNewsIndex,
    bool clearExpandedNewsIndex = false,
    List<Earnings>? earningsSurprises,
    bool clearEarningsSurprises = false,
    List<EarningsCalendarEntry>? earningsCalendar,
    bool clearEarningsCalendar = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SentimentState(
      availableWatchlists: availableWatchlists ?? this.availableWatchlists,
      selectedWatchlist: selectedWatchlist ?? this.selectedWatchlist,
      selectedSymbol: clearSelectedSymbol
          ? null
          : (selectedSymbol ?? this.selectedSymbol),
      profile: clearProfile ? null : (profile ?? this.profile),
      quote: clearQuote ? null : (quote ?? this.quote),
      peers: clearPeers ? null : (peers ?? this.peers),
      peersExpanded: peersExpanded ?? this.peersExpanded,
      news: clearNews ? null : (news ?? this.news),
      newsExpanded: newsExpanded ?? this.newsExpanded,
      expandedNewsIndex: clearExpandedNewsIndex
          ? null
          : (expandedNewsIndex ?? this.expandedNewsIndex),
      earningsSurprises: clearEarningsSurprises
          ? null
          : (earningsSurprises ?? this.earningsSurprises),
      earningsCalendar: clearEarningsCalendar
          ? null
          : (earningsCalendar ?? this.earningsCalendar),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        availableWatchlists,
        selectedWatchlist,
        selectedSymbol,
        profile,
        quote,
        peers,
        peersExpanded,
        news,
        newsExpanded,
        expandedNewsIndex,
        earningsSurprises,
        earningsCalendar,
        isLoading,
        error,
      ];
}
