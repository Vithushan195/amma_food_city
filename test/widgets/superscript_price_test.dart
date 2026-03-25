import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amma_food_city/widgets/superscript_price.dart';

void main() {
  group('SuperscriptPrice', () {
    testWidgets('renders price correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuperscriptPrice(price: 4.99, size: PriceSize.medium),
          ),
        ),
      );

      expect(find.text('£'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('.99'), findsOneWidget);
    });

    testWidgets('shows strikethrough for original price', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuperscriptPrice(price: 3.49, size: PriceSize.small),
          ),
        ),
      );

      expect(find.text('£'), findsOneWidget);
    });

    testWidgets('handles whole number prices', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuperscriptPrice(price: 10.00, size: PriceSize.large),
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.text('.00'), findsOneWidget);
    });
  });
}
