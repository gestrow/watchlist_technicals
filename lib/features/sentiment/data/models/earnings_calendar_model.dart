import 'package:freezed_annotation/freezed_annotation.dart';

part 'earnings_calendar_model.freezed.dart';
part 'earnings_calendar_model.g.dart';

/// Model for earnings calendar from Finnhub API
/// Maps Finnhub /calendar/earnings response to app model
@freezed
class EarningsCalendarModel with _$EarningsCalendarModel {
  const factory EarningsCalendarModel({
    required String date,
    required double epsEstimate,
    required String symbol,
  }) = _EarningsCalendarModel;

  factory EarningsCalendarModel.fromJson(Map<String, dynamic> json) =>
      _$EarningsCalendarModelFromJson(json);
}
