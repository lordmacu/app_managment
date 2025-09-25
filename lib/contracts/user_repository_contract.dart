import '../models/user.dart';

abstract class UserRepositoryContract {
  Future<User?> getUserById(String id);
  Future<List<User>> getAllUsers();
  Future<String> saveUser(User user);
  Future<bool> updateUser(User user);
  Future<bool> deleteUser(String id);
  Future<bool> userExists(String id);
  Future<List<User>> searchUsersByName(String name);

  // Additional helper methods contracts
  Future<void> clearAllUsers();
  Future<int> getUserCount();
  Future<List<User>> getUsersWithCriteria({
    int? minAge,
    int? maxAge,
    bool? hasAddresses,
  });
 }
