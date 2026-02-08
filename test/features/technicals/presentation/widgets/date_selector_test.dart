import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:watchlist_technicals/features/technicals/presentation/widgets/date_selector.dart';

void main() {
  group('DateSelector', () {
    late bool backPressed;
    late bool forwardPressed;

    setUp(() {
      backPressed = false;
      forwardPressed = false;
    });

    Widget buildTestWidget({
      required DateTime selectedDate,
      required bool isToday,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: DateSelector(
              selectedDate: selectedDate,
              isToday: isToday,
              onBack: () => backPressed = true,
              onForward: () => forwardPressed = true,
            ),
          ),
        ),
      );
    }

    testWidgets('displays the formatted date', (tester) async {
      final testDate = DateTime(2024, 6, 15);
      await tester.pumpWidget(buildTestWidget(
        selectedDate: testDate,
        isToday: false,
      ));

      // Check that the date is displayed in the expected format
      expect(find.text('Jun 15, 2024'), findsOneWidget);
    });

    testWidgets('shows "up-to-date" label when isToday is true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime.now(),
        isToday: true,
      ));

      expect(find.text('up-to-date'), findsOneWidget);
    });

    testWidgets('hides "up-to-date" label when isToday is false',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      expect(find.text('up-to-date'), findsNothing);
    });

    testWidgets('shows left chevron (back) button', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('shows right chevron (forward) button when not today',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('hides right chevron (forward) button when isToday',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime.now(),
        isToday: true,
      ));

      // The forward button should not be visible
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('calls onBack when left chevron is tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(backPressed, isTrue);
      expect(forwardPressed, isFalse);
    });

    testWidgets('calls onForward when right chevron is tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(forwardPressed, isTrue);
      expect(backPressed, isFalse);
    });

    testWidgets('left button has "Previous day" tooltip', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      final leftButton = find.ancestor(
        of: find.byIcon(Icons.chevron_left),
        matching: find.byType(IconButton),
      );

      expect(leftButton, findsOneWidget);
      final widget = tester.widget<IconButton>(leftButton);
      expect(widget.tooltip, 'Previous day');
    });

    testWidgets('right button has "Next day" tooltip', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      final rightButton = find.ancestor(
        of: find.byIcon(Icons.chevron_right),
        matching: find.byType(IconButton),
      );

      expect(rightButton, findsOneWidget);
      final widget = tester.widget<IconButton>(rightButton);
      expect(widget.tooltip, 'Next day');
    });

    testWidgets('displays different dates correctly', (tester) async {
      final dateFormat = DateFormat('MMM dd, yyyy');

      // Test January 1st
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 1, 1),
        isToday: false,
      ));
      expect(find.text(dateFormat.format(DateTime(2024, 1, 1))), findsOneWidget);

      // Test December 31st
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 12, 31),
        isToday: false,
      ));
      await tester.pumpAndSettle();
      expect(
          find.text(dateFormat.format(DateTime(2024, 12, 31))), findsOneWidget);

      // Test leap year date
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 2, 29),
        isToday: false,
      ));
      await tester.pumpAndSettle();
      expect(
          find.text(dateFormat.format(DateTime(2024, 2, 29))), findsOneWidget);
    });

    testWidgets('has proper container decoration', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      // Find the Container with border decoration
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('uses compact visual density for buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      final leftButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.chevron_left),
          matching: find.byType(IconButton),
        ),
      );

      expect(leftButton.visualDensity, VisualDensity.compact);
    });

    testWidgets('animates visibility of forward button', (tester) async {
      // Start with isToday = true (forward hidden)
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime.now(),
        isToday: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsNothing);

      // Change to isToday = false (forward should appear)
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      // AnimatedSize needs time to animate
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('maintains Row structure with proper children', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDate: DateTime(2024, 6, 15),
        isToday: false,
      ));

      // Should have a Row containing the buttons and date
      expect(find.byType(Row), findsWidgets);

      // Should have exactly 2 IconButtons when not today
      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsNWidgets(2));
    });
  });
}
