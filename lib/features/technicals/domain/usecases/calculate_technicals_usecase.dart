import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../data/datasources/yahoo_finance_api.dart';
import '../../data/models/ohlc_model.dart';
import '../calculators/bollinger_bands_calculator.dart';
import '../calculators/dominant_cycle_calculator.dart';
import '../calculators/ema_calculator.dart';
import '../calculators/macd_calculator.dart';
import '../calculators/rsi_calculator.dart';
import '../calculators/sma_calculator.dart';
import '../calculators/vwap_calculator.dart';
import '../entities/technical_indicators_result.dart';
import '../entities/timeframe_config.dart';

/// Use case for calculating technical indicators for a symbol.
class CalculateTechnicalsUsecase {
  final YahooFinanceApi _api;
  final Box _cacheBox;

  static const int _dataBufferDays = 60;
  static const Duration _cacheTtl = Duration(hours: 4);

  CalculateTechnicalsUsecase({
    required YahooFinanceApi api,
    required Box cacheBox,
  })  : _api = api,
        _cacheBox = cacheBox;

  /// Executes the technical calculation for a symbol.
  ///
  /// [symbol] - Stock ticker symbol
  /// [endDate] - End date for calculations (data up to this date)
  /// [config] - Timeframe configuration with indicator parameters
  Future<TechnicalIndicatorsResult> execute({
    required String symbol,
    required DateTime endDate,
    required TimeframeConfig config,
  }) async {
    // Fetch OHLCV data (with caching)
    final candles = await _fetchOhlcData(symbol, endDate);

    if (candles.isEmpty) {
      throw Exception('No data available for $symbol');
    }

    // Filter candles up to endDate
    final filteredCandles = candles
        .where((c) =>
            c.date.isBefore(endDate.add(const Duration(days: 1))) ||
            c.date.isAtSameMomentAs(endDate))
        .toList();

    if (filteredCandles.isEmpty) {
      throw Exception('No data available for $symbol up to $endDate');
    }

    // Run calculations in isolate for performance
    final result = await compute(
      _calculateInIsolate,
      _CalculationParams(
        candles: filteredCandles,
        config: config,
        symbol: symbol,
        endDate: endDate,
      ),
    );

    return result;
  }

  /// Fetches OHLC data with caching.
  Future<List<OhlcModel>> _fetchOhlcData(
    String symbol,
    DateTime endDate,
  ) async {
    final startDate = endDate.subtract(const Duration(days: _dataBufferDays));
    final cacheKey = _getCacheKey(symbol, startDate, endDate);

    // Check cache
    final cached = _getCachedData(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Fetch from API
    final candles = await _api.getHistoricalData(
      symbol,
      startDate,
      endDate,
      '1d',
    );

    // Cache the result
    _cacheData(cacheKey, candles);

    return candles;
  }

  String _getCacheKey(String symbol, DateTime start, DateTime end) {
    final startStr =
        '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endStr =
        '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    return '${symbol}_ohlc_${startStr}_$endStr';
  }

  List<OhlcModel>? _getCachedData(String key) {
    try {
      final cached = _cacheBox.get(key);
      if (cached == null) return null;

      final Map<String, dynamic> cacheEntry = Map<String, dynamic>.from(cached);
      final timestamp = DateTime.parse(cacheEntry['timestamp'] as String);

      // Check TTL
      if (DateTime.now().difference(timestamp) > _cacheTtl) {
        _cacheBox.delete(key);
        return null;
      }

      // Deserialize candles
      final candlesJson = List<Map<String, dynamic>>.from(
        (cacheEntry['candles'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
      return candlesJson.map((json) => OhlcModel.fromJson(json)).toList();
    } catch (e) {
      // Invalid cache entry, delete it
      _cacheBox.delete(key);
      return null;
    }
  }

  void _cacheData(String key, List<OhlcModel> candles) {
    try {
      final cacheEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'candles': candles.map((c) => c.toJson()).toList(),
      };
      _cacheBox.put(key, cacheEntry);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Static method for compute isolate.
  static TechnicalIndicatorsResult _calculateInIsolate(
    _CalculationParams params,
  ) {
    final candles = params.candles;
    final config = params.config;
    final closes = candles.map((c) => c.close).toList();

    // Initialize calculators
    final rsiCalc = RsiCalculator();
    final emaCalc = EmaCalculator();
    final smaCalc = SmaCalculator();
    final macdCalc = MacdCalculator();
    final bbCalc = BollingerBandsCalculator();
    final vwapCalc = VwapCalculator();
    final cycleCalc = DominantCycleFacade();

    // Calculate RSI
    final rsi = rsiCalc.calculate(closes, config.rsiPeriod);

    // Calculate EMAs for all periods
    final emas = <int, List<double?>>{};
    for (final period in config.emaPeriods) {
      if (config.useSMA) {
        emas[period] = smaCalc.calculate(closes, period);
      } else {
        emas[period] = emaCalc.calculate(closes, period);
      }
    }

    // Calculate SMA if useSMA is true
    final sma = config.useSMA
        ? smaCalc.calculate(closes, config.emaPeriods.first)
        : <double?>[];

    // Calculate MACD
    final macd = macdCalc.calculate(
      closes,
      fastPeriod: config.macdFast,
      slowPeriod: config.macdSlow,
      signalPeriod: config.macdSignal,
    );

    // Calculate Bollinger Bands
    final bollinger = bbCalc.calculate(
      closes,
      period: config.bollingerPeriod,
      stdDevMultiplier: config.bollingerStdDev,
    );

    // Calculate VWAP
    final vwap = vwapCalc.calculate(
      candles,
      rollingPeriod: config.vwapPeriod,
    );

    // Calculate Dominant Cycle
    final dominantCycle = cycleCalc.calculate(candles);

    return TechnicalIndicatorsResult(
      candles: candles,
      rsi: rsi,
      emas: emas,
      sma: sma,
      macd: macd,
      bollinger: bollinger,
      vwap: vwap,
      dominantCycle: dominantCycle,
      symbol: params.symbol,
      endDate: params.endDate,
      calculatedAt: DateTime.now(),
    );
  }
}

/// Parameters for isolate calculation.
class _CalculationParams {
  final List<OhlcModel> candles;
  final TimeframeConfig config;
  final String symbol;
  final DateTime endDate;

  const _CalculationParams({
    required this.candles,
    required this.config,
    required this.symbol,
    required this.endDate,
  });
}
