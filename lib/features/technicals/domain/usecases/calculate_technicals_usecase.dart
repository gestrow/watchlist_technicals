import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../../core/services/av_call_tracker.dart';
import '../../data/datasources/alpha_vantage_api.dart';
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
  final AlphaVantageApi _alphaVantageApi;
  final Box _cacheBox;
  final AvCallTracker _callTracker;

  static const int _dataBufferDays = 60;
  static const Duration _cacheTtl = Duration(hours: 4);

  CalculateTechnicalsUsecase({
    required YahooFinanceApi api,
    required AlphaVantageApi alphaVantageApi,
    required Box cacheBox,
    required AvCallTracker callTracker,
  })  : _api = api,
        _alphaVantageApi = alphaVantageApi,
        _cacheBox = cacheBox,
        _callTracker = callTracker;

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

  /// Executes technical calculation using Alpha Vantage server-side indicators.
  ///
  /// Fetches RSI, EMA, MACD, BBANDS from AV. VWAP is calculated locally from
  /// AV price data. Dominant Cycle is always calculated from Yahoo Finance data.
  Future<TechnicalIndicatorsResult> executeWithAv({
    required String symbol,
    required DateTime endDate,
    required TimeframeConfig config,
  }) async {
    final upperSymbol = symbol.toUpperCase();

    // Calculate needed API calls
    final neededCalls = 1 + // RSI
        config.emaPeriods.length + // EMA per period
        1 + // MACD
        1 + // BBANDS
        1; // TIME_SERIES_DAILY (for VWAP + candle data)

    // Check per-indicator AV cache — only fetch uncached indicators
    final today = _todayStr();
    var actualCallsNeeded = 0;

    if (!_isAvCached('${upperSymbol}_av_RSI_${config.rsiPeriod}', today)) {
      actualCallsNeeded++;
    }
    for (final period in config.emaPeriods) {
      if (!_isAvCached('${upperSymbol}_av_EMA_$period', today)) {
        actualCallsNeeded++;
      }
    }
    if (!_isAvCached(
        '${upperSymbol}_av_MACD_${config.macdFast}_${config.macdSlow}_${config.macdSignal}',
        today)) {
      actualCallsNeeded++;
    }
    if (!_isAvCached(
        '${upperSymbol}_av_BBANDS_${config.bollingerPeriod}_${config.bollingerStdDev}',
        today)) {
      actualCallsNeeded++;
    }
    if (!_isAvCached('${upperSymbol}_av_DAILY', today)) {
      actualCallsNeeded++;
    }

    if (actualCallsNeeded > 0 && !_callTracker.canAfford(actualCallsNeeded)) {
      throw Exception(
        'Insufficient AV API calls (need $actualCallsNeeded, '
        'have ${_callTracker.remainingCalls}). '
        'Total budget: $neededCalls calls for full fetch.',
      );
    }

    // 1. Fetch daily candle data from AV (for VWAP + chart + index alignment)
    List<OhlcModel> avCandles;
    final dailyCacheKey = '${upperSymbol}_av_DAILY';
    final cachedDaily = _getAvCachedList(dailyCacheKey, today);
    if (cachedDaily != null) {
      avCandles = cachedDaily;
    } else {
      avCandles = await _alphaVantageApi.getDailyData(upperSymbol);
      _callTracker.recordCalls(1);
      _cacheAvList(dailyCacheKey, avCandles);
    }

    if (avCandles.isEmpty) {
      throw Exception('No AV daily data for $upperSymbol');
    }

    // Filter candles up to endDate
    final filteredCandles = avCandles
        .where((c) =>
            c.date.isBefore(endDate.add(const Duration(days: 1))) ||
            c.date.isAtSameMomentAs(endDate))
        .toList();

    // Build date-to-index map for aligning indicator data
    final dateIndex = <String, int>{};
    for (var i = 0; i < filteredCandles.length; i++) {
      final d = filteredCandles[i].date;
      dateIndex[
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'] =
          i;
    }

    // 2. Fetch RSI
    final rsi = List<double?>.filled(filteredCandles.length, null);
    final rsiKey = '${upperSymbol}_av_RSI_${config.rsiPeriod}';
    var rsiMap = _getAvCachedMap(rsiKey, today);
    if (rsiMap == null) {
      rsiMap = await _alphaVantageApi.getRSI(
        upperSymbol,
        timePeriod: config.rsiPeriod,
      );
      _callTracker.recordCalls(1);
      _cacheAvMap(rsiKey, rsiMap);
    }
    _alignSingleIndicator(rsiMap, dateIndex, rsi);

    // 3. Fetch EMAs
    final emas = <int, List<double?>>{};
    for (final period in config.emaPeriods) {
      final emaList = List<double?>.filled(filteredCandles.length, null);
      final emaKey = '${upperSymbol}_av_EMA_$period';
      var emaMap = _getAvCachedMap(emaKey, today);
      if (emaMap == null) {
        emaMap = await _alphaVantageApi.getEMA(
          upperSymbol,
          timePeriod: period,
        );
        _callTracker.recordCalls(1);
        _cacheAvMap(emaKey, emaMap);
      }
      _alignSingleIndicator(emaMap, dateIndex, emaList);
      emas[period] = emaList;
    }

    // 4. Fetch MACD
    final macdLine = List<double?>.filled(filteredCandles.length, null);
    final signalLine = List<double?>.filled(filteredCandles.length, null);
    final histogram = List<double?>.filled(filteredCandles.length, null);
    final macdKey =
        '${upperSymbol}_av_MACD_${config.macdFast}_${config.macdSlow}_${config.macdSignal}';
    var macdMap = _getAvCachedMultiMap(macdKey, today);
    if (macdMap == null) {
      macdMap = await _alphaVantageApi.getMACD(
        upperSymbol,
        fastPeriod: config.macdFast,
        slowPeriod: config.macdSlow,
        signalPeriod: config.macdSignal,
      );
      _callTracker.recordCalls(1);
      _cacheAvMultiMap(macdKey, macdMap);
    }
    for (final entry in macdMap.entries) {
      final idx = dateIndex[entry.key];
      if (idx != null) {
        macdLine[idx] = entry.value['MACD'];
        signalLine[idx] = entry.value['MACD_Signal'];
        histogram[idx] = entry.value['MACD_Hist'];
      }
    }

    // 5. Fetch Bollinger Bands
    final bbUpper = List<double?>.filled(filteredCandles.length, null);
    final bbMiddle = List<double?>.filled(filteredCandles.length, null);
    final bbLower = List<double?>.filled(filteredCandles.length, null);
    final bbKey =
        '${upperSymbol}_av_BBANDS_${config.bollingerPeriod}_${config.bollingerStdDev}';
    var bbMap = _getAvCachedMultiMap(bbKey, today);
    if (bbMap == null) {
      bbMap = await _alphaVantageApi.getBBands(
        upperSymbol,
        timePeriod: config.bollingerPeriod,
        nbDevUp: config.bollingerStdDev,
        nbDevDn: config.bollingerStdDev,
      );
      _callTracker.recordCalls(1);
      _cacheAvMultiMap(bbKey, bbMap);
    }
    for (final entry in bbMap.entries) {
      final idx = dateIndex[entry.key];
      if (idx != null) {
        bbUpper[idx] = entry.value['upper'];
        bbMiddle[idx] = entry.value['middle'];
        bbLower[idx] = entry.value['lower'];
      }
    }

    // 6. VWAP — calculated locally from AV candle data
    final vwapCalc = VwapCalculator();
    final vwap = vwapCalc.calculate(
      filteredCandles,
      rollingPeriod: config.vwapPeriod,
    );

    // 7. Dominant Cycle — always from Yahoo Finance
    double? dominantCycle;
    try {
      final yahooCandles = await _fetchYahooOnly(symbol, endDate);
      if (yahooCandles.length >= 30) {
        final cycleCalc = DominantCycleFacade();
        dominantCycle = cycleCalc.calculate(yahooCandles);
      }
    } catch (e) {
      debugPrint('[Technicals] Yahoo for dominant cycle failed: $e');
    }

    return TechnicalIndicatorsResult(
      candles: filteredCandles,
      rsi: rsi,
      emas: emas,
      sma: const [],
      macd: MacdResult(macdLine, signalLine, histogram),
      bollinger: BollingerBandsResult(bbUpper, bbMiddle, bbLower),
      vwap: vwap,
      dominantCycle: dominantCycle,
      symbol: symbol,
      endDate: endDate,
      calculatedAt: DateTime.now(),
      dataSource: 'alpha_vantage',
    );
  }

  /// Fetches Yahoo Finance OHLCV only (no AV fallback), for Dominant Cycle.
  Future<List<OhlcModel>> _fetchYahooOnly(
    String symbol,
    DateTime endDate,
  ) async {
    final startDate = endDate.subtract(const Duration(days: _dataBufferDays));
    return _api.getHistoricalData(symbol, startDate, endDate, '1d');
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // AV Indicator Cache Helpers
  // ---------------------------------------------------------------------------

  bool _isAvCached(String key, String today) {
    final cached = _cacheBox.get(key);
    if (cached == null) return false;
    try {
      final entry = Map<String, dynamic>.from(cached);
      return entry['date'] == today;
    } catch (_) {
      return false;
    }
  }

  Map<String, double>? _getAvCachedMap(String key, String today) {
    if (!_isAvCached(key, today)) return null;
    try {
      final entry = Map<String, dynamic>.from(_cacheBox.get(key));
      final data = Map<String, dynamic>.from(entry['data']);
      return data.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return null;
    }
  }

  void _cacheAvMap(String key, Map<String, double> data) {
    try {
      _cacheBox.put(key, {
        'date': _todayStr(),
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      });
    } catch (_) {}
  }

  Map<String, Map<String, double>>? _getAvCachedMultiMap(
      String key, String today) {
    if (!_isAvCached(key, today)) return null;
    try {
      final entry = Map<String, dynamic>.from(_cacheBox.get(key));
      final data = Map<String, dynamic>.from(entry['data']);
      return data.map((k, v) {
        final inner = Map<String, dynamic>.from(v);
        return MapEntry(
            k, inner.map((ik, iv) => MapEntry(ik, (iv as num).toDouble())));
      });
    } catch (_) {
      return null;
    }
  }

  void _cacheAvMultiMap(String key, Map<String, Map<String, double>> data) {
    try {
      _cacheBox.put(key, {
        'date': _todayStr(),
        'timestamp': DateTime.now().toIso8601String(),
        'data': data.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v))),
      });
    } catch (_) {}
  }

  List<OhlcModel>? _getAvCachedList(String key, String today) {
    if (!_isAvCached(key, today)) return null;
    try {
      final entry = Map<String, dynamic>.from(_cacheBox.get(key));
      final candlesJson = List<Map<String, dynamic>>.from(
        (entry['candles'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
      return candlesJson.map((json) => OhlcModel.fromJson(json)).toList();
    } catch (_) {
      return null;
    }
  }

  void _cacheAvList(String key, List<OhlcModel> candles) {
    try {
      _cacheBox.put(key, {
        'date': _todayStr(),
        'timestamp': DateTime.now().toIso8601String(),
        'candles': candles.map((c) => c.toJson()).toList(),
      });
    } catch (_) {}
  }

  void _alignSingleIndicator(
    Map<String, double> indicatorMap,
    Map<String, int> dateIndex,
    List<double?> target,
  ) {
    for (final entry in indicatorMap.entries) {
      final idx = dateIndex[entry.key];
      if (idx != null) {
        target[idx] = entry.value;
      }
    }
  }

  /// Fetches OHLC data with caching.
  /// Tries Yahoo Finance first, falls back to Alpha Vantage if configured.
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

    // Try Yahoo Finance first
    try {
      final candles = await _api.getHistoricalData(
        symbol,
        startDate,
        endDate,
        '1d',
      );

      _cacheData(cacheKey, candles);
      return candles;
    } catch (yahooError) {
      print('[Technicals] Yahoo Finance failed for $symbol: $yahooError');

      // Fall back to Alpha Vantage if configured
      if (await _alphaVantageApi.isConfigured) {
        print('[Technicals] Falling back to Alpha Vantage for $symbol');
        try {
          final candles = await _alphaVantageApi.getHistoricalData(
            symbol,
            startDate,
            endDate,
            '1d',
          );

          _cacheData(cacheKey, candles);
          return candles;
        } catch (avError) {
          print('[Technicals] Alpha Vantage also failed: $avError');
          // Throw the original Yahoo error as it's the primary source
          rethrow;
        }
      }

      // No fallback available, rethrow Yahoo error
      throw yahooError;
    }
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
