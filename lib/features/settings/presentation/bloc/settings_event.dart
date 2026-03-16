part of 'settings_bloc.dart';

/// Base class for settings events
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load settings on startup
final class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Save an API key for a provider
final class SaveApiKey extends SettingsEvent {
  final ApiProvider provider;
  final String apiKey;

  const SaveApiKey({required this.provider, required this.apiKey});

  @override
  List<Object?> get props => [provider, apiKey];
}

/// Validate an API key before saving
final class ValidateApiKey extends SettingsEvent {
  final ApiProvider provider;
  final String apiKey;

  const ValidateApiKey({required this.provider, required this.apiKey});

  @override
  List<Object?> get props => [provider, apiKey];
}

/// Clear an API key for a provider
final class ClearApiKey extends SettingsEvent {
  final ApiProvider provider;

  const ClearApiKey({required this.provider});

  @override
  List<Object?> get props => [provider];
}

/// Clear validation state (after dialog dismissed)
final class ClearValidationState extends SettingsEvent {
  const ClearValidationState();
}

/// Toggle "Use Alpha Vantage for Technicals" setting
final class ToggleAvForTechnicals extends SettingsEvent {
  final bool enabled;

  const ToggleAvForTechnicals({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}
