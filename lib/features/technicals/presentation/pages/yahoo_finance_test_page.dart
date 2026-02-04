import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/datasources/yahoo_finance_api.dart';
import '../../../../core/di/injection_container.dart';

/// Test page for Yahoo Finance API
/// Tests fetching 60 days of daily OHLCV data for AAPL
class YahooFinanceTestPage extends StatefulWidget {
  const YahooFinanceTestPage({super.key});

  @override
  State<YahooFinanceTestPage> createState() => _YahooFinanceTestPageState();
}

class _YahooFinanceTestPageState extends State<YahooFinanceTestPage> {
  final YahooFinanceApi _yahooApi = sl<YahooFinanceApi>();
  String _output = 'Press button to test Yahoo Finance API';
  bool _isLoading = false;

  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _priceFormat = NumberFormat('\$#,##0.00');

  Future<void> _testYahooFinanceApi() async {
    setState(() {
      _isLoading = true;
      _output = 'Testing Yahoo Finance API...\\n\\n';
    });

    try {
      const symbol = 'AAPL';
      const days = 60;

      _appendOutput('Fetching $days days of daily data for $symbol...');
      _appendOutput(
          'WARNING: Yahoo Finance API is unofficial and for testing only\\n');

      final candles = await _yahooApi.getRecentDailyData(symbol, days);

      _appendOutput('✓ Successfully fetched ${candles.length} candles\\n');

      // Display first 5 candles
      _appendOutput('=== FIRST 5 CANDLES ===');
      final first5 = candles.take(5).toList();
      for (final candle in first5) {
        _appendOutput(_formatCandle(candle));
      }

      _appendOutput('');

      // Display last 5 candles
      _appendOutput('=== LAST 5 CANDLES ===');
      final last5 = candles.reversed.take(5).toList().reversed.toList();
      for (final candle in last5) {
        _appendOutput(_formatCandle(candle));
      }

      _appendOutput('');

      // Summary statistics
      _appendOutput('=== SUMMARY ===');
      final avgVolume = candles.map((c) => c.volume).reduce((a, b) => a + b) /
          candles.length;
      final highestClose = candles.map((c) => c.close).reduce(
          (a, b) => a > b ? a : b);
      final lowestClose = candles.map((c) => c.close).reduce(
          (a, b) => a < b ? a : b);

      _appendOutput('Total candles: ${candles.length}');
      _appendOutput(
          'Date range: ${_dateFormat.format(candles.first.date)} to ${_dateFormat.format(candles.last.date)}');
      _appendOutput('Highest close: ${_priceFormat.format(highestClose)}');
      _appendOutput('Lowest close: ${_priceFormat.format(lowestClose)}');
      _appendOutput(
          'Avg volume: ${NumberFormat('#,###').format(avgVolume.round())}');

      _appendOutput('\\n✅ All tests completed successfully!');
    } catch (e) {
      _appendOutput('\\n❌ Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCandle(dynamic candle) {
    // Handle both OhlcModel and any potential dynamic type
    final date = _dateFormat.format(candle.date);
    final open = _priceFormat.format(candle.open);
    final high = _priceFormat.format(candle.high);
    final low = _priceFormat.format(candle.low);
    final close = _priceFormat.format(candle.close);
    final volume = NumberFormat('#,###').format(candle.volume);

    return '$date | O:$open H:$high L:$low C:$close V:$volume';
  }

  void _appendOutput(String text) {
    setState(() {
      _output += '$text\\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yahoo Finance API Test'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testYahooFinanceApi,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Test Yahoo Finance API (AAPL 60d)'),
                ),
                const SizedBox(height: 8),
                const Text(
                  '⚠️ Yahoo Finance API is unofficial. Use for testing only.',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                _output,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
