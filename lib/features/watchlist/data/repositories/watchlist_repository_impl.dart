import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/watchlist.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../models/watchlist_model.dart';

/// Implementation of [WatchlistRepository] using Hive for local persistence.
class WatchlistRepositoryImpl implements WatchlistRepository {
  final Box<WatchlistModel> _watchlistBox;
  final Uuid _uuid;

  WatchlistRepositoryImpl({
    required Box<WatchlistModel> watchlistBox,
    Uuid? uuid,
  })  : _watchlistBox = watchlistBox,
        _uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, List<Watchlist>>> getWatchlists() async {
    try {
      final models = _watchlistBox.values.toList();
      final watchlists = models.map((m) => m.toEntity()).toList();
      // Sort by name for consistent display
      watchlists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return Right(watchlists);
    } catch (e) {
      return Left(CacheFailure('Failed to load watchlists: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Watchlist>> createWatchlist({
    required String name,
    required List<String> symbols,
  }) async {
    try {
      final id = _uuid.v4();
      final sortedSymbols = List<String>.from(symbols)..sort();

      final model = WatchlistModel(
        id: id,
        name: name.trim(),
        symbols: sortedSymbols,
      );

      await _watchlistBox.put(id, model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to create watchlist: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Watchlist>> updateWatchlist(Watchlist watchlist) async {
    try {
      if (!_watchlistBox.containsKey(watchlist.id)) {
        return Left(CacheFailure('Watchlist not found'));
      }

      final sortedSymbols = List<String>.from(watchlist.symbols)..sort();

      final model = WatchlistModel(
        id: watchlist.id,
        name: watchlist.name.trim(),
        symbols: sortedSymbols,
      );

      await _watchlistBox.put(watchlist.id, model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to update watchlist: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWatchlist(String id) async {
    try {
      if (!_watchlistBox.containsKey(id)) {
        return Left(CacheFailure('Watchlist not found'));
      }

      await _watchlistBox.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete watchlist: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Watchlist>> getWatchlistById(String id) async {
    try {
      final model = _watchlistBox.get(id);
      if (model == null) {
        return Left(CacheFailure('Watchlist not found'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get watchlist: ${e.toString()}'));
    }
  }
}
