// Abstract interface for authentication service
// Implement this with your preferred auth provider

abstract class AuthService {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp(String email, String password);
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<String?> getCurrentUserId();
  Future<void> resetPassword(String email);
}
