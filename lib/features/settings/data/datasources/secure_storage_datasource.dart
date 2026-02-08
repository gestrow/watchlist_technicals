import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/api_provider.dart';

/// Datasource for securely storing API keys using flutter_secure_storage
class SecureStorageDatasource {
  final FlutterSecureStorage _storage;

  SecureStorageDatasource({required FlutterSecureStorage storage})
      : _storage = storage;

  /// Read an API key for the given provider
  Future<String?> readApiKey(ApiProvider provider) async {
    return _storage.read(key: provider.storageKey);
  }

  /// Write an API key for the given provider
  Future<void> writeApiKey(ApiProvider provider, String apiKey) async {
    await _storage.write(key: provider.storageKey, value: apiKey);
  }

  /// Delete an API key for the given provider
  Future<void> deleteApiKey(ApiProvider provider) async {
    await _storage.delete(key: provider.storageKey);
  }

  /// Check if an API key exists for the given provider
  Future<bool> hasApiKey(ApiProvider provider) async {
    final key = await readApiKey(provider);
    return key != null && key.isNotEmpty;
  }
}
