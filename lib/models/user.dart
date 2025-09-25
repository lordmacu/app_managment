import 'address.dart';


class User {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final List<Address> addresses;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.addresses,
  });

   factory User.create({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    List<Address>? addresses,
  }) {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      addresses: addresses ?? [],
    );
  }

   String get fullName => '$firstName $lastName';

   int get age {
    final now = DateTime.now();
    int currentAge = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      currentAge--;
    }
    return currentAge;
  }

   bool get isAdult => age >= 18;

   Address? get primaryAddress {
    return addresses.isNotEmpty ? addresses.first : null;
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    List<Address>? addresses,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      addresses: addresses ?? this.addresses,
    );
  }

   User addAddress(Address address) {
    final newAddresses = List<Address>.from(addresses)..add(address);
    return copyWith(addresses: newAddresses);
  }

   User removeAddress(String addressId) {
    final newAddresses =
        addresses.where((addr) => addr.id != addressId).toList();
    return copyWith(addresses: newAddresses);
  }

   User updateAddress(String addressId, Address updatedAddress) {
    final newAddresses = addresses.map((addr) {
      return addr.id == addressId ? updatedAddress : addr;
    }).toList();
    return copyWith(addresses: newAddresses);
  }

   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
    };
  }

   factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      birthDate: DateTime.parse(map['birthDate']),
      addresses: (map['addresses'] as List<dynamic>?)
              ?.map(
                  (addrMap) => Address.fromMap(addrMap as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

   String toJson() => toMap().toString();

   bool get isValid {
    return firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        birthDate.isBefore(DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.birthDate == birthDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        birthDate.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, '
        'birthDate: $birthDate, addresses: ${addresses.length})';
  }
}
