import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_model.freezed.dart';
part 'quote_model.g.dart';

/// Model for stock quote from Finnhub API
/// Maps Finnhub /quote response to app model
@freezed
class QuoteModel with _$QuoteModel {
  const factory QuoteModel({
    @JsonKey(name: 'c') required double current,
    @JsonKey(name: 'h') required double high,
    @JsonKey(name: 'l') required double low,
    @JsonKey(name: 'o') required double open,
    @JsonKey(name: 'pc') required double previousClose,
    @JsonKey(name: 'd') required double change,
    @JsonKey(name: 'dp') required double percentChange,
  }) = _QuoteModel;

  factory QuoteModel.fromJson(Map<String, dynamic> json) =>
      _$QuoteModelFromJson(json);
}
