import 'package:flutter_test/flutter_test.dart';
import 'package:user_management_app/models/address.dart';

void main() {
  group('Address model', () {
    test('fullAddress returns correctly formatted string', () {
      final address = const Address(
        id: '1',
        country: 'Colombia',
        state: 'Cundinamarca',
        city: 'Bogotá',
        detailedAddress: 'Calle 123',
      );

      expect(address.fullAddress, 'Calle 123, Bogotá, Cundinamarca, Colombia');
    });

    test('isComplete returns false if required fields are missing', () {
      final address = const Address(
        id: '1',
        country: '',
        state: 'Cundinamarca',
        city: 'Bogotá',
      );

      expect(address.isComplete, false);
    });
  });
}
