import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amma_food_city/widgets/lime_cta.dart';

void main() {
  group('LimeCta', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LimeCta(label: 'Add to Cart', onTap: () {}),
          ),
        ),
      );

      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('renders with icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LimeCta(
              label: 'Checkout',
              icon: Icons.arrow_forward_rounded,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('shows loading spinner when isLoading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LimeCta(label: 'Place Order', isLoading: true, onTap: () {}),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Place Order'), findsNothing);
    });

    testWidgets('fires onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LimeCta(label: 'Tap Me', onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(tapped, true);
    });

    testWidgets('disabled when onTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LimeCta(label: 'Disabled', onTap: null),
          ),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);
    });
  });
}
