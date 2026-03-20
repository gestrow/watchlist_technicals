import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/api_provider.dart';
import '../../domain/repositories/settings_repository.dart';

export '../../domain/entities/api_provider.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// BLoC for managing app settings
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;
  final Dio _dio;
  final Box _settingsBox;

  SettingsBloc({
    required SettingsRepository repository,
    required Dio dio,
    required Box settingsBox,
  })  : _repository = repository,
        _dio = dio,
        _settingsBox = settingsBox,
        super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<SaveApiKey>(_onSaveApiKey);
    on<ValidateApiKey>(_onValidateApiKey);
    on<ClearApiKey>(_onClearApiKey);
    on<ClearValidationState>(_onClearValidationState);
    on<ToggleAvForTechnicals>(_onToggleAvForTechnicals);
    on<ToggleAvPremiumTier>(_onToggleAvPremiumTier);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final status = await _repository.getConfigurationStatus();
      final avMode =
          _settingsBox.get(AppConstants.avModeKey, defaultValue: false) as bool;
      final avPremium =
          !(_settingsBox.get(AppConstants.avFreeTierKey, defaultValue: true) as bool);
      emit(state.copyWith(
        isLoading: false,
        finnhubConfigured: status[ApiProvider.finnhub] ?? false,
        marketauxConfigured: status[ApiProvider.marketaux] ?? false,
        alphaVantageConfigured: status[ApiProvider.alphaVantage] ?? false,
        useAvForTechnicals: avMode,
        avPremiumTier: avPremium,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load settings: $e',
      ));
    }
  }

  Future<void> _onSaveApiKey(
    SaveApiKey event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.saveApiKey(event.provider, event.apiKey);

      // Update state based on provider
      switch (event.provider) {
        case ApiProvider.finnhub:
          emit(state.copyWith(finnhubConfigured: true, clearValidation: true));
        case ApiProvider.marketaux:
          emit(state.copyWith(marketauxConfigured: true, clearValidation: true));
        case ApiProvider.alphaVantage:
          emit(state.copyWith(alphaVantageConfigured: true, clearValidation: true));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to save API key: $e',
      ));
    }
  }

  Future<void> _onValidateApiKey(
    ValidateApiKey event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      validationStatus: ValidationStatus.validating,
      validatingProvider: event.provider,
    ));

    try {
      final isValid = await _validateKey(event.provider, event.apiKey);

      if (isValid) {
        emit(state.copyWith(
          validationStatus: ValidationStatus.success,
          validationMessage: 'API key is valid',
        ));
      } else {
        emit(state.copyWith(
          validationStatus: ValidationStatus.failure,
          validationMessage: 'Invalid API key',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        validationStatus: ValidationStatus.failure,
        validationMessage: _getValidationErrorMessage(e),
      ));
    }
  }

  Future<void> _onClearApiKey(
    ClearApiKey event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.deleteApiKey(event.provider);

      // Update state based on provider
      switch (event.provider) {
        case ApiProvider.finnhub:
          emit(state.copyWith(finnhubConfigured: false));
        case ApiProvider.marketaux:
          emit(state.copyWith(marketauxConfigured: false));
        case ApiProvider.alphaVantage:
          emit(state.copyWith(alphaVantageConfigured: false));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to clear API key: $e',
      ));
    }
  }

  void _onClearValidationState(
    ClearValidationState event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(clearValidation: true));
  }

  Future<void> _onToggleAvForTechnicals(
    ToggleAvForTechnicals event,
    Emitter<SettingsState> emit,
  ) async {
    await _settingsBox.put(AppConstants.avModeKey, event.enabled);
    emit(state.copyWith(useAvForTechnicals: event.enabled));
  }

  Future<void> _onToggleAvPremiumTier(
    ToggleAvPremiumTier event,
    Emitter<SettingsState> emit,
  ) async {
    // avFreeTierKey stores true = free tier; premium = NOT free tier
    await _settingsBox.put(AppConstants.avFreeTierKey, !event.isPremium);
    emit(state.copyWith(avPremiumTier: event.isPremium));
  }

  /// Validate an API key by making a test request
  Future<bool> _validateKey(ApiProvider provider, String apiKey) async {
    switch (provider) {
      case ApiProvider.finnhub:
        return _validateFinnhubKey(apiKey);
      case ApiProvider.marketaux:
        return _validateMarketAuxKey(apiKey);
      case ApiProvider.alphaVantage:
        return _validateAlphaVantageKey(apiKey);
    }
  }

  /// Test Finnhub API key with a quote request
  Future<bool> _validateFinnhubKey(String apiKey) async {
    final response = await _dio.get(
      '${ApiConstants.finnhubBaseUrl}${ApiConstants.finnhubQuote}',
      queryParameters: {
        'symbol': 'AAPL',
        'token': apiKey,
      },
    );

    // Check if response has valid data
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      // Valid response has a current price > 0
      return data['c'] != null && data['c'] > 0;
    }
    return false;
  }

  /// Test Alpha Vantage API key with a quote request
  Future<bool> _validateAlphaVantageKey(String apiKey) async {
    final response = await _dio.get(
      '${ApiConstants.alphaVantageBaseUrl}${ApiConstants.alphaVantageQuery}',
      queryParameters: {
        'function': 'TIME_SERIES_DAILY',
        'symbol': 'AAPL',
        'outputsize': 'compact',
        'apikey': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      // Invalid key returns {"Error Message": "..."}
      // Rate limit returns {"Note": "..."}
      return data.containsKey('Time Series (Daily)');
    }
    return false;
  }

  /// Test MarketAux API key with a news request
  Future<bool> _validateMarketAuxKey(String apiKey) async {
    final response = await _dio.get(
      '${ApiConstants.marketAuxBaseUrl}${ApiConstants.marketAuxNews}',
      queryParameters: {
        'api_token': apiKey,
        'limit': '1',
      },
    );

    // Check if response is successful
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      // Valid response has a data field
      return data.containsKey('data');
    }
    return false;
  }

  String _getValidationErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 401:
          return 'Invalid API key';
        case 403:
          return 'API key does not have required permissions';
        case 429:
          return 'Rate limit exceeded. Try again later.';
        default:
          if (error.type == DioExceptionType.connectionError) {
            return 'Network error. Check your connection.';
          }
          if (error.type == DioExceptionType.connectionTimeout) {
            return 'Connection timed out. Try again.';
          }
          return 'Validation failed: ${error.message}';
      }
    }
    return 'Validation failed: $error';
  }
}
