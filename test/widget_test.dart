import 'package:flutter_test/flutter_test.dart';
import 'package:ev_master/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EvMasterApp());

    // Verify that the login screen is present
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}

