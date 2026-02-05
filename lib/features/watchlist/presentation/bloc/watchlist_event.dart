part of 'watchlist_bloc.dart';

/// Base class for all watchlist events.
sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all watchlists from storage.
final class LoadWatchlists extends WatchlistEvent {
  const LoadWatchlists();
}

/// Event to add a new watchlist.
final class AddWatchlist extends WatchlistEvent {
  final String name;
  final List<String> symbols;

  const AddWatchlist({
    required this.name,
    required this.symbols,
  });

  @override
  List<Object?> get props => [name, symbols];
}

/// Event to update an existing watchlist.
final class UpdateWatchlist extends WatchlistEvent {
  final String id;
  final String name;
  final List<String> symbols;

  const UpdateWatchlist({
    required this.id,
    required this.name,
    required this.symbols,
  });

  @override
  List<Object?> get props => [id, name, symbols];
}

/// Event to delete a watchlist.
final class DeleteWatchlist extends WatchlistEvent {
  final String id;

  const DeleteWatchlist(this.id);

  @override
  List<Object?> get props => [id];
}
