import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amma_food_city/widgets/circular_qty_control.dart';

void main() {
  group('CircularQtyControl', () {
    testWidgets('shows add button when quantity is 0', (tester) async {
      int currentQty = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularQtyControl(
              quantity: currentQty,
              onChanged: (qty) => currentQty = qty,
            ),
          ),
        ),
      );

      // Should show + button
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsNothing);
    });

    testWidgets('shows qty with +/- when quantity > 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularQtyControl(
              quantity: 3,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    });

    testWidgets('tapping + increments quantity', (tester) async {
      int result = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularQtyControl(
              quantity: 0,
              onChanged: (qty) => result = qty,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_rounded));
      expect(result, 1);
    });

    testWidgets('tapping - decrements quantity', (tester) async {
      int result = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularQtyControl(
              quantity: 3,
              onChanged: (qty) => result = qty,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove_rounded));
      expect(result, 2);
    });

    testWidgets('tapping - at qty 1 sets to 0 (delete)', (tester) async {
      int result = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularQtyControl(
              quantity: 1,
              onChanged: (qty) => result = qty,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove_rounded));
      expect(result, 0);
    });
  });
}
