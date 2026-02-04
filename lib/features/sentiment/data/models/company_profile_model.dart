import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_profile_model.freezed.dart';
part 'company_profile_model.g.dart';

/// Model for company profile from Finnhub API
/// Maps Finnhub /stock/profile2 response to app model
@freezed
class CompanyProfileModel with _$CompanyProfileModel {
  const factory CompanyProfileModel({
    required String name,
    required String ticker,
    required String logo,
    required String description,
    @JsonKey(name: 'weburl') String? webUrl,
    required String industry,
    required String country,
  }) = _CompanyProfileModel;

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyProfileModelFromJson(json);
}
