// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_calendar_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EarningsCalendarModel _$EarningsCalendarModelFromJson(
    Map<String, dynamic> json) {
  return _EarningsCalendarModel.fromJson(json);
}

/// @nodoc
mixin _$EarningsCalendarModel {
  String get date => throw _privateConstructorUsedError;
  double get epsEstimate => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EarningsCalendarModelCopyWith<EarningsCalendarModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EarningsCalendarModelCopyWith<$Res> {
  factory $EarningsCalendarModelCopyWith(EarningsCalendarModel value,
          $Res Function(EarningsCalendarModel) then) =
      _$EarningsCalendarModelCopyWithImpl<$Res, EarningsCalendarModel>;
  @useResult
  $Res call({String date, double epsEstimate, String symbol});
}

/// @nodoc
class _$EarningsCalendarModelCopyWithImpl<$Res,
        $Val extends EarningsCalendarModel>
    implements $EarningsCalendarModelCopyWith<$Res> {
  _$EarningsCalendarModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? epsEstimate = null,
    Object? symbol = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      epsEstimate: null == epsEstimate
          ? _value.epsEstimate
          : epsEstimate // ignore: cast_nullable_to_non_nullable
              as double,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EarningsCalendarModelImplCopyWith<$Res>
    implements $EarningsCalendarModelCopyWith<$Res> {
  factory _$$EarningsCalendarModelImplCopyWith(
          _$EarningsCalendarModelImpl value,
          $Res Function(_$EarningsCalendarModelImpl) then) =
      __$$EarningsCalendarModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, double epsEstimate, String symbol});
}

/// @nodoc
class __$$EarningsCalendarModelImplCopyWithImpl<$Res>
    extends _$EarningsCalendarModelCopyWithImpl<$Res,
        _$EarningsCalendarModelImpl>
    implements _$$EarningsCalendarModelImplCopyWith<$Res> {
  __$$EarningsCalendarModelImplCopyWithImpl(_$EarningsCalendarModelImpl _value,
      $Res Function(_$EarningsCalendarModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? epsEstimate = null,
    Object? symbol = null,
  }) {
    return _then(_$EarningsCalendarModelImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      epsEstimate: null == epsEstimate
          ? _value.epsEstimate
          : epsEstimate // ignore: cast_nullable_to_non_nullable
              as double,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EarningsCalendarModelImpl implements _EarningsCalendarModel {
  const _$EarningsCalendarModelImpl(
      {required this.date, required this.epsEstimate, required this.symbol});

  factory _$EarningsCalendarModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EarningsCalendarModelImplFromJson(json);

  @override
  final String date;
  @override
  final double epsEstimate;
  @override
  final String symbol;

  @override
  String toString() {
    return 'EarningsCalendarModel(date: $date, epsEstimate: $epsEstimate, symbol: $symbol)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EarningsCalendarModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.epsEstimate, epsEstimate) ||
                other.epsEstimate == epsEstimate) &&
            (identical(other.symbol, symbol) || other.symbol == symbol));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, epsEstimate, symbol);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EarningsCalendarModelImplCopyWith<_$EarningsCalendarModelImpl>
      get copyWith => __$$EarningsCalendarModelImplCopyWithImpl<
          _$EarningsCalendarModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EarningsCalendarModelImplToJson(
      this,
    );
  }
}

abstract class _EarningsCalendarModel implements EarningsCalendarModel {
  const factory _EarningsCalendarModel(
      {required final String date,
      required final double epsEstimate,
      required final String symbol}) = _$EarningsCalendarModelImpl;

  factory _EarningsCalendarModel.fromJson(Map<String, dynamic> json) =
      _$EarningsCalendarModelImpl.fromJson;

  @override
  String get date;
  @override
  double get epsEstimate;
  @override
  String get symbol;
  @override
  @JsonKey(ignore: true)
  _$$EarningsCalendarModelImplCopyWith<_$EarningsCalendarModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
