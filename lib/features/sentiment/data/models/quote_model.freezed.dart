// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quote_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QuoteModel _$QuoteModelFromJson(Map<String, dynamic> json) {
  return _QuoteModel.fromJson(json);
}

/// @nodoc
mixin _$QuoteModel {
  @JsonKey(name: 'c')
  double get current => throw _privateConstructorUsedError;
  @JsonKey(name: 'h')
  double get high => throw _privateConstructorUsedError;
  @JsonKey(name: 'l')
  double get low => throw _privateConstructorUsedError;
  @JsonKey(name: 'o')
  double get open => throw _privateConstructorUsedError;
  @JsonKey(name: 'pc')
  double get previousClose => throw _privateConstructorUsedError;
  @JsonKey(name: 'd')
  double get change => throw _privateConstructorUsedError;
  @JsonKey(name: 'dp')
  double get percentChange => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuoteModelCopyWith<QuoteModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuoteModelCopyWith<$Res> {
  factory $QuoteModelCopyWith(
          QuoteModel value, $Res Function(QuoteModel) then) =
      _$QuoteModelCopyWithImpl<$Res, QuoteModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'c') double current,
      @JsonKey(name: 'h') double high,
      @JsonKey(name: 'l') double low,
      @JsonKey(name: 'o') double open,
      @JsonKey(name: 'pc') double previousClose,
      @JsonKey(name: 'd') double change,
      @JsonKey(name: 'dp') double percentChange});
}

/// @nodoc
class _$QuoteModelCopyWithImpl<$Res, $Val extends QuoteModel>
    implements $QuoteModelCopyWith<$Res> {
  _$QuoteModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? high = null,
    Object? low = null,
    Object? open = null,
    Object? previousClose = null,
    Object? change = null,
    Object? percentChange = null,
  }) {
    return _then(_value.copyWith(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as double,
      high: null == high
          ? _value.high
          : high // ignore: cast_nullable_to_non_nullable
              as double,
      low: null == low
          ? _value.low
          : low // ignore: cast_nullable_to_non_nullable
              as double,
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as double,
      previousClose: null == previousClose
          ? _value.previousClose
          : previousClose // ignore: cast_nullable_to_non_nullable
              as double,
      change: null == change
          ? _value.change
          : change // ignore: cast_nullable_to_non_nullable
              as double,
      percentChange: null == percentChange
          ? _value.percentChange
          : percentChange // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuoteModelImplCopyWith<$Res>
    implements $QuoteModelCopyWith<$Res> {
  factory _$$QuoteModelImplCopyWith(
          _$QuoteModelImpl value, $Res Function(_$QuoteModelImpl) then) =
      __$$QuoteModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'c') double current,
      @JsonKey(name: 'h') double high,
      @JsonKey(name: 'l') double low,
      @JsonKey(name: 'o') double open,
      @JsonKey(name: 'pc') double previousClose,
      @JsonKey(name: 'd') double change,
      @JsonKey(name: 'dp') double percentChange});
}

/// @nodoc
class __$$QuoteModelImplCopyWithImpl<$Res>
    extends _$QuoteModelCopyWithImpl<$Res, _$QuoteModelImpl>
    implements _$$QuoteModelImplCopyWith<$Res> {
  __$$QuoteModelImplCopyWithImpl(
      _$QuoteModelImpl _value, $Res Function(_$QuoteModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? high = null,
    Object? low = null,
    Object? open = null,
    Object? previousClose = null,
    Object? change = null,
    Object? percentChange = null,
  }) {
    return _then(_$QuoteModelImpl(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as double,
      high: null == high
          ? _value.high
          : high // ignore: cast_nullable_to_non_nullable
              as double,
      low: null == low
          ? _value.low
          : low // ignore: cast_nullable_to_non_nullable
              as double,
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as double,
      previousClose: null == previousClose
          ? _value.previousClose
          : previousClose // ignore: cast_nullable_to_non_nullable
              as double,
      change: null == change
          ? _value.change
          : change // ignore: cast_nullable_to_non_nullable
              as double,
      percentChange: null == percentChange
          ? _value.percentChange
          : percentChange // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuoteModelImpl implements _QuoteModel {
  const _$QuoteModelImpl(
      {@JsonKey(name: 'c') required this.current,
      @JsonKey(name: 'h') required this.high,
      @JsonKey(name: 'l') required this.low,
      @JsonKey(name: 'o') required this.open,
      @JsonKey(name: 'pc') required this.previousClose,
      @JsonKey(name: 'd') required this.change,
      @JsonKey(name: 'dp') required this.percentChange});

  factory _$QuoteModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteModelImplFromJson(json);

  @override
  @JsonKey(name: 'c')
  final double current;
  @override
  @JsonKey(name: 'h')
  final double high;
  @override
  @JsonKey(name: 'l')
  final double low;
  @override
  @JsonKey(name: 'o')
  final double open;
  @override
  @JsonKey(name: 'pc')
  final double previousClose;
  @override
  @JsonKey(name: 'd')
  final double change;
  @override
  @JsonKey(name: 'dp')
  final double percentChange;

  @override
  String toString() {
    return 'QuoteModel(current: $current, high: $high, low: $low, open: $open, previousClose: $previousClose, change: $change, percentChange: $percentChange)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteModelImpl &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.high, high) || other.high == high) &&
            (identical(other.low, low) || other.low == low) &&
            (identical(other.open, open) || other.open == open) &&
            (identical(other.previousClose, previousClose) ||
                other.previousClose == previousClose) &&
            (identical(other.change, change) || other.change == change) &&
            (identical(other.percentChange, percentChange) ||
                other.percentChange == percentChange));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, current, high, low, open,
      previousClose, change, percentChange);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteModelImplCopyWith<_$QuoteModelImpl> get copyWith =>
      __$$QuoteModelImplCopyWithImpl<_$QuoteModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteModelImplToJson(
      this,
    );
  }
}

abstract class _QuoteModel implements QuoteModel {
  const factory _QuoteModel(
          {@JsonKey(name: 'c') required final double current,
          @JsonKey(name: 'h') required final double high,
          @JsonKey(name: 'l') required final double low,
          @JsonKey(name: 'o') required final double open,
          @JsonKey(name: 'pc') required final double previousClose,
          @JsonKey(name: 'd') required final double change,
          @JsonKey(name: 'dp') required final double percentChange}) =
      _$QuoteModelImpl;

  factory _QuoteModel.fromJson(Map<String, dynamic> json) =
      _$QuoteModelImpl.fromJson;

  @override
  @JsonKey(name: 'c')
  double get current;
  @override
  @JsonKey(name: 'h')
  double get high;
  @override
  @JsonKey(name: 'l')
  double get low;
  @override
  @JsonKey(name: 'o')
  double get open;
  @override
  @JsonKey(name: 'pc')
  double get previousClose;
  @override
  @JsonKey(name: 'd')
  double get change;
  @override
  @JsonKey(name: 'dp')
  double get percentChange;
  @override
  @JsonKey(ignore: true)
  _$$QuoteModelImplCopyWith<_$QuoteModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
