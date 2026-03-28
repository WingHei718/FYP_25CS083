import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:virtual_try_on_app/app_init.dart';
import 'package:virtual_try_on_app/models/settings_model.dart';

void main() {
  testWidgets('AppInit', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: SettingsModel()),
        ],
        child: MaterialApp(
          home: AppInit(),
        ),
      ),
    );

    expect(find.text('CS4514 Project'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('Tap Start button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: SettingsModel()),
        ],
        child: MaterialApp(
          home: AppInit(),
          routes: {
            '/main': (context) => const Scaffold(body: Text('Main Screen Content')),
          },
        ),
      ),
    );

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Main Screen Content'), findsOneWidget);
  });
}
