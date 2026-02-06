import 'package:equatable/equatable.dart';

import '../../data/models/company_profile_model.dart';

/// Domain entity for company profile information.
class CompanyProfile extends Equatable {
  final String name;
  final String ticker;
  final String logo;
  final String description;
  final String? webUrl;
  final String industry;
  final String country;

  const CompanyProfile({
    required this.name,
    required this.ticker,
    required this.logo,
    required this.description,
    this.webUrl,
    required this.industry,
    required this.country,
  });

  /// Creates a domain entity from the data model.
  factory CompanyProfile.fromModel(CompanyProfileModel model) {
    return CompanyProfile(
      name: model.name,
      ticker: model.ticker,
      logo: model.logo,
      description: model.description,
      webUrl: model.webUrl,
      industry: model.industry,
      country: model.country,
    );
  }

  /// Returns true if the profile has a valid logo URL.
  bool get hasLogo => logo.isNotEmpty;

  /// Returns true if the profile has a website URL.
  bool get hasWebsite => webUrl != null && webUrl!.isNotEmpty;

  /// Returns a truncated description for preview.
  String get shortDescription {
    if (description.length <= 200) return description;
    return '${description.substring(0, 197)}...';
  }

  @override
  List<Object?> get props => [
        name,
        ticker,
        logo,
        description,
        webUrl,
        industry,
        country,
      ];
}
