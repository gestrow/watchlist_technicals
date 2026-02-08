import '../entities/api_provider.dart';

/// Repository interface for managing app settings
abstract class SettingsRepository {
  /// Check if an API key is configured for the given provider
  Future<bool> hasApiKey(ApiProvider provider);

  /// Get the API key for the given provider (returns null if not set)
  Future<String?> getApiKey(ApiProvider provider);

  /// Save an API key for the given provider
  Future<void> saveApiKey(ApiProvider provider, String apiKey);

  /// Delete the API key for the given provider
  Future<void> deleteApiKey(ApiProvider provider);

  /// Get configuration status for all providers
  Future<Map<ApiProvider, bool>> getConfigurationStatus();
}
