import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_on_app/screens/home_screen.dart';
import 'package:virtual_try_on_app/screens/product_screen.dart';

void main() {
  testWidgets('HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Test Ring'), findsOneWidget);
    expect(find.text('Silver Ring (Wire Wrapping)'), findsOneWidget);
    expect(find.text('Silver Ring (Zigzag)'), findsOneWidget);
    expect(find.text('Blue Ring'), findsOneWidget);
  });

  testWidgets('Navigating to ProductScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    final productFinder = find.text('Test Ring');
    expect(productFinder, findsOneWidget);

    await tester.tap(productFinder);
    await tester.pumpAndSettle();

    expect(find.byType(ProductScreen), findsOneWidget);
    expect(find.text('Test Ring'), findsAtLeastNWidgets(1));
  });
}
