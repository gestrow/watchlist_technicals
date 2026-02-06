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
        isLoading,
        error,
      ];
}
