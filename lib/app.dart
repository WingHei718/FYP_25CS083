import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_try_on_app/route.dart';
import 'package:virtual_try_on_app/models/theme_model.dart';
import 'package:virtual_try_on_app/models/settings_model.dart';
import 'package:virtual_try_on_app/widgets/app_theme.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey();

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsModel()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Virtual Try On App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            routes: Routes.getRouteMap(),
            initialRoute: '/init',
          );
        },
      ),
    );
  }
}