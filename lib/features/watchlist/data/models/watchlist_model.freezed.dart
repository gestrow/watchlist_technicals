// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watchlist_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WatchlistModel _$WatchlistModelFromJson(Map<String, dynamic> json) {
  return _WatchlistModel.fromJson(json);
}

/// @nodoc
mixin _$WatchlistModel {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get name => throw _privateConstructorUsedError;
  @HiveField(2)
  List<String> get symbols => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WatchlistModelCopyWith<WatchlistModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchlistModelCopyWith<$Res> {
  factory $WatchlistModelCopyWith(
          WatchlistModel value, $Res Function(WatchlistModel) then) =
      _$WatchlistModelCopyWithImpl<$Res, WatchlistModel>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) List<String> symbols});
}

/// @nodoc
class _$WatchlistModelCopyWithImpl<$Res, $Val extends WatchlistModel>
    implements $WatchlistModelCopyWith<$Res> {
  _$WatchlistModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? symbols = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbols: null == symbols
          ? _value.symbols
          : symbols // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WatchlistModelImplCopyWith<$Res>
    implements $WatchlistModelCopyWith<$Res> {
  factory _$$WatchlistModelImplCopyWith(_$WatchlistModelImpl value,
          $Res Function(_$WatchlistModelImpl) then) =
      __$$WatchlistModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) List<String> symbols});
}

/// @nodoc
class __$$WatchlistModelImplCopyWithImpl<$Res>
    extends _$WatchlistModelCopyWithImpl<$Res, _$WatchlistModelImpl>
    implements _$$WatchlistModelImplCopyWith<$Res> {
  __$$WatchlistModelImplCopyWithImpl(
      _$WatchlistModelImpl _value, $Res Function(_$WatchlistModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? symbols = null,
  }) {
    return _then(_$WatchlistModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbols: null == symbols
          ? _value._symbols
          : symbols // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WatchlistModelImpl extends _WatchlistModel {
  const _$WatchlistModelImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.name,
      @HiveField(2) required final List<String> symbols})
      : _symbols = symbols,
        super._();

  factory _$WatchlistModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WatchlistModelImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  final List<String> _symbols;
  @override
  @HiveField(2)
  List<String> get symbols {
    if (_symbols is EqualUnmodifiableListView) return _symbols;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_symbols);
  }

  @override
  String toString() {
    return 'WatchlistModel(id: $id, name: $name, symbols: $symbols)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchlistModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._symbols, _symbols));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, const DeepCollectionEquality().hash(_symbols));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchlistModelImplCopyWith<_$WatchlistModelImpl> get copyWith =>
      __$$WatchlistModelImplCopyWithImpl<_$WatchlistModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WatchlistModelImplToJson(
      this,
    );
  }
}

abstract class _WatchlistModel extends WatchlistModel {
  const factory _WatchlistModel(
          {@HiveField(0) required final String id,
          @HiveField(1) required final String name,
          @HiveField(2) required final List<String> symbols}) =
      _$WatchlistModelImpl;
  const _WatchlistModel._() : super._();

  factory _WatchlistModel.fromJson(Map<String, dynamic> json) =
      _$WatchlistModelImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get name;
  @override
  @HiveField(2)
  List<String> get symbols;
  @override
  @JsonKey(ignore: true)
  _$$WatchlistModelImplCopyWith<_$WatchlistModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
