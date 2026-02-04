import 'package:freezed_annotation/freezed_annotation.dart';

part 'ohlc_model.freezed.dart';
part 'ohlc_model.g.dart';

/// Model for OHLC (Open, High, Low, Close) candlestick data
/// Used for technical analysis calculations
@freezed
class OhlcModel with _$OhlcModel {
  const factory OhlcModel({
    required DateTime date,
    required double open,
    required double high,
    required double low,
    required double close,
    required int volume,
  }) = _OhlcModel;

  factory OhlcModel.fromJson(Map<String, dynamic> json) =>
      _$OhlcModelFromJson(json);
}
