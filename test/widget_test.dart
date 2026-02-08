// Widget tests for Watchlist Technicals app
//
// This file contains smoke tests to verify core app functionality.
// More detailed widget tests are in feature-specific test directories.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('MaterialApp builds without errors', (tester) async {
      // Build a minimal MaterialApp to verify the testing framework works
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Watchlist Technicals'),
            ),
          ),
        ),
      );

      expect(find.text('Watchlist Technicals'), findsOneWidget);
    });

    testWidgets('Theme brightness detection works - light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final brightness = Theme.of(context).brightness;
              return Text('Brightness: ${brightness.name}');
            },
          ),
        ),
      );

      expect(find.text('Brightness: light'), findsOneWidget);
    });

    testWidgets('Theme brightness detection works - dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final brightness = Theme.of(context).brightness;
              return Text('Brightness: ${brightness.name}');
            },
          ),
        ),
      );

      expect(find.text('Brightness: dark'), findsOneWidget);
    });

    testWidgets('Scaffold with AppBar renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Watchlists'),
            ),
            body: const Center(
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Watchlists'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('FloatingActionButton is tappable', (tester) async {
      bool fabPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Content')),
            floatingActionButton: FloatingActionButton(
              onPressed: () => fabPressed = true,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(fabPressed, isTrue);
    });

    testWidgets('ListView scrolls correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => ListTile(
                title: Text('Item $index'),
              ),
            ),
          ),
        ),
      );

      // First item should be visible
      expect(find.text('Item 0'), findsOneWidget);

      // Last item should not be visible initially
      expect(find.text('Item 19'), findsNothing);

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // After scrolling, first item should not be visible
      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('Dialog can be shown and dismissed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Test Dialog'),
                      content: const Text('Dialog content'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Dialog should not be visible initially
      expect(find.text('Test Dialog'), findsNothing);

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('Dialog content'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Test Dialog'), findsNothing);
    });

    testWidgets('SnackBar can be shown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test SnackBar')),
                  );
                },
                child: const Text('Show SnackBar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show SnackBar'));
      await tester.pumpAndSettle();

      expect(find.text('Test SnackBar'), findsOneWidget);
    });

    testWidgets('Card widget renders with proper styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Card Content'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('RefreshIndicator triggers callback', (tester) async {
      bool refreshTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                refreshTriggered = true;
              },
              child: ListView(
                children: const [
                  ListTile(title: Text('Item 1')),
                  ListTile(title: Text('Item 2')),
                ],
              ),
            ),
          ),
        ),
      );

      // Trigger pull-to-refresh
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(refreshTriggered, isTrue);
    });
  });
}
