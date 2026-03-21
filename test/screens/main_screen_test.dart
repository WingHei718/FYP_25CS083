import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_try_on_app/models/settings_model.dart';
import 'package:virtual_try_on_app/models/theme_model.dart';
import 'package:virtual_try_on_app/screens/home_screen.dart';
import 'package:virtual_try_on_app/screens/main_screen.dart';
import 'package:virtual_try_on_app/screens/settings_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createMainScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: SettingsModel()),
      ],
      child: const MaterialApp(
        home: MainScreen(),
      ),
    );
  }

  testWidgets('MainScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createMainScreen());
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Test Ring'), findsAtLeastNWidgets(1));
  });

  testWidgets('Navigating to SettingsScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createMainScreen());
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
  });
}
