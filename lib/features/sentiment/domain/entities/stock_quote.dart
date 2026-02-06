import 'package:equatable/equatable.dart';

import '../../data/models/quote_model.dart';

/// Domain entity for stock quote information.
class StockQuote extends Equatable {
  final double currentPrice;
  final double highPrice;
  final double lowPrice;
  final double openPrice;
  final double previousClose;
  final double change;
  final double percentChange;

  const StockQuote({
    required this.currentPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.openPrice,
    required this.previousClose,
    required this.change,
    required this.percentChange,
  });

  /// Creates a domain entity from the data model.
  factory StockQuote.fromModel(QuoteModel model) {
    return StockQuote(
      currentPrice: model.current,
      highPrice: model.high,
      lowPrice: model.low,
      openPrice: model.open,
      previousClose: model.previousClose,
      change: model.change,
      percentChange: model.percentChange,
    );
  }

  /// Returns true if the price has increased.
  bool get isPositive => change >= 0;

  /// Returns true if the price has decreased.
  bool get isNegative => change < 0;

  /// Returns the formatted price string.
  String get formattedPrice => '\$${currentPrice.toStringAsFixed(2)}';

  /// Returns the formatted change string with sign.
  String get formattedChange {
    final sign = isPositive ? '+' : '';
    return '$sign${change.toStringAsFixed(2)}';
  }

  /// Returns the formatted percent change string with sign.
  String get formattedPercentChange {
    final sign = isPositive ? '+' : '';
    return '$sign${percentChange.toStringAsFixed(2)}%';
  }

  /// Returns the full formatted change string (e.g., "+1.25 (+0.85%)").
  String get formattedFullChange {
    return '$formattedChange ($formattedPercentChange)';
  }

  @override
  List<Object?> get props => [
        currentPrice,
        highPrice,
        lowPrice,
        openPrice,
        previousClose,
        change,
        percentChange,
      ];
}
