import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_try_on_app/models/settings_model.dart';
import 'package:virtual_try_on_app/models/theme_model.dart';
import 'package:virtual_try_on_app/screens/settings_screen.dart';

void main() {
  late ThemeProvider themeProvider;
  late SettingsModel settingsModel;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settingsModel = SettingsModel();
    await settingsModel.initialize();
  });

  Widget createSettingsScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          themeProvider = ThemeProvider();
          return themeProvider;
        }),
        ChangeNotifierProvider.value(
          value: settingsModel,
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SettingsScreen()),
      ),
    );
  }

  testWidgets('SettingsScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsScreen());
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('AR Settings'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('SettingsScreen (Change Theme)', (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsScreen());
    final darkModeOption = find.text('Dark Mode');
    expect(darkModeOption, findsOneWidget);
    await tester.tap(darkModeOption);
    await tester.pumpAndSettle();
    expect(themeProvider.themeMode, ThemeMode.dark);
  });

  testWidgets('SettingsScreen (Hand Tracking)', (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsScreen());
    final scrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(find.text('Hand Tracking'), 500.0, scrollable: scrollable);
    expect(settingsModel.handTrackingEnabled, true);
    final HandTrackingRowFinder = find.ancestor(
      of: find.text('Hand Tracking'),
      matching: find.byType(Row),
    ).first;
    final HandTrackingSwitchFinder = find.descendant(
      of: HandTrackingRowFinder,
      matching: find.byType(Switch),
    );
    expect(HandTrackingSwitchFinder, findsOneWidget);

    await tester.tap(HandTrackingSwitchFinder);
    await tester.pumpAndSettle();

    expect(settingsModel.handTrackingEnabled, false);
  });
  
  testWidgets('SettingsScreen (Testing Mode)', (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsScreen());

    final scrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(find.text('Testing Mode'), 500.0, scrollable: scrollable);
    expect(settingsModel.testingModeEnabled, true);

    final TestingModeRowFinder = find.ancestor(
      of: find.text('Testing Mode'),
      matching: find.byType(Row),
    ).first;
    
    final TestingModeSwitchFinder = find.descendant(
      of: TestingModeRowFinder,
      matching: find.byType(Switch),
    );

    expect(TestingModeSwitchFinder, findsOneWidget);

    await tester.tap(TestingModeSwitchFinder);
    await tester.pumpAndSettle();

    expect(settingsModel.testingModeEnabled, false);
  });

  testWidgets('SettingsScreen (Target Finger)', (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsScreen());
    final scrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(find.text('Target Finger'), 500.0, scrollable: scrollable);
    expect(settingsModel.targetFinger, 'ring');

    final TargetFingerDropdownFinder = find.byType(DropdownButton<String>);
    await tester.tap(TargetFingerDropdownFinder);
    await tester.pumpAndSettle();

    final indexItem = find.text('Index').last;
    await tester.tap(indexItem);
    await tester.pumpAndSettle();

    expect(settingsModel.targetFinger, 'index');
  });
}
