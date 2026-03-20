part of 'settings_bloc.dart';

/// Validation status for API key testing
enum ValidationStatus {
  idle,
  validating,
  success,
  failure,
}

/// Settings state
class SettingsState extends Equatable {
  final bool isLoading;
  final bool finnhubConfigured;
  final bool marketauxConfigured;
  final bool alphaVantageConfigured;
  final ValidationStatus validationStatus;
  final String? validationMessage;
  final ApiProvider? validatingProvider;
  final String? error;
  final bool useAvForTechnicals;
  /// True when the user has a paid Alpha Vantage plan (disables rate limiting).
  final bool avPremiumTier;

  const SettingsState({
    this.isLoading = false,
    this.finnhubConfigured = false,
    this.marketauxConfigured = false,
    this.alphaVantageConfigured = false,
    this.validationStatus = ValidationStatus.idle,
    this.validationMessage,
    this.validatingProvider,
    this.error,
    this.useAvForTechnicals = false,
    this.avPremiumTier = false,
  });

  /// Check if a specific provider is configured
  bool isConfigured(ApiProvider provider) {
    switch (provider) {
      case ApiProvider.finnhub:
        return finnhubConfigured;
      case ApiProvider.marketaux:
        return marketauxConfigured;
      case ApiProvider.alphaVantage:
        return alphaVantageConfigured;
    }
  }

  /// Check if all providers are configured
  bool get allConfigured =>
      finnhubConfigured && marketauxConfigured && alphaVantageConfigured;

  /// Count of configured providers
  int get configuredCount =>
      (finnhubConfigured ? 1 : 0) +
      (marketauxConfigured ? 1 : 0) +
      (alphaVantageConfigured ? 1 : 0);

  SettingsState copyWith({
    bool? isLoading,
    bool? finnhubConfigured,
    bool? marketauxConfigured,
    bool? alphaVantageConfigured,
    ValidationStatus? validationStatus,
    String? validationMessage,
    ApiProvider? validatingProvider,
    String? error,
    bool clearError = false,
    bool clearValidation = false,
    bool? useAvForTechnicals,
    bool? avPremiumTier,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      finnhubConfigured: finnhubConfigured ?? this.finnhubConfigured,
      marketauxConfigured: marketauxConfigured ?? this.marketauxConfigured,
      alphaVantageConfigured:
          alphaVantageConfigured ?? this.alphaVantageConfigured,
      validationStatus: clearValidation
          ? ValidationStatus.idle
          : (validationStatus ?? this.validationStatus),
      validationMessage:
          clearValidation ? null : (validationMessage ?? this.validationMessage),
      validatingProvider:
          clearValidation ? null : (validatingProvider ?? this.validatingProvider),
      error: clearError ? null : (error ?? this.error),
      useAvForTechnicals: useAvForTechnicals ?? this.useAvForTechnicals,
      avPremiumTier: avPremiumTier ?? this.avPremiumTier,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        finnhubConfigured,
        marketauxConfigured,
        alphaVantageConfigured,
        validationStatus,
        validationMessage,
        validatingProvider,
        error,
        useAvForTechnicals,
        avPremiumTier,
      ];
}
