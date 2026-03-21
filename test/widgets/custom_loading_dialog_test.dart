import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_on_app/widgets/custom_loading_dialog.dart';

void main() {
  testWidgets('CustomLoadingDialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomLoadingDialog(),
        ),
      ),
    );
    expect(find.byType(SizedBox), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
