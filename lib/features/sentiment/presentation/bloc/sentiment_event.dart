part of 'sentiment_bloc.dart';

/// Base class for sentiment events.
sealed class SentimentEvent extends Equatable {
  const SentimentEvent();

  @override
  List<Object?> get props => [];
}

/// Updates the list of available watchlists.
final class UpdateAvailableWatchlists extends SentimentEvent {
  final List<Watchlist> watchlists;

  const UpdateAvailableWatchlists(this.watchlists);

  @override
  List<Object?> get props => [watchlists];
}

/// Selects a watchlist to display symbols from.
final class SelectWatchlist extends SentimentEvent {
  final Watchlist watchlist;

  const SelectWatchlist(this.watchlist);

  @override
  List<Object?> get props => [watchlist];
}

/// Selects a symbol to view detailed sentiment data.
final class SelectSymbol extends SentimentEvent {
  final String symbol;

  const SelectSymbol(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Loads sentiment data for a symbol.
final class LoadSentimentData extends SentimentEvent {
  final String symbol;

  const LoadSentimentData(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Toggles the peers list expansion state.
final class TogglePeers extends SentimentEvent {
  const TogglePeers();
}

/// Collapses the expanded sentiment view.
final class CollapseSentiment extends SentimentEvent {
  const CollapseSentiment();
}

/// Clears any sentiment error.
final class ClearSentimentError extends SentimentEvent {
  const ClearSentimentError();
}

/// Selects a peer symbol to view.
final class SelectPeer extends SentimentEvent {
  final String peerSymbol;

  const SelectPeer(this.peerSymbol);

  @override
  List<Object?> get props => [peerSymbol];
}

/// Toggles the news section expansion state.
final class ToggleNews extends SentimentEvent {
  const ToggleNews();
}

/// Toggles a specific news item expansion.
final class ToggleNewsItem extends SentimentEvent {
  final int index;

  const ToggleNewsItem(this.index);

  @override
  List<Object?> get props => [index];
}
