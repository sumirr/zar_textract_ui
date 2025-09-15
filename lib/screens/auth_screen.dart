import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onSignInSuccess;
  final VoidCallback onSignUpSuccess;

  const AuthScreen({
    super.key,
    required this.onSignInSuccess,
    required this.onSignUpSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _currentIndex = 0; // 0: SignIn, 1: SignUp, 2: ForgotPassword

  @override
  Widget build(BuildContext context) {
    switch (_currentIndex) {
      case 1:
        return SignUpScreen(
          onSignUpSuccess: widget.onSignUpSuccess,
          onNavigateToSignIn: () => setState(() => _currentIndex = 0),
        );
      case 2:
        return ForgotPasswordScreen(
          onNavigateBack: () => setState(() => _currentIndex = 0),
        );
      default:
        return SignInScreen(
          onSignInSuccess: widget.onSignInSuccess,
          onNavigateToSignUp: () => setState(() => _currentIndex = 1),
          onNavigateToForgotPassword: () => setState(() => _currentIndex = 2),
        );
    }
  }
}