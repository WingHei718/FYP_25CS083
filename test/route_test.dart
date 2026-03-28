import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_on_app/route.dart';
import 'package:virtual_try_on_app/app_init.dart';
import 'package:virtual_try_on_app/screens/home_screen.dart';
import 'package:virtual_try_on_app/screens/main_screen.dart';
import 'package:virtual_try_on_app/screens/settings_screen.dart';

void main() {
  test('Routes map keys', () {
    final routes = Routes.getRouteMap();
    expect(routes.containsKey('/init'), true);
    expect(routes.containsKey('/main'), true);
    expect(routes.containsKey('/home'), true);
    expect(routes.containsKey('/settings'), true);
  });

  test('getRouteByName', () {
    expect(Routes.getRouteByName('/init'), isNotNull);
    expect(Routes.getRouteByName('/main'), isNotNull);
    expect(Routes.getRouteByName('/home'), isNotNull);
    expect(Routes.getRouteByName('/settings'), isNotNull);
    expect(Routes.getRouteByName('/unknown'), isNotNull);
  });

  testWidgets('Routes', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Container()));
    final BuildContext context = tester.element(find.byType(Container));
    final routes = Routes.getRouteMap();
    
    expect(routes['/init']!(context), isA<AppInit>());
    expect(routes['/main']!(context), isA<MainScreen>());
    expect(routes['/home']!(context), isA<HomeScreen>());
    expect(routes['/settings']!(context), isA<SettingsScreen>());
  });
}
