import 'package:hive/hive.dart';

import '../constants/app_constants.dart';

/// Tracks daily Alpha Vantage API call usage against the 25/day free tier limit.
/// Persists count in Hive settings box so it survives app restarts within the same day.
class AvCallTracker {
  final Box _settingsBox;

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

  /// Called on app boot — resets counter if stored date is not today.
  void resetIfNewDay() {
    final storedDate = _settingsBox.get(AppConstants.avCallDateKey) as String?;
    if (storedDate != null && storedDate != _todayStr) {
      _settingsBox.put(AppConstants.avCallCountKey, 0);
      _settingsBox.put(AppConstants.avCallDateKey, _todayStr);
    }
  }
}
