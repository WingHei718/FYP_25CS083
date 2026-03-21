import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_try_on_app/models/product_model.dart';
import 'package:virtual_try_on_app/models/settings_model.dart';
import 'package:virtual_try_on_app/screens/arcore_screen.dart';
import 'package:virtual_try_on_app/services/arcore_service.dart';
import 'package:virtual_try_on_app/widgets/custom_loading_dialog.dart';

void mockPermissionChannel() {
  const MethodChannel channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
       switch (methodCall.method) {
          case 'checkPermissionStatus':
            return 1;
          case 'requestPermissions':
            return {0: 1};
          default:
            return null;
        }
    },
  );
}

void mockARCoreChannel() {
  const MethodChannel channel = MethodChannel('com.example/arcore');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'startARSession':
          return 'AR Session Started';
        case 'closeARSession':
            return 'AR Session Closed';
        default:
          return null;
      }
    },
  );
}

void main() {
  setUp(() {
    mockPermissionChannel();
    mockARCoreChannel();
  });

  testWidgets('ARCoreScreen (Init)', (WidgetTester tester) async {
    final product = ProductModel()
      ..setName = "Test Ring"
      ..setModelPath = "test.glb";

    final settings = SettingsModel();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
        ],
        child: MaterialApp(
          home: ARCoreScreen(product: product),
        ),
      ),
    );

    expect(find.byType(CustomLoadingDialog), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(AndroidView), findsOneWidget);

    final androidView = tester.widget<AndroidView>(find.byType(AndroidView));
    if (androidView.onPlatformViewCreated != null) {
      androidView.onPlatformViewCreated!(0);
    }
    await tester.pump(const Duration(seconds: 4));
    
    // Reload Button
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    
    // Menu Button
    expect(find.byIcon(Icons.tune), findsOneWidget);
  });
  
  testWidgets('ARCoreScreen (Control Panel)', (WidgetTester tester) async {
     tester.view.physicalSize = const Size(1080, 2400);
     tester.view.devicePixelRatio = 1.0;
     addTearDown(tester.view.resetPhysicalSize);

     final product = ProductModel()
      ..setName = "Test Ring"
      ..setModelPath = "test.glb";

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: SettingsModel()),
        ],
        child: MaterialApp(
          home: ARCoreScreen(product: product),
        ),
      ),
    );

    await tester.pumpAndSettle();
    ARCoreService().simulatePlaneDetected();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.text('Control Panel'), findsOneWidget);
    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));
    
    // Hand Tracking Switch
    final handTrackingSwitch = tester.widget<Switch>(switches.first);
    await tester.ensureVisible(switches.first);
    if (handTrackingSwitch.onChanged != null) {
        handTrackingSwitch.onChanged!(false); 
        handTrackingSwitch.onChanged!(true); 
        await tester.pumpAndSettle();
    }

    // Testing Mode Switch
    final testingModeSwitch = tester.widget<Switch>(switches.last);
    await tester.ensureVisible(switches.last);
    if (testingModeSwitch.onChanged != null) {
        testingModeSwitch.onChanged!(false); 
        testingModeSwitch.onChanged!(true); 
        await tester.pumpAndSettle();
    }

    // Target Finger
    final dropdownFinder = find.byType(DropdownButton<String>);
    await tester.ensureVisible(dropdownFinder);
    await tester.pumpAndSettle();
    expect(dropdownFinder, findsOneWidget);

    final dropdownWidget = tester.widget<DropdownButton<String>>(dropdownFinder);
    if (dropdownWidget.onChanged != null) {
       dropdownWidget.onChanged!('index');
       await tester.pumpAndSettle();
    }

    // Close
    final closeButtonFinder = find.byIcon(Icons.close); 
    await tester.ensureVisible(closeButtonFinder);
    await tester.tap(closeButtonFinder);
    await tester.pumpAndSettle();
  });

  testWidgets('ARCoreScreen (Permission error)', (WidgetTester tester) async {
    const MethodChannel channel = MethodChannel('flutter.baseflow.com/permissions/methods');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
         if (methodCall.method == 'checkPermissionStatus') return 0;
         if (methodCall.method == 'requestPermissions') return {0: 0};
         return null;
      },
    );

    final product = ProductModel()..setName = "Test Ring";
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: SettingsModel())],
        child: MaterialApp(home: ARCoreScreen(product: product)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  });
  
  testWidgets('ARCoreScreen (Reload Model)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final product = ProductModel()..setName = "Test Ring";
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: SettingsModel())],
        child: MaterialApp(home: ARCoreScreen(product: product)),
      ),
    );
    await tester.pumpAndSettle();

    final refreshBtnFinder = find.widgetWithIcon(FloatingActionButton, Icons.refresh);
    await tester.ensureVisible(refreshBtnFinder);
    final refreshBtn = tester.widget<FloatingActionButton>(refreshBtnFinder);
    refreshBtn.onPressed!();

    await tester.pump(Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  });

  testWidgets('ARCoreScreen (with disabled settings)', (WidgetTester tester) async {
    final product = ProductModel()..setName = "Test Ring";
    final settings = SettingsModel();
    SharedPreferences.setMockInitialValues({});
    await settings.initialize();
    await settings.setHandTrackingEnabled(false);
    await settings.setTestingModeEnabled(false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: settings)],
        child: MaterialApp(home: ARCoreScreen(product: product)),
      ),
    );
    await tester.pumpAndSettle();
    final androidView = tester.widget<AndroidView>(find.byType(AndroidView));
    if (androidView.onPlatformViewCreated != null) {
      androidView.onPlatformViewCreated!(0);
    }
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('ARCoreScreen (Dispose failure)', (WidgetTester tester) async {
    const MethodChannel arChannel = MethodChannel('com.example/arcore');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      arChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'closeARSession') {
          throw PlatformException(code: 'ERROR', message: 'Failed to close session');
        }
        return null;
      },
    );

    final product = ProductModel()..setName = "Test Ring";
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: SettingsModel())],
        child: MaterialApp(home: ARCoreScreen(product: product)),
      ),
    );

    await tester.pumpAndSettle();
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle(); 
  });
}
