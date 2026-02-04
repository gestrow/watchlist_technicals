// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ohlc_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OhlcModel _$OhlcModelFromJson(Map<String, dynamic> json) {
  return _OhlcModel.fromJson(json);
}

/// @nodoc
mixin _$OhlcModel {
  DateTime get date => throw _privateConstructorUsedError;
  double get open => throw _privateConstructorUsedError;
  double get high => throw _privateConstructorUsedError;
  double get low => throw _privateConstructorUsedError;
  double get close => throw _privateConstructorUsedError;
  int get volume => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OhlcModelCopyWith<OhlcModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OhlcModelCopyWith<$Res> {
  factory $OhlcModelCopyWith(OhlcModel value, $Res Function(OhlcModel) then) =
      _$OhlcModelCopyWithImpl<$Res, OhlcModel>;
  @useResult
  $Res call(
      {DateTime date,
      double open,
      double high,
      double low,
      double close,
      int volume});
}

/// @nodoc
class _$OhlcModelCopyWithImpl<$Res, $Val extends OhlcModel>
    implements $OhlcModelCopyWith<$Res> {
  _$OhlcModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? open = null,
    Object? high = null,
    Object? low = null,
    Object? close = null,
    Object? volume = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as double,
      high: null == high
          ? _value.high
          : high // ignore: cast_nullable_to_non_nullable
              as double,
      low: null == low
          ? _value.low
          : low // ignore: cast_nullable_to_non_nullable
              as double,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as double,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OhlcModelImplCopyWith<$Res>
    implements $OhlcModelCopyWith<$Res> {
  factory _$$OhlcModelImplCopyWith(
          _$OhlcModelImpl value, $Res Function(_$OhlcModelImpl) then) =
      __$$OhlcModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      double open,
      double high,
      double low,
      double close,
      int volume});
}

/// @nodoc
class __$$OhlcModelImplCopyWithImpl<$Res>
    extends _$OhlcModelCopyWithImpl<$Res, _$OhlcModelImpl>
    implements _$$OhlcModelImplCopyWith<$Res> {
  __$$OhlcModelImplCopyWithImpl(
      _$OhlcModelImpl _value, $Res Function(_$OhlcModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? open = null,
    Object? high = null,
    Object? low = null,
    Object? close = null,
    Object? volume = null,
  }) {
    return _then(_$OhlcModelImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as double,
      high: null == high
          ? _value.high
          : high // ignore: cast_nullable_to_non_nullable
              as double,
      low: null == low
          ? _value.low
          : low // ignore: cast_nullable_to_non_nullable
              as double,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as double,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OhlcModelImpl implements _OhlcModel {
  const _$OhlcModelImpl(
      {required this.date,
      required this.open,
      required this.high,
      required this.low,
      required this.close,
      required this.volume});

  factory _$OhlcModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OhlcModelImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double open;
  @override
  final double high;
  @override
  final double low;
  @override
  final double close;
  @override
  final int volume;

  @override
  String toString() {
    return 'OhlcModel(date: $date, open: $open, high: $high, low: $low, close: $close, volume: $volume)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OhlcModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.open, open) || other.open == open) &&
            (identical(other.high, high) || other.high == high) &&
            (identical(other.low, low) || other.low == low) &&
            (identical(other.close, close) || other.close == close) &&
            (identical(other.volume, volume) || other.volume == volume));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, open, high, low, close, volume);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OhlcModelImplCopyWith<_$OhlcModelImpl> get copyWith =>
      __$$OhlcModelImplCopyWithImpl<_$OhlcModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OhlcModelImplToJson(
      this,
    );
  }
}

abstract class _OhlcModel implements OhlcModel {
  const factory _OhlcModel(
      {required final DateTime date,
      required final double open,
      required final double high,
      required final double low,
      required final double close,
      required final int volume}) = _$OhlcModelImpl;

  factory _OhlcModel.fromJson(Map<String, dynamic> json) =
      _$OhlcModelImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get open;
  @override
  double get high;
  @override
  double get low;
  @override
  double get close;
  @override
  int get volume;
  @override
  @JsonKey(ignore: true)
  _$$OhlcModelImplCopyWith<_$OhlcModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
