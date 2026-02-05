import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/watchlist.dart';

part 'watchlist_model.freezed.dart';
part 'watchlist_model.g.dart';

/// Data model for Watchlist with Hive persistence support.
///
/// Uses Freezed for immutable data class generation and
/// Hive TypeAdapter for local storage serialization.
@freezed
@HiveType(typeId: 0)
class WatchlistModel with _$WatchlistModel {
  const WatchlistModel._();

  const factory WatchlistModel({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required List<String> symbols,
  }) = _WatchlistModel;

  /// Creates a model from JSON.
  factory WatchlistModel.fromJson(Map<String, dynamic> json) =>
      _$WatchlistModelFromJson(json);

  /// Creates a model from domain entity.
  factory WatchlistModel.fromEntity(Watchlist entity) {
    return WatchlistModel(
      id: entity.id,
      name: entity.name,
      symbols: entity.symbols,
    );
  }

  /// Converts this model to domain entity.
  Watchlist toEntity() {
    return Watchlist(
      id: id,
      name: name,
      symbols: List.unmodifiable(symbols),
    );
  }
}
