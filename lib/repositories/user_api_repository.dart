import 'package:get/get_connect/connect.dart';
import 'package:user_management_app/contracts/user_repository_contract.dart';
import 'package:user_management_app/models/user.dart';
import 'package:user_management_app/models/address.dart';

class UserApiRepository extends GetConnect implements UserRepositoryContract {
  final String baseUrl;

  UserApiRepository({required this.baseUrl}) {
    httpClient.baseUrl = baseUrl;
    httpClient.timeout = const Duration(seconds: 10);
  }

  @override
  Future<int> getUserCount() async {
    final res = await get('/api/users/count');
    if (!res.isOk || res.body == null) return 0;
    return int.tryParse(res.body['count'].toString()) ?? 0;
  }

  @override
  Future<void> clearAllUsers() async {
    final res = await delete('/api/users/all');
    if (!res.isOk) {
      throw Exception('Failed to clear users on server');
    }
  }


  @override
  Future<List<User>> getUsersWithCriteria({
    int? minAge,
    int? maxAge,
    bool? hasAddresses,
  }) async {
    final query = <String, String>{};

    if (minAge != null) query['minAge'] = minAge.toString();
    if (maxAge != null) query['maxAge'] = maxAge.toString();
    if (hasAddresses != null) query['hasAddresses'] = hasAddresses.toString();

    final res = await get('/api/users/criteria', query: query);

    if (!res.isOk || res.body == null) return [];
    final List data = res.body;
    return data.map((e) => _userFromJson(e)).whereType<User>().toList();
  }


  @override
  Future<User?> getUserById(String id) async {
    final res = await get('/api/users/$id');
    if (!res.isOk || res.body == null) return null;
    return _userFromJson(res.body);
  }

  @override
  Future<List<User>> getAllUsers() async {
    final res = await get('/api/users');
    if (!res.isOk || res.body == null) return [];
    final List data = res.body;
    return data.map((e) => _userFromJson(e)).whereType<User>().toList();
  }

  @override
  Future<String> saveUser(User user) async {

    if (!user.isValid) {
      throw ArgumentError('Invalid user data');
    }
    final payload = _userToJson(user);

    final res = await post('/api/users', payload);

    if (!res.isOk || res.body == null) {
      throw Exception('Failed to create user');
    }
    return res.body['id'].toString();
  }

  @override
  Future<bool> updateUser(User user) async {
    if (!user.isValid) {
      throw ArgumentError('Invalid user data');
    }
    final payload = _userToJson(user);
    final res = await put('/api/users/${user.id}', payload);
    return res.isOk;
  }

  @override
  Future<bool> deleteUser(String id) async {
    final res = await delete('/api/users/$id');
    return res.isOk;
  }

  @override
  Future<bool> userExists(String id) async {
    final res = await get('/api/users/$id/exists');
    if (!res.isOk || res.body == null) return false;
    return (res.body['exists'] == true);
  }

  @override
  Future<List<User>> searchUsersByName(String name) async {
    if (name.trim().isEmpty) return [];
    final res = await get('/api/users/search', query: {'name': name});
    if (!res.isOk || res.body == null) return [];
    final List data = res.body;
    return data.map((e) => _userFromJson(e)).whereType<User>().toList();
  }

  // ----- JSON mappers -----
  Map<String, dynamic> _userToJson(User user) => {
    'id': user.id,
    'firstName': user.firstName,
    'lastName': user.lastName,
    'birthDate': user.birthDate.toIso8601String(),
    'addresses': user.addresses.map((a) => {
      'id': a.id,
      'country': a.country,
      'state': a.state,
      'city': a.city,
      'detailedAddress': a.detailedAddress,
      'isPrimary': a.isPrimary,
    }).toList(),
  };

  User? _userFromJson(dynamic json) {
    if (json == null) return null;
    final addresses = (json['addresses'] as List? ?? [])
        .map((a) => Address.fromMap({
      'id': a['id'],
      'country': a['country'],
      'state': a['state'],
      'city': a['city'],
      'detailedAddress': a['detailedAddress'],
      'isPrimary': a['isPrimary'] == true,
    }))
        .toList();
    return User.fromMap({
      'id': json['id'],
      'firstName': json['firstName'],
      'lastName': json['lastName'],
      'birthDate': json['birthDate'],
      'addresses': addresses.map((e) => e.toMap()).toList(),
    });
  }
}
