import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ========================================
// MarketAux API Key Management
// ========================================

/// Helper function to store MarketAux API key in secure storage
///
/// Usage:
/// 1. Add a button in your app that calls this function
/// 2. Or call it once during app initialization
/// 3. Pass your API key as the parameter
///
/// Example:
/// ```dart
/// await storeMarketAuxApiKey('your_api_key_here');
/// ```
Future<void> storeMarketAuxApiKey(String apiKey) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: 'marketaux_api_key', value: apiKey);
  print('✓ MarketAux API key stored successfully in secure storage');
}

/// Helper function to retrieve MarketAux API key
Future<String?> getMarketAuxApiKey() async {
  const storage = FlutterSecureStorage();
  final apiKey = await storage.read(key: 'marketaux_api_key');
  if (apiKey != null && apiKey.isNotEmpty) {
    print('✓ MarketAux API key found');
    return apiKey;
  } else {
    print('✗ MarketAux API key not found in secure storage');
    return null;
  }
}

/// Helper function to delete MarketAux API key
Future<void> deleteMarketAuxApiKey() async {
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'marketaux_api_key');
  print('✓ MarketAux API key deleted from secure storage');
}

// ========================================
// Finnhub API Key Management
// ========================================

/// Helper function to store Finnhub API key in secure storage
///
/// Usage:
/// 1. Add a button in your app that calls this function
/// 2. Or call it once during app initialization
/// 3. Pass your API key as the parameter
///
/// Example:
/// ```dart
/// await storeFinnhubApiKey('your_api_key_here');
/// ```
Future<void> storeFinnhubApiKey(String apiKey) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: 'finnhub_api_key', value: apiKey);
  print('✓ Finnhub API key stored successfully in secure storage');
}

/// Helper function to retrieve Finnhub API key
Future<String?> getFinnhubApiKey() async {
  const storage = FlutterSecureStorage();
  final apiKey = await storage.read(key: 'finnhub_api_key');
  if (apiKey != null && apiKey.isNotEmpty) {
    print('✓ Finnhub API key found');
    return apiKey;
  } else {
    print('✗ Finnhub API key not found in secure storage');
    return null;
  }
}

/// Helper function to delete Finnhub API key
Future<void> deleteFinnhubApiKey() async {
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'finnhub_api_key');
  print('✓ Finnhub API key deleted from secure storage');
}
