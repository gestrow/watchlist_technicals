// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EarningsModelImpl _$$EarningsModelImplFromJson(Map<String, dynamic> json) =>
    _$EarningsModelImpl(
      actual: (json['actual'] as num).toDouble(),
      estimate: (json['estimate'] as num).toDouble(),
      period: json['period'] as String,
      surprise: (json['surprise'] as num).toDouble(),
    );

Map<String, dynamic> _$$EarningsModelImplToJson(_$EarningsModelImpl instance) =>
    <String, dynamic>{
      'actual': instance.actual,
      'estimate': instance.estimate,
      'period': instance.period,
      'surprise': instance.surprise,
    };
