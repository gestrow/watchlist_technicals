// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuoteModelImpl _$$QuoteModelImplFromJson(Map<String, dynamic> json) =>
    _$QuoteModelImpl(
      current: (json['c'] as num).toDouble(),
      high: (json['h'] as num).toDouble(),
      low: (json['l'] as num).toDouble(),
      open: (json['o'] as num).toDouble(),
      previousClose: (json['pc'] as num).toDouble(),
      change: (json['d'] as num).toDouble(),
      percentChange: (json['dp'] as num).toDouble(),
    );

Map<String, dynamic> _$$QuoteModelImplToJson(_$QuoteModelImpl instance) =>
    <String, dynamic>{
      'c': instance.current,
      'h': instance.high,
      'l': instance.low,
      'o': instance.open,
      'pc': instance.previousClose,
      'd': instance.change,
      'dp': instance.percentChange,
    };
