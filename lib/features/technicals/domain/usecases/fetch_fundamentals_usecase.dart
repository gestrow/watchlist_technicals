import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/av_call_tracker.dart';
import '../../data/datasources/alpha_vantage_api.dart';
import '../../data/models/fundamentals_model.dart';
import '../entities/fundamentals_result.dart';

class FetchFundamentalsUsecase {
  final AlphaVantageApi _api;
  final Box _cacheBox;
  final AvCallTracker _callTracker;

  static const int _callsNeeded = 3;

  FetchFundamentalsUsecase({
    required AlphaVantageApi alphaVantageApi,
    required Box cacheBox,
    required AvCallTracker callTracker,
  })  : _api = alphaVantageApi,
        _cacheBox = cacheBox,
        _callTracker = callTracker;

  Future<FundamentalsResult> execute({required String symbol}) async {
    final cacheKey = '${symbol.toUpperCase()}_fundamentals';

    // Check cache
    final cached = _getCached(cacheKey);
    if (cached != null) return cached;

    // Check budget
    if (!_callTracker.canAfford(_callsNeeded)) {
      throw Exception(
        'Insufficient AV API calls remaining '
        '(need $_callsNeeded, have ${_callTracker.remainingCalls})',
      );
    }

    // Fetch company overview
    await _callTracker.throttleIfNeeded();
    final overviewData = await _api.getCompanyOverview(symbol);
    _callTracker.recordCalls(1);

    // Fetch earnings
    await _callTracker.throttleIfNeeded();
    final earningsData = await _api.getEarnings(symbol);
    _callTracker.recordCalls(1);

    // Fetch income statement
    await _callTracker.throttleIfNeeded();
    final incomeData = await _api.getIncomeStatement(symbol);
    _callTracker.recordCalls(1);

    // Parse
    final overview = overviewData.containsKey('Symbol')
        ? CompanyOverviewModel.fromJson(overviewData)
        : null;

    final quarterlyEarnings = <EarningsQuarterModel>[];
    final earningsList =
        earningsData['quarterlyEarnings'] as List<dynamic>? ?? [];
    for (final e in earningsList.take(4)) {
      quarterlyEarnings
          .add(EarningsQuarterModel.fromJson(e as Map<String, dynamic>));
    }

    final quarterlyReports = <IncomeQuarterModel>[];
    final reportsList =
        incomeData['quarterlyReports'] as List<dynamic>? ?? [];
    for (final r in reportsList.take(4)) {
      quarterlyReports
          .add(IncomeQuarterModel.fromJson(r as Map<String, dynamic>));
    }

    final result = FundamentalsResult(
      symbol: symbol.toUpperCase(),
      overview: overview,
      quarterlyEarnings: quarterlyEarnings,
      quarterlyReports: quarterlyReports,
      fetchedAt: DateTime.now(),
    );

    // Cache
    _cacheResult(cacheKey, result, overviewData, earningsData, incomeData);

    return result;
  }

  FundamentalsResult? _getCached(String key) {
    try {
      final cached = _cacheBox.get(key);
      if (cached == null) return null;

      final entry = Map<String, dynamic>.from(cached);
      final timestamp = DateTime.parse(entry['timestamp'] as String);

      if (DateTime.now().difference(timestamp) > AppConstants.fundamentalsCacheTtl) {
        _cacheBox.delete(key);
        return null;
      }

      final overviewMap = entry['overview'] as Map?;
      final overview = overviewMap != null
          ? CompanyOverviewModel.fromJson(Map<String, dynamic>.from(overviewMap))
          : null;

      final earningsList = entry['earnings'] as List? ?? [];
      final earnings = earningsList
          .map((e) =>
              EarningsQuarterModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final reportsList = entry['income'] as List? ?? [];
      final reports = reportsList
          .map((r) =>
              IncomeQuarterModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();

      debugPrint('[Fundamentals] Using cached data for ${entry['symbol']}');

      return FundamentalsResult(
        symbol: entry['symbol'] as String,
        overview: overview,
        quarterlyEarnings: earnings,
        quarterlyReports: reports,
        fetchedAt: timestamp,
      );
    } catch (e) {
      _cacheBox.delete(key);
      return null;
    }
  }

  void _cacheResult(
    String key,
    FundamentalsResult result,
    Map<String, dynamic> overviewRaw,
    Map<String, dynamic> earningsRaw,
    Map<String, dynamic> incomeRaw,
  ) {
    try {
      _cacheBox.put(key, {
        'timestamp': result.fetchedAt.toIso8601String(),
        'symbol': result.symbol,
        'overview': result.overview?.toJson(),
        'earnings':
            result.quarterlyEarnings.map((e) => e.toJson()).toList(),
        'income':
            result.quarterlyReports.map((r) => r.toJson()).toList(),
      });
    } catch (e) {
      debugPrint('[Fundamentals] Cache write failed: $e');
    }
  }
}
