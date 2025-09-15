import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'services/amplify_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'screens/auth_screen.dart';
import 'screens/image_textract_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthUser? _currentUser;
  String _userEmail = '';
  String _userName = '';
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _configureAmplify();
    _themeService.loadTheme();
  }

  Future<void> _configureAmplify() async {
    try {
      await AmplifyService.configure();
      _listenToAuthChanges();
    } on AmplifyException catch (e) {
      safePrint('Failed to configure Amplify: ${e.message}');
    }
  }

  void _listenToAuthChanges() {
    Amplify.Hub.listen(HubChannel.Auth, (HubEvent event) {
      switch (event.eventName) {
        case 'SIGNED_IN':
          _fetchCurrentUser();
          break;
        case 'SIGNED_OUT':
          setState(() {
            _currentUser = null;
            _userEmail = '';
            _userName = '';
          });
          safePrint('User signed out via Hub event.');
          break;
        case 'USER_DELETED':
          setState(() {
            _currentUser = null;
            _userEmail = '';
            _userName = '';
          });
          safePrint('User deleted.');
          break;
        case 'SESSION_EXPIRED':
          safePrint('Session expired. Please sign in again.');
          Amplify.Auth.signOut();
          break;
        default:
          safePrint('Auth event type: ${event.eventName}');
      }
    });
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final userInfo = await AuthService.getCurrentUserInfo();
    if (userInfo != null) {
      setState(() {
        _currentUser = userInfo['user'];
        _userEmail = userInfo['email'];
        _userName = userInfo['name'];
      });
      safePrint('User is signed in: ${_currentUser!.username}');
    } else {
      setState(() {
        _currentUser = null;
        _userEmail = '';
        _userName = '';
      });
      safePrint('No user is currently signed in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        return MaterialApp(
          title: 'Text Extractor',
          theme: _themeService.lightTheme,
          darkTheme: _themeService.darkTheme,
          themeMode: _themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: AmplifyService.isConfigured
              ? (_currentUser != null
                    ? _buildAuthenticatedScreen()
                    : _buildAuthScreen())
              : Scaffold(
                  appBar: AppBar(title: const Text('Text Extractor')),
                  body: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildAuthScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Extractor')),
      body: AuthScreen(
        onSignInSuccess: _fetchCurrentUser,
        onSignUpSuccess: _fetchCurrentUser,
      ),
    );
  }

  Widget _buildAuthenticatedScreen() {
    return ImageTextractScreen(
      userName: _userName.isNotEmpty
          ? _userName
          : _currentUser!.username,
      userId: _currentUser!.userId,
      onSignOut: _signOut,
    );
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      setState(() {
        _currentUser = null;
        _userEmail = '';
        _userName = '';
      });
    } on AuthException catch (e) {
      safePrint('Error signing out: ${e.message}');
    }
  }
}

