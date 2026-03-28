import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_on_app/app.dart';
import 'package:virtual_try_on_app/app_init.dart';

void main() {
  testWidgets('Initialization', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    expect(find.byType(AppInit), findsOneWidget);
    expect(find.text('CS4514 Project'), findsOneWidget);
  });
}
