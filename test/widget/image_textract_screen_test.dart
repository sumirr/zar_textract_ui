import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zar_textract_app/screens/image_textract_screen.dart';

void main() {
  group('ImageTextractScreen Widget Tests', () {
    testWidgets('displays main screen with text extraction UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageTextractScreen(
            userName: 'Test User',
            userId: 'test-user-id',
            onSignOut: () {},
          ),
        ),
      );

      expect(find.text('Text Extractor'), findsOneWidget);
      expect(find.text('Extract Text from Images'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
    });

    testWidgets('shows bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageTextractScreen(
            userName: 'Test User',
            userId: 'test-user-id',
            onSignOut: () {},
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('shows floating action button for profile', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageTextractScreen(
            userName: 'Test User',
            userId: 'test-user-id',
            onSignOut: () {},
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('navigates to PDF screen when PDF tab is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageTextractScreen(
            userName: 'Test User',
            userId: 'test-user-id',
            onSignOut: () {},
          ),
        ),
      );

      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();

      expect(find.text('PDF Text Extraction'), findsOneWidget);
      expect(find.text('Select PDF File'), findsOneWidget);
    });

    testWidgets('navigates to history screen when History tab is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageTextractScreen(
            userName: 'Test User',
            userId: 'test-user-id',
            onSignOut: () {},
          ),
        ),
      );

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('Extraction History'), findsOneWidget);
    });

    testWidgets('navigates to profile screen when FAB is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageTextractScreen(
            userName: 'Test User',
            userId: 'test-user-id',
            onSignOut: () {},
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Update Profile'), findsOneWidget);
    });
  });
}