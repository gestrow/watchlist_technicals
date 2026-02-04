import 'package:flutter/material.dart';
import '../../data/datasources/finnhub_api.dart';
import '../../../../core/di/injection_container.dart';

/// Test page for Finnhub API
/// Tests profile, quote, and peers endpoints for AAPL
class FinnhubTestPage extends StatefulWidget {
  const FinnhubTestPage({super.key});

  @override
  State<FinnhubTestPage> createState() => _FinnhubTestPageState();
}

class _FinnhubTestPageState extends State<FinnhubTestPage> {
  final FinnhubApi _finnhubApi = sl<FinnhubApi>();
  String _output = 'Press button to test Finnhub API';
  bool _isLoading = false;

  Future<void> _testFinnhubApi() async {
    setState(() {
      _isLoading = true;
      _output = 'Testing Finnhub API...\n\n';
    });

    try {
      final symbol = 'AAPL';

      // Test 1: Get Company Profile
      _appendOutput('Fetching company profile for $symbol...');
      final profile = await _finnhubApi.getCompanyProfile(symbol);
      _appendOutput('✓ Company Profile:');
      _appendOutput('  Name: ${profile.name}');
      _appendOutput('  Ticker: ${profile.ticker}');
      _appendOutput('  Industry: ${profile.industry}');
      _appendOutput('  Country: ${profile.country}');
      _appendOutput('  Logo: ${profile.logo}');
      _appendOutput('  Description: ${profile.description.substring(0, 100)}...\n');

      // Test 2: Get Quote
      _appendOutput('Fetching quote for $symbol...');
      final quote = await _finnhubApi.getQuote(symbol);
      _appendOutput('✓ Quote:');
      _appendOutput('  Current: \$${quote.current.toStringAsFixed(2)}');
      _appendOutput('  High: \$${quote.high.toStringAsFixed(2)}');
      _appendOutput('  Low: \$${quote.low.toStringAsFixed(2)}');
      _appendOutput('  Open: \$${quote.open.toStringAsFixed(2)}');
      _appendOutput('  Previous Close: \$${quote.previousClose.toStringAsFixed(2)}');
      _appendOutput('  Change: \$${quote.change.toStringAsFixed(2)} (${quote.percentChange.toStringAsFixed(2)}%)\n');

      // Test 3: Get Peers
      _appendOutput('Fetching peers for $symbol...');
      final peers = await _finnhubApi.getPeers(symbol);
      _appendOutput('✓ Peers (${peers.length} total):');
      _appendOutput('  ${peers.take(10).join(", ")}${peers.length > 10 ? "..." : ""}\n');

      _appendOutput('✅ All tests completed successfully!');
    } catch (e) {
      _appendOutput('\n❌ Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _appendOutput(String text) {
    setState(() {
      _output += '$text\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finnhub API Test'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _testFinnhubApi,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Finnhub API (AAPL)'),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                _output,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
