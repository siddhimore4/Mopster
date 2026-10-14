import 'package:flutter_test/flutter_test.dart';
import 'package:mopster/main.dart';
import 'package:mopster/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Mopster initial load and navigation smoke test',
      (WidgetTester tester) async {
    // Build Mopster app and trigger a frame.
    await tester.pumpWidget(const MopsterApp());

    // 1. Verify that the brand name Mopster is rendered on the splash screen
    expect(find.text(AppConstants.appName), findsOneWidget);

    // 2. Advance time past splash timer (2.2 seconds) to trigger transition to WelcomeScreen
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    // 3. Verify that WelcomeScreen is presented with Dhule city features
    expect(find.text('Welcome to Mopster'), findsOneWidget);
    expect(find.text('Select your Dhule Locality'), findsOneWidget);
  });
}
