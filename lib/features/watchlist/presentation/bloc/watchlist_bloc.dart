import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/watchlist.dart';
import '../../domain/repositories/watchlist_repository.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

/// BLoC for managing watchlist state and operations.
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository _repository;

  WatchlistBloc({required WatchlistRepository repository})
      : _repository = repository,
        super(const WatchlistInitial()) {
    on<LoadWatchlists>(_onLoadWatchlists);
    on<AddWatchlist>(_onAddWatchlist);
    on<UpdateWatchlist>(_onUpdateWatchlist);
    on<DeleteWatchlist>(_onDeleteWatchlist);
  }

  Future<void> _onLoadWatchlists(
    LoadWatchlists event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());

    final result = await _repository.getWatchlists();

    result.fold(
      (failure) => emit(WatchlistError(failure.message)),
      (watchlists) => emit(WatchlistLoaded(watchlists)),
    );
  }

  Future<void> _onAddWatchlist(
    AddWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WatchlistLoaded) return;

    final result = await _repository.createWatchlist(
      name: event.name,
      symbols: event.symbols,
    );

    result.fold(
      (failure) => emit(WatchlistError(failure.message)),
      (newWatchlist) {
        final updatedList = [...currentState.watchlists, newWatchlist];
        updatedList.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        emit(WatchlistLoaded(updatedList));
      },
    );
  }

  Future<void> _onUpdateWatchlist(
    UpdateWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WatchlistLoaded) return;

    final watchlist = Watchlist(
      id: event.id,
      name: event.name,
      symbols: event.symbols,
    );

    final result = await _repository.updateWatchlist(watchlist);

    result.fold(
      (failure) => emit(WatchlistError(failure.message)),
      (updatedWatchlist) {
        final updatedList = currentState.watchlists
            .map((w) => w.id == updatedWatchlist.id ? updatedWatchlist : w)
            .toList();
        updatedList.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        emit(WatchlistLoaded(updatedList));
      },
    );
  }

  Future<void> _onDeleteWatchlist(
    DeleteWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WatchlistLoaded) return;

    final result = await _repository.deleteWatchlist(event.id);

    result.fold(
      (failure) => emit(WatchlistError(failure.message)),
      (_) {
        final updatedList =
            currentState.watchlists.where((w) => w.id != event.id).toList();
        emit(WatchlistLoaded(updatedList));
      },
    );
  }
}
