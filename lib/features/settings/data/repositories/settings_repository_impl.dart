import '../../domain/entities/api_provider.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/secure_storage_datasource.dart';

/// Implementation of SettingsRepository using secure storage
class SettingsRepositoryImpl implements SettingsRepository {
  final SecureStorageDatasource _datasource;

  SettingsRepositoryImpl({required SecureStorageDatasource datasource})
      : _datasource = datasource;

  @override
  Future<bool> hasApiKey(ApiProvider provider) async {
    return _datasource.hasApiKey(provider);
  }

  @override
  Future<String?> getApiKey(ApiProvider provider) async {
    return _datasource.readApiKey(provider);
  }

  @override
  Future<void> saveApiKey(ApiProvider provider, String apiKey) async {
    await _datasource.writeApiKey(provider, apiKey);
  }

  @override
  Future<void> deleteApiKey(ApiProvider provider) async {
    await _datasource.deleteApiKey(provider);
  }

  @override
  Future<Map<ApiProvider, bool>> getConfigurationStatus() async {
    final results = <ApiProvider, bool>{};
    for (final provider in ApiProvider.values) {
      results[provider] = await hasApiKey(provider);
    }
    return results;
  }
}
