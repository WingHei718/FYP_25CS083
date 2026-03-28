import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:virtual_try_on_app/models/product_model.dart';
import 'package:virtual_try_on_app/screens/product_screen.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../helpers/fake_web_view_helper.dart';
import '../helpers/asset_bundle_helper.dart';

class MockNavigatorObserver extends NavigatorObserver {
  bool didPushRoute = false;
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    didPushRoute = true;
    super.didPush(route, previousRoute);
  }
}

void main() {
  setUpAll(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });

  setUp(() {
     const MethodChannel channel = MethodChannel('flutter.baseflow.com/permissions/methods');
     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermissionStatus') return 1;
        return null;
      },
    );
  });

  // Create a sample ring product
  final product = ProductModel()
    ..setName = "Test Ring"
    ..setIsARSupported = true
    ..setModelPath = "test_model.glb"
    ..setRealImagePath = "test_image.png"
    ..setVirtualImagePath = "test_virtual.png";

  Widget createProductScreen() {
     return MaterialApp(
        home: DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: ProductScreen(product: product),
        ),
      );
  }

  testWidgets('ProductScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createProductScreen());
    expect(find.textContaining('Test Ring'), findsAtLeastNWidgets(2));
    expect(find.text('AR Supported: Yes'), findsOneWidget);
    expect(find.text('Virtual Try On'), findsOneWidget);
    expect(find.text('Image'), findsOneWidget);
    expect(find.text('3D Model'), findsOneWidget);
  });

  testWidgets('ProductScreen (Image Tab)', (WidgetTester tester) async {
     await tester.pumpWidget(createProductScreen());
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('ProductScreen (3D Model Tab)', (WidgetTester tester) async {
    await tester.pumpWidget(createProductScreen());
    await tester.tap(find.text('3D Model'));
    await tester.pumpAndSettle();
    expect(find.byType(Flutter3DViewer), findsOneWidget);
  });

  testWidgets('Navigating to ARCoreScreen', (WidgetTester tester) async {
    final observer = MockNavigatorObserver();
    await tester.pumpWidget(
       MaterialApp(
        home: DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: ProductScreen(product: product),
        ),
        navigatorObservers: [observer],
      ),
    );
    final VTOButtonFinder = find.widgetWithText(ElevatedButton, 'Virtual Try On');
    expect(VTOButtonFinder, findsOneWidget);
    await tester.tap(VTOButtonFinder);
    await tester.pump();
    expect(observer.didPushRoute, true);
  });
}
