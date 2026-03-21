import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_on_app/widgets/app_theme.dart';

void main() {
  test('Light Theme', () {
    final theme = AppTheme.lightTheme;
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, const Color(0xFFC1BAA1));
  });

  test('Dark Theme', () {
    final theme = AppTheme.darkTheme;
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, const Color(0xFFC9B194));
  });

  testWidgets('Switch Theme', (WidgetTester tester) async {
    final theme = AppTheme.lightTheme;
    final switchTheme = theme.switchTheme;
    
    final WidgetStateProperty<Color?>? thumbColor = switchTheme.thumbColor;
    expect(thumbColor?.resolve({WidgetState.selected}), theme.colorScheme.primary);
    expect(thumbColor?.resolve({}), null);

    final WidgetStateProperty<Color?>? trackColor = switchTheme.trackColor;
    expect(trackColor?.resolve({WidgetState.selected}), theme.colorScheme.primary.withOpacity(0.5));
    expect(trackColor?.resolve({}), null);
  });
}
