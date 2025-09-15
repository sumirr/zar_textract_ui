import 'package:flutter_test/flutter_test.dart'; // Keep this import for `test` and `group` functions
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:zar_textract_app/services/auth_service.dart'; // Ensure this path is correct

void main() {
  group('AuthService Unit Tests', () {
    test(
      'getUserAttributeValue returns correct value for existing attribute',
      () {
        final attributes = [
          AuthUserAttribute(
            userAttributeKey: AuthUserAttributeKey.email,
            value: 'test@example.com',
          ),
          AuthUserAttribute(
            userAttributeKey: AuthUserAttributeKey.name,
            value: 'Test User',
          ),
        ];

        final email = AuthService.getUserAttributeValue(
          attributes,
          AuthUserAttributeKey.email,
        );
        expect(email, 'test@example.com');

        final name = AuthService.getUserAttributeValue(
          attributes,
          AuthUserAttributeKey.name,
        );
        expect(name, 'Test User');
      },
    );

    test(
      'getUserAttributeValue returns empty string for missing attribute',
      () {
        final attributes = [
          AuthUserAttribute(
            userAttributeKey: AuthUserAttributeKey.name,
            value: 'Test User',
          ),
        ];

        final email = AuthService.getUserAttributeValue(
          attributes,
          AuthUserAttributeKey.email,
        );
        expect(email, ''); // Expect empty string for missing email

        final phone = AuthService.getUserAttributeValue(
          attributes,
          AuthUserAttributeKey.phoneNumber,
        );
        expect(phone, ''); // Expect empty string for missing phone number
      },
    );
  });
}
