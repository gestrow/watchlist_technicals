// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompanyProfileModelImpl _$$CompanyProfileModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CompanyProfileModelImpl(
      name: json['name'] as String,
      ticker: json['ticker'] as String,
      logo: json['logo'] as String,
      description: json['description'] as String,
      webUrl: json['weburl'] as String?,
      industry: json['industry'] as String,
      country: json['country'] as String,
    );

Map<String, dynamic> _$$CompanyProfileModelImplToJson(
        _$CompanyProfileModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'ticker': instance.ticker,
      'logo': instance.logo,
      'description': instance.description,
      'weburl': instance.webUrl,
      'industry': instance.industry,
      'country': instance.country,
    };
