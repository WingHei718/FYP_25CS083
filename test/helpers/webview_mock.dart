import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:async';

// Simulate the mobile app as Web App for testing
class FakeWebViewPlatform extends Fake with MockPlatformInterfaceMixin implements WebViewPlatform {
  
  @override
  PlatformWebViewController createPlatformWebViewController(PlatformWebViewControllerCreationParams params) {
    return FakePlatformWebViewController();
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(PlatformNavigationDelegateCreationParams params) {
    return FakePlatformNavigationDelegate();
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(PlatformWebViewWidgetCreationParams params) {
    return FakePlatformWebViewWidget();
  }

  PlatformWebViewCookieManager createPlatformWebViewCookieManager(PlatformWebViewCookieManagerCreationParams params) {
    return FakePlatformWebViewCookieManager();
  }
}

class FakePlatformWebViewController extends Fake with MockPlatformInterfaceMixin implements PlatformWebViewController {
  
  @override
  Future<void> loadRequest(LoadRequestParams params) async {}
  
  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  
  @override
  Future<void> setBackgroundColor(dynamic color) async {}
  
  @override
  Future<void> setPlatformNavigationDelegate(PlatformNavigationDelegate delegate) async {}
  
  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {}
}

class FakePlatformNavigationDelegate extends Fake with MockPlatformInterfaceMixin implements PlatformNavigationDelegate {
    
  @override
  Future<void> setOnPageFinished(void Function(String) onPageFinished) async {}

  @override
  Future<void> setOnNavigationRequest(FutureOr<NavigationDecision> Function(NavigationRequest request) onNavigationRequest) async {}
      
   @override
  Future<void> setOnPageStarted(void Function(String url) onPageStarted) async {}

  @override
  Future<void> setOnProgress(void Function(int progress) onProgress) async {}

  @override
  Future<void> setOnWebResourceError(void Function(WebResourceError error) onWebResourceError) async {}
      
   @override
  Future<void> setOnUrlChange(void Function(UrlChange change) onUrlChange) async {}
  
  @override
  Future<void> setOnHttpError(void Function(HttpResponseError error) onHttpError) async {}
  
  @override
  Future<void> setOnHttpAuthRequest(void Function(HttpAuthRequest request) onHttpAuthRequest) async {}
}

class FakePlatformWebViewWidget extends Fake with MockPlatformInterfaceMixin implements PlatformWebViewWidget {
    
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class FakePlatformWebViewCookieManager extends Fake with MockPlatformInterfaceMixin implements PlatformWebViewCookieManager {}
