// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ohlc_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OhlcModelImpl _$$OhlcModelImplFromJson(Map<String, dynamic> json) =>
    _$OhlcModelImpl(
      date: DateTime.parse(json['date'] as String),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toInt(),
    );

Map<String, dynamic> _$$OhlcModelImplToJson(_$OhlcModelImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'volume': instance.volume,
    };
