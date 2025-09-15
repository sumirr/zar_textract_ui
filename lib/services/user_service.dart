// Abstract interface for user management
// Implement this with your preferred user management system

abstract class UserService {
  Future<Map<String, dynamic>> getUserProfile(String userId);
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data);
  Future<int> getUserUsageCount(String userId);
  Future<bool> hasActiveSubscription(String userId);
}
