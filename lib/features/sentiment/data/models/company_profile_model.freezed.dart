// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CompanyProfileModel _$CompanyProfileModelFromJson(Map<String, dynamic> json) {
  return _CompanyProfileModel.fromJson(json);
}

/// @nodoc
mixin _$CompanyProfileModel {
  String get name => throw _privateConstructorUsedError;
  String get ticker => throw _privateConstructorUsedError;
  String get logo => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'weburl')
  String? get webUrl => throw _privateConstructorUsedError;
  String get industry => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompanyProfileModelCopyWith<CompanyProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyProfileModelCopyWith<$Res> {
  factory $CompanyProfileModelCopyWith(
          CompanyProfileModel value, $Res Function(CompanyProfileModel) then) =
      _$CompanyProfileModelCopyWithImpl<$Res, CompanyProfileModel>;
  @useResult
  $Res call(
      {String name,
      String ticker,
      String logo,
      String description,
      @JsonKey(name: 'weburl') String? webUrl,
      String industry,
      String country});
}

/// @nodoc
class _$CompanyProfileModelCopyWithImpl<$Res, $Val extends CompanyProfileModel>
    implements $CompanyProfileModelCopyWith<$Res> {
  _$CompanyProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? ticker = null,
    Object? logo = null,
    Object? description = null,
    Object? webUrl = freezed,
    Object? industry = null,
    Object? country = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ticker: null == ticker
          ? _value.ticker
          : ticker // ignore: cast_nullable_to_non_nullable
              as String,
      logo: null == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      webUrl: freezed == webUrl
          ? _value.webUrl
          : webUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      industry: null == industry
          ? _value.industry
          : industry // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompanyProfileModelImplCopyWith<$Res>
    implements $CompanyProfileModelCopyWith<$Res> {
  factory _$$CompanyProfileModelImplCopyWith(_$CompanyProfileModelImpl value,
          $Res Function(_$CompanyProfileModelImpl) then) =
      __$$CompanyProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String ticker,
      String logo,
      String description,
      @JsonKey(name: 'weburl') String? webUrl,
      String industry,
      String country});
}

/// @nodoc
class __$$CompanyProfileModelImplCopyWithImpl<$Res>
    extends _$CompanyProfileModelCopyWithImpl<$Res, _$CompanyProfileModelImpl>
    implements _$$CompanyProfileModelImplCopyWith<$Res> {
  __$$CompanyProfileModelImplCopyWithImpl(_$CompanyProfileModelImpl _value,
      $Res Function(_$CompanyProfileModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? ticker = null,
    Object? logo = null,
    Object? description = null,
    Object? webUrl = freezed,
    Object? industry = null,
    Object? country = null,
  }) {
    return _then(_$CompanyProfileModelImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ticker: null == ticker
          ? _value.ticker
          : ticker // ignore: cast_nullable_to_non_nullable
              as String,
      logo: null == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      webUrl: freezed == webUrl
          ? _value.webUrl
          : webUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      industry: null == industry
          ? _value.industry
          : industry // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyProfileModelImpl implements _CompanyProfileModel {
  const _$CompanyProfileModelImpl(
      {required this.name,
      required this.ticker,
      required this.logo,
      required this.description,
      @JsonKey(name: 'weburl') this.webUrl,
      required this.industry,
      required this.country});

  factory _$CompanyProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyProfileModelImplFromJson(json);

  @override
  final String name;
  @override
  final String ticker;
  @override
  final String logo;
  @override
  final String description;
  @override
  @JsonKey(name: 'weburl')
  final String? webUrl;
  @override
  final String industry;
  @override
  final String country;

  @override
  String toString() {
    return 'CompanyProfileModel(name: $name, ticker: $ticker, logo: $logo, description: $description, webUrl: $webUrl, industry: $industry, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyProfileModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ticker, ticker) || other.ticker == ticker) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl) &&
            (identical(other.industry, industry) ||
                other.industry == industry) &&
            (identical(other.country, country) || other.country == country));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, ticker, logo, description, webUrl, industry, country);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyProfileModelImplCopyWith<_$CompanyProfileModelImpl> get copyWith =>
      __$$CompanyProfileModelImplCopyWithImpl<_$CompanyProfileModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyProfileModelImplToJson(
      this,
    );
  }
}

abstract class _CompanyProfileModel implements CompanyProfileModel {
  const factory _CompanyProfileModel(
      {required final String name,
      required final String ticker,
      required final String logo,
      required final String description,
      @JsonKey(name: 'weburl') final String? webUrl,
      required final String industry,
      required final String country}) = _$CompanyProfileModelImpl;

  factory _CompanyProfileModel.fromJson(Map<String, dynamic> json) =
      _$CompanyProfileModelImpl.fromJson;

  @override
  String get name;
  @override
  String get ticker;
  @override
  String get logo;
  @override
  String get description;
  @override
  @JsonKey(name: 'weburl')
  String? get webUrl;
  @override
  String get industry;
  @override
  String get country;
  @override
  @JsonKey(ignore: true)
  _$$CompanyProfileModelImplCopyWith<_$CompanyProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
