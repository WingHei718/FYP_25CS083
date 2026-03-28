import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:virtual_try_on_app/screens/home_screen.dart';
import 'package:virtual_try_on_app/screens/main_screen.dart';
import 'package:virtual_try_on_app/screens/settings_screen.dart';

import 'app_init.dart';

class Routes {
  static final Map<String, WidgetBuilder> _routes = {
    '/init': (_) => AppInit(),
    '/main': (_) => MainScreen(),
    '/home': (_) => HomeScreen(),
    '/settings': (_) => SettingsScreen(),
  };

  static Map<String, WidgetBuilder> getRouteMap() => _routes;

  static WidgetBuilder? getRouteByName(String name) {
    if (_routes.containsKey(name) == false) {
      return _routes['/main'];
    }
    return _routes[name];
  }
}
