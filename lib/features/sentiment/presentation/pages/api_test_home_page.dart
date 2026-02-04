import 'package:flutter/material.dart';
import 'marketaux_test_page.dart';
import 'finnhub_test_page.dart';
import '../../../technicals/presentation/pages/yahoo_finance_test_page.dart';

/// Home page with navigation to API test pages
class ApiTestHomePage extends StatelessWidget {
  const ApiTestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test Dashboard'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select API to Test',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MarketAuxTestPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.newspaper, size: 28),
                  label: const Text(
                    'MarketAux API\n(News & Sentiment)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FinnhubTestPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.show_chart, size: 28),
                  label: const Text(
                    'Finnhub API\n(Stock Data)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const YahooFinanceTestPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.candlestick_chart, size: 28),
                  label: const Text(
                    'Yahoo Finance API\n(Historical OHLCV)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
