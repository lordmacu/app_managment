import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:user_management_app/contracts/user_repository_contract.dart';
import 'package:user_management_app/models/address.dart';
import '../models/user.dart';

/// SQLite implementation of UserRepository
/// S - Single Responsibility: Only handles user data persistence with SQLite
/// L - Liskov Substitution: Can replace UserRepository interface
class UserRepositoryImpl implements UserRepositoryContract {
  static Database? _database;
  static const String _tableName = 'users';

  /// Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize SQLite database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'user_management.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  /// Create database tables
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        addresses TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE addresses (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        country TEXT NOT NULL,
        state TEXT NOT NULL,
        city TEXT NOT NULL,
        detailedAddress TEXT,
        isPrimary INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES $_tableName (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db
        .execute('CREATE INDEX idx_users_firstName ON $_tableName (firstName)');
    await db
        .execute('CREATE INDEX idx_users_lastName ON $_tableName (lastName)');
    await db.execute('CREATE INDEX idx_addresses_userId ON addresses (userId)');
  }

  @override
  Future<User?> getUserById(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> userMaps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (userMaps.isEmpty) {
      return null;
    }

    final userMap = userMaps.first;

    // Get addresses for this user
    final List<Map<String, dynamic>> addressMaps = await db.query(
      'addresses',
      where: 'userId = ?',
      whereArgs: [id],
    );

    // Convert address maps to Address objects
    final addresses = addressMaps
        .map((addrMap) => Address.fromMap({
              'id': addrMap['id'],
              'country': addrMap['country'],
              'state': addrMap['state'],
              'city': addrMap['city'],
              'detailedAddress': addrMap['detailedAddress'],
              'isPrimary': addrMap['isPrimary'] == 1,
            }))
        .toList();

    return User.fromMap({
      ...userMap,
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
    });
  }

  @override
  Future<List<User>> getAllUsers() async {
    final db = await database;

    final List<Map<String, dynamic>> userMaps = await db.query(_tableName);

    final users = <User>[];

    for (final userMap in userMaps) {
      final userId = userMap['id'] as String;

      // Get addresses for this user
      final List<Map<String, dynamic>> addressMaps = await db.query(
        'addresses',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      // Convert address maps to Address objects
      final addresses = addressMaps
          .map((addrMap) => Address.fromMap({
                'id': addrMap['id'],
                'country': addrMap['country'],
                'state': addrMap['state'],
                'city': addrMap['city'],
                'detailedAddress': addrMap['detailedAddress'],
                'isPrimary': addrMap['isPrimary'] == 1,
              }))
          .toList();

      final user = User.fromMap({
        ...userMap,
        'addresses': addresses.map((addr) => addr.toMap()).toList(),
      });

      users.add(user);
    }

    return users;
  }

  @override
  Future<String> saveUser(User user) async {
    if (!user.isValid) {
      throw ArgumentError('Invalid user data');
    }

    final db = await database;

    // Start transaction to ensure data consistency
    await db.transaction((txn) async {
      // Insert user
      await txn.insert(
        _tableName,
        {
          'id': user.id,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'birthDate': user.birthDate.toIso8601String(),
          'addresses':
              jsonEncode(user.addresses.map((addr) => addr.toMap()).toList()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert addresses
      for (final address in user.addresses) {
        await txn.insert(
          'addresses',
          {
            'id': address.id,
            'userId': user.id,
            'country': address.country,
            'state': address.state,
            'city': address.city,
            'detailedAddress': address.detailedAddress,
            'isPrimary': address.isPrimary ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    return user.id;
  }

  @override
  Future<bool> updateUser(User user) async {
    if (!user.isValid) {
      throw ArgumentError('Invalid user data');
    }

    final db = await database;

    // Check if user exists
    final exists = await userExists(user.id);
    if (!exists) {
      return false;
    }

    // Start transaction to ensure data consistency
    await db.transaction((txn) async {
      // Update user
      await txn.update(
        _tableName,
        {
          'firstName': user.firstName,
          'lastName': user.lastName,
          'birthDate': user.birthDate.toIso8601String(),
          'addresses':
              jsonEncode(user.addresses.map((addr) => addr.toMap()).toList()),
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );

      // Delete old addresses
      await txn.delete(
        'addresses',
        where: 'userId = ?',
        whereArgs: [user.id],
      );

      // Insert new addresses
      for (final address in user.addresses) {
        await txn.insert(
          'addresses',
          {
            'id': address.id,
            'userId': user.id,
            'country': address.country,
            'state': address.state,
            'city': address.city,
            'detailedAddress': address.detailedAddress,
            'isPrimary': address.isPrimary ? 1 : 0,
          },
        );
      }
    });

    return true;
  }

  @override
  Future<bool> deleteUser(String id) async {
    final db = await database;

    final result = await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    // Addresses will be automatically deleted due to CASCADE
    return result > 0;
  }

  @override
  Future<bool> userExists(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  @override
  Future<List<User>> searchUsersByName(String name) async {
    if (name.trim().isEmpty) {
      return [];
    }

    final db = await database;
    final searchTerm = '%${name.toLowerCase()}%';

    final List<Map<String, dynamic>> userMaps = await db.query(
      _tableName,
      where: 'LOWER(firstName) LIKE ? OR LOWER(lastName) LIKE ?',
      whereArgs: [searchTerm, searchTerm],
    );

    final users = <User>[];

    for (final userMap in userMaps) {
      final userId = userMap['id'] as String;

      // Get addresses for this user
      final List<Map<String, dynamic>> addressMaps = await db.query(
        'addresses',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      // Convert address maps to Address objects
      final addresses = addressMaps
          .map((addrMap) => Address.fromMap({
                'id': addrMap['id'],
                'country': addrMap['country'],
                'state': addrMap['state'],
                'city': addrMap['city'],
                'detailedAddress': addrMap['detailedAddress'],
                'isPrimary': addrMap['isPrimary'] == 1,
              }))
          .toList();

      final user = User.fromMap({
        ...userMap,
        'addresses': addresses.map((addr) => addr.toMap()).toList(),
      });

      users.add(user);
    }

    return users;
  }

  // Additional helper methods for SQLite operations

  /// Clears all users (useful for testing)
  @override
  Future<void> clearAllUsers() async {
    final db = await database;
    await db.delete(_tableName);
    await db.delete('addresses');
  }

  /// Gets the total count of users
  @override
  Future<int> getUserCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Gets users with specific criteria
  @override
  Future<List<User>> getUsersWithCriteria({
    int? minAge,
    int? maxAge,
    bool? hasAddresses,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (minAge != null || maxAge != null) {
      final now = DateTime.now();

      if (minAge != null) {
        final maxBirthDate = DateTime(now.year - minAge, now.month, now.day);
        whereClause += 'birthDate <= ?';
        whereArgs.add(maxBirthDate.toIso8601String());
      }

      if (maxAge != null) {
        final minBirthDate =
            DateTime(now.year - maxAge - 1, now.month, now.day);
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'birthDate > ?';
        whereArgs.add(minBirthDate.toIso8601String());
      }
    }

    final List<Map<String, dynamic>> userMaps = await db.query(
      _tableName,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    final users = <User>[];

    for (final userMap in userMaps) {
      final user = await getUserById(userMap['id']);
      if (user != null) {
        // Apply hasAddresses filter
        if (hasAddresses != null && user.addresses.isNotEmpty != hasAddresses) {
          continue;
        }
        users.add(user);
      }
    }

    return users;
  }

  /// Close database connection
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
