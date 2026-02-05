import 'package:equatable/equatable.dart';

/// Domain entity representing a watchlist of stock symbols.
///
/// Symbols are always stored in uppercase and sorted alphabetically.
class Watchlist extends Equatable {
  final String id;
  final String name;
  final List<String> symbols;

  const Watchlist({
    required this.id,
    required this.name,
    required this.symbols,
  });

  /// Creates a copy of this watchlist with the given fields replaced.
  Watchlist copyWith({
    String? id,
    String? name,
    List<String>? symbols,
  }) {
    return Watchlist(
      id: id ?? this.id,
      name: name ?? this.name,
      symbols: symbols ?? this.symbols,
    );
  }

  /// Parses a raw symbol string (comma/space separated) into a clean list.
  ///
  /// - Splits by commas and spaces
  /// - Removes empty entries
  /// - Converts to uppercase
  /// - Sorts alphabetically
  /// - Removes duplicates
  static List<String> parseSymbols(String input) {
    final symbols = input
        .split(RegExp(r'[,\s]+'))
        .map((s) => s.trim().toUpperCase())
        .where((s) => s.isNotEmpty && RegExp(r'^[A-Z]+$').hasMatch(s))
        .toSet()
        .toList();
    symbols.sort();
    return symbols;
  }

  @override
  List<Object?> get props => [id, name, symbols];
}
