import '../models/user.dart';
import '../models/address.dart';
import '../contracts/user_service_contract.dart';
import '../contracts/user_repository_contract.dart';

/// Implementation of UserServiceContract following SOLID principles
/// S - Single Responsibility: Only handles user business logic
/// O - Open/Closed: Can be extended without modification
/// L - Liskov Substitution: Can replace UserServiceContract interface
/// D - Dependency Inversion: Depends on UserRepositoryContract abstraction
class UserServiceImpl implements UserServiceContract {
  final UserRepositoryContract _userRepository;

  const UserServiceImpl(this._userRepository);

  @override
  Future<User?> getUserById(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      return await _userRepository.getUserById(id);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      return await _userRepository.getAllUsers();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  @override
  Future<String> createUser({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    List<Address>? addresses,
  }) async {
    // Validate input data
    if (!validateUserData(
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
    )) {
      throw ArgumentError('Invalid user data provided');
    }
    try {
      // Create user with auto-generated ID
      final user = User.create(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        birthDate: birthDate,
        addresses: addresses ?? [],
      );

      // Save user to repository
      final userId = await _userRepository.saveUser(user);
      return userId;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<bool> updateUser(User user) async {
    if (!user.isValid) {
      throw ArgumentError('Invalid user data');
    }

    try {
      return await _userRepository.updateUser(user);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<bool> deleteUser(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      return await _userRepository.deleteUser(id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<bool> userExists(String id) async {
    if (id.trim().isEmpty) {
      return false;
    }

    try {
      return await _userRepository.userExists(id);
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }

  @override
  Future<List<User>> searchUsersByName(String name) async {
    if (name.trim().isEmpty) {
      return [];
    }

    try {
      return await _userRepository.searchUsersByName(name.trim());
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  @override
  Future<List<User>> getAdultUsers() async {
    try {
      final allUsers = await _userRepository.getAllUsers();
      return allUsers.where((user) => user.isAdult).toList();
    } catch (e) {
      throw Exception('Failed to get adult users: $e');
    }
  }

  @override
  Future<List<User>> getMinorUsers() async {
    try {
      final allUsers = await _userRepository.getAllUsers();
      return allUsers.where((user) => !user.isAdult).toList();
    } catch (e) {
      throw Exception('Failed to get minor users: $e');
    }
  }

  @override
  Future<List<User>> getUsersWithAddresses() async {
    try {
      return await _userRepository.getUsersWithCriteria(hasAddresses: true);
    } catch (e) {
      throw Exception('Failed to get users with addresses: $e');
    }
  }

  @override
  Future<bool> addAddressToUser(String userId, Address address) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (!address.isValid) {
      throw ArgumentError('Invalid address data');
    }

    try {
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return false;
      }

      // If this is the first address, make it primary
      final updatedAddress =
          user.addresses.isEmpty ? address.markAsPrimary() : address;

      final updatedUser = user.addAddress(updatedAddress);
      return await _userRepository.updateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to add address to user: $e');
    }
  }

  @override
  Future<bool> removeAddressFromUser(String userId, String addressId) async {
    if (userId.trim().isEmpty || addressId.trim().isEmpty) {
      throw ArgumentError('User ID and Address ID cannot be empty');
    }

    try {
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return false;
      }

      final updatedUser = user.removeAddress(addressId);
      return await _userRepository.updateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to remove address from user: $e');
    }
  }

  @override
  Future<bool> updateUserAddress(
      String userId, String addressId, Address updatedAddress) async {
    if (userId.trim().isEmpty || addressId.trim().isEmpty) {
      throw ArgumentError('User ID and Address ID cannot be empty');
    }

    if (!updatedAddress.isValid) {
      throw ArgumentError('Invalid address data');
    }

    try {
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return false;
      }

      final updatedUser = user.updateAddress(addressId, updatedAddress);
      return await _userRepository.updateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to update user address: $e');
    }
  }

  @override
  Future<bool> setPrimaryAddress(String userId, String addressId) async {
    if (userId.trim().isEmpty || addressId.trim().isEmpty) {
      throw ArgumentError('User ID and Address ID cannot be empty');
    }

    try {
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return false;
      }



      // Update all addresses: set target as primary, others as secondary
      final updatedAddresses = user.addresses.map((addr) {
        if (addr.id == addressId) {
          return addr.markAsPrimary();
        } else {
          return addr.markAsSecondary();
        }
      }).toList();

      final updatedUser = user.copyWith(addresses: updatedAddresses);
      return await _userRepository.updateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to set primary address: $e');
    }
  }

  @override
  bool validateUserData({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) {
    // Check for empty names
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return false;
    }

    // Check for valid birth date
    if (!validateUserAge(birthDate)) {
      return false;
    }

    // Check for reasonable name lengths
    if (firstName.trim().length < 2 || lastName.trim().length < 2) {
      return false;
    }

    // Check for maximum name lengths
    if (firstName.trim().length > 50 || lastName.trim().length > 50) {
      return false;
    }

    return true;
  }

  @override
  bool validateUserAge(DateTime birthDate) {
    final now = DateTime.now();

    // Birth date cannot be in the future
    if (birthDate.isAfter(now)) {
      return false;
    }

    // Calculate age
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    // Age must be reasonable (0-150 years)
    return age >= 0 && age <= 150;
  }

  @override
  String generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Future<int> getUserCount() async {
    try {
      return await _userRepository.getUserCount();
    } catch (e) {
      throw Exception('Failed to get user count: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final allUsers = await _userRepository.getAllUsers();
      final totalUsers = allUsers.length;

      if (totalUsers == 0) {
        return {
          'totalUsers': 0,
          'adultUsers': 0,
          'minorUsers': 0,
          'usersWithAddresses': 0,
          'usersWithoutAddresses': 0,
          'averageAge': 0.0,
          'addressPerUser': 0.0,
        };
      }

      final adultUsers = allUsers.where((user) => user.isAdult).length;
      final minorUsers = totalUsers - adultUsers;
      final usersWithAddresses =
          allUsers.where((user) => user.addresses.isNotEmpty).length;
      final usersWithoutAddresses = totalUsers - usersWithAddresses;

      final totalAge = allUsers.map((user) => user.age).reduce((a, b) => a + b);
      final averageAge = totalAge / totalUsers;

      final totalAddresses =
          allUsers.map((user) => user.addresses.length).reduce((a, b) => a + b);
      final addressPerUser = totalAddresses / totalUsers;

      return {
        'totalUsers': totalUsers,
        'adultUsers': adultUsers,
        'minorUsers': minorUsers,
        'usersWithAddresses': usersWithAddresses,
        'usersWithoutAddresses': usersWithoutAddresses,
        'averageAge': double.parse(averageAge.toStringAsFixed(1)),
        'addressPerUser': double.parse(addressPerUser.toStringAsFixed(1)),
      };
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }

  @override
  Future<List<User>> getRecentUsers({int days = 30}) async {
    try {
      final allUsers = await _userRepository.getAllUsers();
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      // Filter users created in the last N days
      // Note: This assumes user ID contains timestamp (as we generate it)
      return allUsers.where((user) {
        try {
          final createdTimestamp = int.parse(user.id);
          final createdDate =
              DateTime.fromMillisecondsSinceEpoch(createdTimestamp);
          return createdDate.isAfter(cutoffDate);
        } catch (e) {
          // If ID is not a timestamp, include the user
          return true;
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent users: $e');
    }
  }

  @override
  Future<List<String>> createMultipleUsers(
      List<Map<String, dynamic>> usersData) async {
    if (usersData.isEmpty) {
      return [];
    }

    try {
      final userIds = <String>[];

      for (final userData in usersData) {
        final firstName = userData['firstName'] as String? ?? '';
        final lastName = userData['lastName'] as String? ?? '';
        final birthDateStr = userData['birthDate'] as String? ?? '';

        if (firstName.isEmpty || lastName.isEmpty || birthDateStr.isEmpty) {
          throw ArgumentError('Missing required user data');
        }

        final birthDate = DateTime.parse(birthDateStr);
        final addresses = (userData['addresses'] as List<dynamic>?)
                ?.map((addrData) =>
                    Address.fromMap(addrData as Map<String, dynamic>))
                .toList() ??
            <Address>[];

        final userId = await createUser(
          firstName: firstName,
          lastName: lastName,
          birthDate: birthDate,
          addresses: addresses,
        );

        userIds.add(userId);
      }

      return userIds;
    } catch (e) {
      throw Exception('Failed to create multiple users: $e');
    }
  }

  @override
  Future<bool> deleteAllUsers() async {
    try {
      await _userRepository.clearAllUsers();
      return true;
    } catch (e) {
      throw Exception('Failed to delete all users: $e');
    }
  }
}
