import 'dart:async';

import 'package:hive/hive.dart';

import '../constants/app_constants.dart';

/// Tracks daily Alpha Vantage API call usage against the 25/day free tier limit.
/// Persists count in Hive settings box so it survives app restarts within the same day.
///
/// Also enforces free-tier rate limiting (5 req/min) by serializing calls with
/// a minimum 13-second gap when [isFreeTier] is true.
class AvCallTracker {
  final Box _settingsBox;

  /// Serialized rate-limit queue — each caller chains onto the previous.
  Future<void>? _rateLimitQueue;

  /// Timestamp of when the last rate-limited call was allowed to proceed.
  DateTime? _lastCallTime;

  AvCallTracker({required Box settingsBox}) : _settingsBox = settingsBox;

  String get _todayStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Number of calls used today.
  int get usedCalls {
    final storedDate = _settingsBox.get(AppConstants.avCallDateKey) as String?;
    if (storedDate != _todayStr) return 0;
    return (_settingsBox.get(AppConstants.avCallCountKey) as int?) ?? 0;
  }

  /// Number of calls remaining today.
  int get remainingCalls => AppConstants.avDailyCallLimit - usedCalls;

  /// Whether there are enough calls remaining.
  bool canAfford(int needed) => remainingCalls >= needed;

  /// Display string for the UI.
  String get displayString => '$remainingCalls/${AppConstants.avDailyCallLimit}';

  /// Record that [count] API calls were made.
  void recordCalls(int count) {
    final storedDate = _settingsBox.get(AppConstants.avCallDateKey) as String?;
    final today = _todayStr;

    if (storedDate != today) {
      // New day — reset counter
      _settingsBox.put(AppConstants.avCallDateKey, today);
      _settingsBox.put(AppConstants.avCallCountKey, count);
    } else {
      final current =
          (_settingsBox.get(AppConstants.avCallCountKey) as int?) ?? 0;
      _settingsBox.put(AppConstants.avCallCountKey, current + count);
    }
  }

  /// Whether the user is on the free tier (default true).
  /// Free tier: 5 API calls/minute → 13 s minimum gap between calls.
  bool get isFreeTier =>
      (_settingsBox.get(AppConstants.avFreeTierKey, defaultValue: true) as bool?) ??
      true;

  /// Waits if necessary to stay within the AV free-tier rate limit (5 req/min).
  ///
  /// Calls are serialized: each invocation queues behind the previous one so
  /// that concurrent callers (technicals + fundamentals) never burst.
  Future<void> throttleIfNeeded() async {
    if (!isFreeTier) return;

    // Capture and replace the queue atomically (Dart is single-threaded).
    final prev = _rateLimitQueue;
    final completer = Completer<void>();
    _rateLimitQueue = completer.future;

    // Wait for the previous call's slot to finish.
    if (prev != null) await prev;

    // Now enforce the minimum interval since the last allowed call.
    final lastCall = _lastCallTime;
    if (lastCall != null) {
      const minInterval = Duration(milliseconds: AppConstants.avFreeMinIntervalMs);
      final elapsed = DateTime.now().difference(lastCall);
      if (elapsed < minInterval) {
        await Future.delayed(minInterval - elapsed);
      }
    }

    _lastCallTime = DateTime.now();
    completer.complete();
  }

  /// Called on app boot — resets counter if stored date is not today.
  void resetIfNewDay() {
    final storedDate = _settingsBox.get(AppConstants.avCallDateKey) as String?;
    if (storedDate != null && storedDate != _todayStr) {
      _settingsBox.put(AppConstants.avCallCountKey, 0);
      _settingsBox.put(AppConstants.avCallDateKey, _todayStr);
    }
  }
}
