import 'package:freezed_annotation/freezed_annotation.dart';

part 'earnings_model.freezed.dart';
part 'earnings_model.g.dart';

/// Model for earnings surprises from Finnhub API
/// Maps Finnhub /stock/earnings response to app model
@freezed
class EarningsModel with _$EarningsModel {
  const factory EarningsModel({
    required double actual,
    required double estimate,
    required String period,
    required double surprise,
  }) = _EarningsModel;

  factory EarningsModel.fromJson(Map<String, dynamic> json) =>
      _$EarningsModelFromJson(json);
}
