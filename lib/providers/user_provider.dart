import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../contracts/user_service_contract.dart';

/// User Provider for state management following SOLID principles
/// S - Single Responsibility: Only manages user-related UI state
/// O - Open/Closed: Can be extended with new state management features
/// D - Dependency Inversion: Depends on UserServiceContract abstraction
class UserProvider with ChangeNotifier {
  UserServiceContract _userService;

  UserProvider(this._userService);
   // Private state variables
  List<User> _users = [];
  User? _currentUser;
  User? _selectedUser;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  List<User> _filteredUsers = [];

  // Getters for accessing state
  List<User> get users => List.unmodifiable(_users);
  User? get currentUser => _currentUser;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  List<User> get filteredUsers => List.unmodifiable(_filteredUsers);
  bool get hasUsers => _users.isNotEmpty;
  bool get hasError => _errorMessage != null;
  int get userCount => _users.length;

  void updateService(UserServiceContract service) {
    _userService = service;
  }

  /// Load users once at app start (idempotent).
  Future<void> bootstrap() async {
    if (_users.isEmpty && !_isLoading) {
      await loadUsers();
    }
  }

  /// Load all users from the service
  Future<void> loadUsers() async {
    _setLoading(true);
    _clearError();

    try {
      _users = await _userService.getAllUsers();
      _applySearchFilter();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAllUsers() async {
    try {
      await _userService.deleteAllUsers();

      // Clear local state
      _users.clear();
      _filteredUsers.clear();
      _currentUser = null;
      _selectedUser = null;

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete all users: $e');
      return false;
    }
  }

  /// Create a new user
  Future<bool> createUser({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    List<Address>? addresses,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final userId = await _userService.createUser(
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        addresses: addresses,
      );

      // Refresh users list
      await loadUsers();

      // Set the newly created user as current
      final newUser = _users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception('Created user not found'),
      );
      setCurrentUser(newUser);

      return true;
    } catch (e) {
      _setError('Failed to create user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing user
  Future<bool> updateUser(User user) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _userService.updateUser(user);

      if (success) {
        // Update local state
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = user;
        }

        // Update current user if it's the same
        if (_currentUser?.id == user.id) {
          _currentUser = user;
        }

        // Update selected user if it's the same
        if (_selectedUser?.id == user.id) {
          _selectedUser = user;
        }

        _applySearchFilter();
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError('Failed to update user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a user
  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _userService.deleteUser(userId);

      if (success) {
        // Remove from local state
        _users.removeWhere((user) => user.id == userId);

        // Clear current/selected user if it was deleted
        if (_currentUser?.id == userId) {
          _currentUser = null;
        }
        if (_selectedUser?.id == userId) {
          _selectedUser = null;
        }

        _applySearchFilter();
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError('Failed to delete user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Search users by name
  Future<void> searchUsers(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_users);
    } else {
      _setLoading(true);
      _clearError();

      try {
        _filteredUsers = await _userService.searchUsersByName(_searchQuery);
        notifyListeners();
      } catch (e) {
        _setError('Failed to search users: $e');
        _filteredUsers = [];
      } finally {
        _setLoading(false);
      }
    }

    notifyListeners();
  }

  /// Add address to user
  Future<bool> addAddressToUser(String userId, Address address) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _userService.addAddressToUser(userId, address);

      if (success) {
        // Refresh the specific user
        await _refreshUser(userId);
      }

      return success;
    } catch (e) {
      _setError('Failed to add address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove address from user
  Future<bool> removeAddressFromUser(String userId, String addressId) async {
    _setLoading(true);
    _clearError();

    try {
      final success =
          await _userService.removeAddressFromUser(userId, addressId);

      if (success) {
        // Refresh the specific user
        await _refreshUser(userId);
      }

      return success;
    } catch (e) {
      _setError('Failed to remove address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user address
  Future<bool> updateUserAddress(
      String userId, String addressId, Address updatedAddress) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _userService.updateUserAddress(
          userId, addressId, updatedAddress);

      if (success) {
        // Refresh the specific user
        await _refreshUser(userId);
      }

      return success;
    } catch (e) {
      _setError('Failed to update address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Set primary address for user
  Future<bool> setPrimaryAddress(String userId, String addressId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _userService.setPrimaryAddress(userId, addressId);

      if (success) {
        // Refresh the specific user
        await _refreshUser(userId);
      }

      return success;
    } catch (e) {
      _setError('Failed to set primary address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }



  /// Get adult users
  Future<void> getAdultUsers() async {
    _setLoading(true);
    _clearError();

    try {
      _filteredUsers = await _userService.getAdultUsers();
      notifyListeners();
    } catch (e) {
      _setError('Fallo al cargar Adultos: $e');
      _filteredUsers = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> getUserById(String id) async {
    if (id.trim().isEmpty) {
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final user = await _userService.getUserById(id);
      return user;
    } catch (e) {
      _setError('Fallo al cargar el usuario: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get minor users
  Future<void> getMinorUsers() async {
    _setLoading(true);
    _clearError();

    try {
      _filteredUsers = await _userService.getMinorUsers();
      notifyListeners();
    } catch (e) {
      _setError('Fallo al cargar niños: $e');
      _filteredUsers = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Get users with addresses
  Future<void> getUsersWithAddresses() async {
    _setLoading(true);
    _clearError();

    try {
      _filteredUsers = await _userService.getUsersWithAddresses();
      notifyListeners();
    } catch (e) {
      _setError('Fallo al cargar direcciones: $e');
      _filteredUsers = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>?> getUserStatistics() async {
    _setLoading(true);
    _clearError();

    try {
      final stats = await _userService.getUserStatistics();
      return stats;
    } catch (e) {
      _setError('Fallo al cargar estadisticas: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Set current user (for forms, editing, etc.)
  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Set selected user (for viewing details)
  void setSelectedUser(User? user) {
    _selectedUser = user;
    notifyListeners();
  }

  /// Clear current user
  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }

  /// Clear selected user
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  /// Clear search and show all users
  void clearSearch() {
    _searchQuery = '';
    _filteredUsers = List.from(_users);
    notifyListeners();
  }

  /// Reset all filters and show all users
  void resetFilters() {
    _searchQuery = '';
    _filteredUsers = List.from(_users);
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadUsers();
  }

  /// Validate user data before operations
  bool validateUserData({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) {
    return _userService.validateUserData(
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
    );
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_users);
    } else {
      _filteredUsers = _users.where((user) {
        final fullName = user.fullName.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return fullName.contains(query);
      }).toList();
    }
  }

  Future<void> _refreshUser(String userId) async {
    try {
      final updatedUser = await _userService.getUserById(userId);
      if (updatedUser != null) {
        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _users[index] = updatedUser;
        }

        if (_currentUser?.id == userId) {
          _currentUser = updatedUser;
        }

        if (_selectedUser?.id == userId) {
          _selectedUser = updatedUser;
        }

        _applySearchFilter();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('NO se pudo recargar el usuario: $e');
    }
  }




  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
