import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/watchlist.dart';

/// Abstract repository interface for watchlist operations.
///
/// Implements the repository pattern from Clean Architecture,
/// defining the contract for data layer implementations.
abstract class WatchlistRepository {
  /// Retrieves all watchlists from storage.
  ///
  /// Returns [Right] with list of watchlists on success,
  /// or [Left] with [Failure] on error.
  Future<Either<Failure, List<Watchlist>>> getWatchlists();

  /// Creates a new watchlist.
  ///
  /// Returns [Right] with the created watchlist on success,
  /// or [Left] with [Failure] on error.
  Future<Either<Failure, Watchlist>> createWatchlist({
    required String name,
    required List<String> symbols,
  });

  /// Updates an existing watchlist.
  ///
  /// Returns [Right] with the updated watchlist on success,
  /// or [Left] with [Failure] on error.
  Future<Either<Failure, Watchlist>> updateWatchlist(Watchlist watchlist);

  /// Deletes a watchlist by its ID.
  ///
  /// Returns [Right] with [Unit] on success,
  /// or [Left] with [Failure] on error.
  Future<Either<Failure, Unit>> deleteWatchlist(String id);

  /// Gets a single watchlist by ID.
  ///
  /// Returns [Right] with the watchlist on success,
  /// or [Left] with [Failure] if not found or on error.
  Future<Either<Failure, Watchlist>> getWatchlistById(String id);
}
