import '../models/user.dart';
import '../models/address.dart';


abstract class UserServiceContract {
  // Core user operations
  Future<User?> getUserById(String id);
  Future<List<User>> getAllUsers();
  Future<String> createUser({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    List<Address>? addresses,
  });
  Future<bool> updateUser(User user);
  Future<bool> deleteUser(String id);
  Future<bool> userExists(String id);

  // User search and filtering
  Future<List<User>> searchUsersByName(String name);
  Future<List<User>> getAdultUsers();
  Future<List<User>> getMinorUsers();
  Future<List<User>> getUsersWithAddresses();

  // Address management
  Future<bool> addAddressToUser(String userId, Address address);
  Future<bool> removeAddressFromUser(String userId, String addressId);
  Future<bool> updateUserAddress(
      String userId, String addressId, Address updatedAddress);
  Future<bool> setPrimaryAddress(String userId, String addressId);

  // User validation and utilities
  bool validateUserData({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  });
  bool validateUserAge(DateTime birthDate);
  String generateUserId();

  // Statistics and analytics
  Future<int> getUserCount();
  Future<Map<String, dynamic>> getUserStatistics();
  Future<List<User>> getRecentUsers({int days = 30});

  // Bulk operations
  Future<List<String>> createMultipleUsers(
      List<Map<String, dynamic>> usersData);
  Future<bool> deleteAllUsers();
}
