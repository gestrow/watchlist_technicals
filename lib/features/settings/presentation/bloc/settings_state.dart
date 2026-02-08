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
  final ValidationStatus validationStatus;
  final String? validationMessage;
  final ApiProvider? validatingProvider;
  final String? error;

  const SettingsState({
    this.isLoading = false,
    this.finnhubConfigured = false,
    this.marketauxConfigured = false,
    this.validationStatus = ValidationStatus.idle,
    this.validationMessage,
    this.validatingProvider,
    this.error,
  });

  /// Check if a specific provider is configured
  bool isConfigured(ApiProvider provider) {
    switch (provider) {
      case ApiProvider.finnhub:
        return finnhubConfigured;
      case ApiProvider.marketaux:
        return marketauxConfigured;
    }
  }

  /// Check if all providers are configured
  bool get allConfigured => finnhubConfigured && marketauxConfigured;

  /// Count of configured providers
  int get configuredCount =>
      (finnhubConfigured ? 1 : 0) + (marketauxConfigured ? 1 : 0);

  SettingsState copyWith({
    bool? isLoading,
    bool? finnhubConfigured,
    bool? marketauxConfigured,
    ValidationStatus? validationStatus,
    String? validationMessage,
    ApiProvider? validatingProvider,
    String? error,
    bool clearError = false,
    bool clearValidation = false,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      finnhubConfigured: finnhubConfigured ?? this.finnhubConfigured,
      marketauxConfigured: marketauxConfigured ?? this.marketauxConfigured,
      validationStatus: clearValidation
          ? ValidationStatus.idle
          : (validationStatus ?? this.validationStatus),
      validationMessage:
          clearValidation ? null : (validationMessage ?? this.validationMessage),
      validatingProvider:
          clearValidation ? null : (validatingProvider ?? this.validatingProvider),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        finnhubConfigured,
        marketauxConfigured,
        validationStatus,
        validationMessage,
        validatingProvider,
        error,
      ];
}
