import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zar_textract_app/screens/auth_screen.dart';

void main() {
  group('AuthScreen Widget Tests', () {
    testWidgets('displays sign in form by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthScreen(
            onSignInSuccess: () {},
            onSignUpSuccess: () {},
          ),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('navigates to sign up form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthScreen(
            onSignInSuccess: () {},
            onSignUpSuccess: () {},
          ),
        ),
      );

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('navigates to forgot password', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthScreen(
            onSignInSuccess: () {},
            onSignUpSuccess: () {},
          ),
        ),
      );

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.text('Send Reset Code'), findsOneWidget);
    });
  });
}