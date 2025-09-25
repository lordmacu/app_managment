
class Address {
  final String id;
  final String country;
  final String state;
  final String city;
  final String? detailedAddress;
  final bool isPrimary;

  const Address({
    required this.id,
    required this.country,
    required this.state,
    required this.city,
    this.detailedAddress,
    this.isPrimary = false,
  });

   factory Address.create({
    required String country,
    required String state,
    required String city,
    String? detailedAddress,
    bool isPrimary = false,
  }) {
    return Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      country: country,
      state: state,
      city: city,
      detailedAddress: detailedAddress,
      isPrimary: isPrimary,
    );
  }

   String get fullAddress {
    final parts = <String>[city, state, country];

    if (detailedAddress?.trim().isNotEmpty == true) {
      parts.insert(0, detailedAddress!);
    }

    return parts.join(', ');
  }

   String get geographicLocation => '$state, $country';

   bool get isComplete {
    return country.trim().isNotEmpty &&
        state.trim().isNotEmpty &&
        city.trim().isNotEmpty;
  }

   bool get isInternational => country.toLowerCase() != 'colombia';


  Address copyWith({
    String? id,
    String? country,
    String? state,
    String? city,
    String? detailedAddress,
    bool? isPrimary,
  }) {
    return Address(
      id: id ?? this.id,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      detailedAddress: detailedAddress ?? this.detailedAddress,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

   Address markAsPrimary() => copyWith(isPrimary: true);

   Address markAsSecondary() => copyWith(isPrimary: false);

   Address updateDetails(String newDetails) =>
      copyWith(detailedAddress: newDetails);

   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'country': country,
      'state': state,
      'city': city,
      'detailedAddress': detailedAddress,
      'isPrimary': isPrimary,
    };
  }

   factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      country: map['country'] ?? '',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      detailedAddress: map['detailedAddress'],
      isPrimary: map['isPrimary'] ?? false,
    );
  }

   String toJson() => toMap().toString();

   bool get isValid {
    return country.trim().isNotEmpty &&
        state.trim().isNotEmpty &&
        city.trim().isNotEmpty;
  }

   bool get isValidColombian {
    if (!isValid || isInternational) return false;

     final colombianStates = [
      'antioquia',
      'atlantico',
      'bogota',
      'bolivar',
      'boyaca',
      'caldas',
      'caqueta',
      'cauca',
      'cesar',
      'cordoba',
      'cundinamarca',
      'choco',
      'huila',
      'la guajira',
      'magdalena',
      'meta',
      'nariño',
      'norte de santander',
      'quindio',
      'risaralda',
      'santander',
      'sucre',
      'tolima',
      'valle del cauca',
      'arauca',
      'casanare',
      'putumayo',
      'san andres',
      'amazonas',
      'guainia',
      'guaviare',
      'vaupes',
      'vichada'
    ];

    return colombianStates.contains(state.toLowerCase());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other.id == id &&
        other.country == country &&
        other.state == state &&
        other.city == city &&
        other.detailedAddress == detailedAddress &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        country.hashCode ^
        state.hashCode ^
        city.hashCode ^
        detailedAddress.hashCode ^
        isPrimary.hashCode;
  }

  @override
  String toString() {
    return 'Address(id: $id, country: $country, state: $state, '
        'city: $city, detailedAddress: $detailedAddress, '
        'isPrimary: $isPrimary)';
  }
}
