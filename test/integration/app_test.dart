import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zar_textract_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('app starts and shows auth screen', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for Amplify to configure
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show auth screen initially
      expect(find.text('Zar Textract App'), findsOneWidget);
    });

    testWidgets('can navigate between sign up and sign in', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should start with sign up
      expect(find.text('Create Account'), findsOneWidget);

      // Tap to switch to sign in
      await tester.tap(find.text('Already have an account? Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}
