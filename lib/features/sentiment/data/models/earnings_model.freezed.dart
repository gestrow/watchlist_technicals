// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EarningsModel _$EarningsModelFromJson(Map<String, dynamic> json) {
  return _EarningsModel.fromJson(json);
}

/// @nodoc
mixin _$EarningsModel {
  double get actual => throw _privateConstructorUsedError;
  double get estimate => throw _privateConstructorUsedError;
  String get period => throw _privateConstructorUsedError;
  double get surprise => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EarningsModelCopyWith<EarningsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EarningsModelCopyWith<$Res> {
  factory $EarningsModelCopyWith(
          EarningsModel value, $Res Function(EarningsModel) then) =
      _$EarningsModelCopyWithImpl<$Res, EarningsModel>;
  @useResult
  $Res call({double actual, double estimate, String period, double surprise});
}

/// @nodoc
class _$EarningsModelCopyWithImpl<$Res, $Val extends EarningsModel>
    implements $EarningsModelCopyWith<$Res> {
  _$EarningsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actual = null,
    Object? estimate = null,
    Object? period = null,
    Object? surprise = null,
  }) {
    return _then(_value.copyWith(
      actual: null == actual
          ? _value.actual
          : actual // ignore: cast_nullable_to_non_nullable
              as double,
      estimate: null == estimate
          ? _value.estimate
          : estimate // ignore: cast_nullable_to_non_nullable
              as double,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      surprise: null == surprise
          ? _value.surprise
          : surprise // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EarningsModelImplCopyWith<$Res>
    implements $EarningsModelCopyWith<$Res> {
  factory _$$EarningsModelImplCopyWith(
          _$EarningsModelImpl value, $Res Function(_$EarningsModelImpl) then) =
      __$$EarningsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double actual, double estimate, String period, double surprise});
}

/// @nodoc
class __$$EarningsModelImplCopyWithImpl<$Res>
    extends _$EarningsModelCopyWithImpl<$Res, _$EarningsModelImpl>
    implements _$$EarningsModelImplCopyWith<$Res> {
  __$$EarningsModelImplCopyWithImpl(
      _$EarningsModelImpl _value, $Res Function(_$EarningsModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actual = null,
    Object? estimate = null,
    Object? period = null,
    Object? surprise = null,
  }) {
    return _then(_$EarningsModelImpl(
      actual: null == actual
          ? _value.actual
          : actual // ignore: cast_nullable_to_non_nullable
              as double,
      estimate: null == estimate
          ? _value.estimate
          : estimate // ignore: cast_nullable_to_non_nullable
              as double,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      surprise: null == surprise
          ? _value.surprise
          : surprise // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EarningsModelImpl implements _EarningsModel {
  const _$EarningsModelImpl(
      {required this.actual,
      required this.estimate,
      required this.period,
      required this.surprise});

  factory _$EarningsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EarningsModelImplFromJson(json);

  @override
  final double actual;
  @override
  final double estimate;
  @override
  final String period;
  @override
  final double surprise;

  @override
  String toString() {
    return 'EarningsModel(actual: $actual, estimate: $estimate, period: $period, surprise: $surprise)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EarningsModelImpl &&
            (identical(other.actual, actual) || other.actual == actual) &&
            (identical(other.estimate, estimate) ||
                other.estimate == estimate) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.surprise, surprise) ||
                other.surprise == surprise));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, actual, estimate, period, surprise);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EarningsModelImplCopyWith<_$EarningsModelImpl> get copyWith =>
      __$$EarningsModelImplCopyWithImpl<_$EarningsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EarningsModelImplToJson(
      this,
    );
  }
}

abstract class _EarningsModel implements EarningsModel {
  const factory _EarningsModel(
      {required final double actual,
      required final double estimate,
      required final String period,
      required final double surprise}) = _$EarningsModelImpl;

  factory _EarningsModel.fromJson(Map<String, dynamic> json) =
      _$EarningsModelImpl.fromJson;

  @override
  double get actual;
  @override
  double get estimate;
  @override
  String get period;
  @override
  double get surprise;
  @override
  @JsonKey(ignore: true)
  _$$EarningsModelImplCopyWith<_$EarningsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
