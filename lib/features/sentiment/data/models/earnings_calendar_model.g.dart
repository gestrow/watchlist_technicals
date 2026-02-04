// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_calendar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EarningsCalendarModelImpl _$$EarningsCalendarModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EarningsCalendarModelImpl(
      date: json['date'] as String,
      epsEstimate: (json['epsEstimate'] as num).toDouble(),
      symbol: json['symbol'] as String,
    );

Map<String, dynamic> _$$EarningsCalendarModelImplToJson(
        _$EarningsCalendarModelImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'epsEstimate': instance.epsEstimate,
      'symbol': instance.symbol,
    };
