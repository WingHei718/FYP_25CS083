import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_try_on_app/models/theme_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ThemeProvider (System Default)', () async {
    final themeProvider = ThemeProvider();
    await Future.delayed(Duration.zero);
    expect(themeProvider.themeMode, ThemeMode.system);
    expect(themeProvider.themeModeString, 'System');
    final _ = themeProvider.isDarkMode;
  });

  test('ThemeProvider (Light)', () async {
    final themeProvider = ThemeProvider();
    await themeProvider.setThemeMode(ThemeMode.light);
    expect(themeProvider.themeMode, ThemeMode.light);
    expect(themeProvider.themeModeString, 'Light');
    expect(themeProvider.isDarkMode, false);
  });

  test('ThemeProvider (Dark)', () async {
    final themeProvider = ThemeProvider();
    await themeProvider.setThemeMode(ThemeMode.dark);
    expect(themeProvider.themeMode, ThemeMode.dark);
    expect(themeProvider.themeModeString, 'Dark');
    expect(themeProvider.isDarkMode, true);
  });
}
