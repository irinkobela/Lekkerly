// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lekkerly/main.dart';
import 'package:lekkerly/theme_provider.dart';

void main() {
  testWidgets('App loads and displays welcome message',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We must now provide the required 'onboardingComplete' parameter.
    // For testing purposes, we can set it to 'true' to bypass onboarding.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const LekkerlyApp(onboardingComplete: true),
      ),
    );

    // pumpAndSettle will wait for all animations and async tasks to complete.
    await tester.pumpAndSettle();

    // Verify that the welcome message on the main screen is displayed.
    // This is a more robust test for the new UI.
    expect(find.text("Let's get learning!"), findsOneWidget);
  });
}
