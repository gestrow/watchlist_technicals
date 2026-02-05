part of 'watchlist_bloc.dart';

/// Base class for all watchlist states.
sealed class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
final class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

/// State while watchlists are being loaded.
final class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

/// State when watchlists are successfully loaded.
final class WatchlistLoaded extends WatchlistState {
  final List<Watchlist> watchlists;

  const WatchlistLoaded(this.watchlists);

  @override
  List<Object?> get props => [watchlists];

  /// Returns true if there are no watchlists.
  bool get isEmpty => watchlists.isEmpty;
}

/// State when an error occurs.
final class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError(this.message);

  @override
  List<Object?> get props => [message];
}
