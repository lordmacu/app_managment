// test/services/user_service_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:user_management_app/contracts/user_repository_contract.dart';
import 'package:user_management_app/models/user.dart';
import 'package:user_management_app/models/address.dart';
import 'package:user_management_app/services/user_service_impl.dart';

class MockUserRepository extends Mock implements UserRepositoryContract {}

class FakeUser extends Fake implements User {}
class FakeAddress extends Fake implements Address {}

void main() {
  late MockUserRepository repo;
  late UserServiceImpl service;

  setUpAll(() {
    registerFallbackValue(FakeUser());
    registerFallbackValue(FakeAddress());
  });

  setUp(() {
    repo = MockUserRepository();
    service = UserServiceImpl(repo);
  });

  group('UserServiceImpl - createUser', () {
    test('lanza ArgumentError si los datos son inválidos (firstName vacío)', () async {
      expect(
            () => service.createUser(
          firstName: '',
          lastName: 'Doe',
          birthDate: DateTime(2000, 1, 1),
        ),
        throwsA(isA<ArgumentError>()),
      );
      // No debe llamar al repositorio
      verifyNever(() => repo.saveUser(any()));
    });

    test('cuando los datos son válidos, guarda y retorna el id', () async {
      // Arrange
      when(() => repo.saveUser(any())).thenAnswer((_) async => '12345');

      // Act
      final id = await service.createUser(
        firstName: 'John',
        lastName: 'Doe',
        birthDate: DateTime(2000, 1, 1),
      );

      // Assert
      expect(id, '12345');
      // Verifica que se llamó al repo con un User
      verify(() => repo.saveUser(any(that: isA<User>()))).called(1);
    });
  });

  group('UserServiceImpl - userExists & searchUsersByName', () {
    test('userExists: si id está vacío, retorna false y NO llama al repo', () async {
      final result = await service.userExists('   ');
      expect(result, false);
      verifyNever(() => repo.userExists(any()));
    });

    test('searchUsersByName: si nombre vacío, retorna [] y NO llama al repo', () async {
      final result = await service.searchUsersByName('   ');
      expect(result, isEmpty);
      verifyNever(() => repo.searchUsersByName(any()));
    });
  });

  group('UserServiceImpl - getUserById & deleteUser', () {
    test('getUserById: lanza ArgumentError si id vacío', () async {
      expect(() => service.getUserById('  '), throwsA(isA<ArgumentError>()));
      verifyNever(() => repo.getUserById(any()));
    });

    test('deleteUser: lanza ArgumentError si id vacío', () async {
      expect(() => service.deleteUser(''), throwsA(isA<ArgumentError>()));
      verifyNever(() => repo.deleteUser(any()));
    });
  });

  group('UserServiceImpl - addAddressToUser', () {
    test('si es la primera dirección, la marca como primaria y actualiza el usuario', () async {
      // Arrange: un usuario sin direcciones
      final user = User(
        id: 'u1',
        firstName: 'Ana',
        lastName: 'Lopez',
        birthDate: DateTime(1995, 5, 5),
        addresses: const [],
      );

      when(() => repo.getUserById('u1')).thenAnswer((_) async => user);
      when(() => repo.updateUser(any())).thenAnswer((_) async => true);

      final address = Address.create(
        country: 'Colombia',
        state: 'Cundinamarca',
        city: 'Bogotá',
        detailedAddress: 'Calle 123',
        isPrimary: false, // viene como secundaria
      );

      // Act
      final ok = await service.addAddressToUser('u1', address);

      // Assert
      expect(ok, true);

      // Capturamos el usuario actualizado para revisar que la dirección quedó primaria
      final captured = verify(() => repo.updateUser(captureAny())).captured.first as User;
      expect(captured.addresses.length, 1);
      expect(captured.addresses.first.isPrimary, true);
    });
  });

  group('UserServiceImpl - getUserStatistics', () {
    test('calcula totales, promedios y conteos básicos', () async {
      // Creamos 3 usuarios: 2 adultos con direcciones, 1 menor sin direcciones
      final now = DateTime.now();
      final adultBirth = DateTime(now.year - 30, now.month, now.day);
      final minorBirth = DateTime(now.year - 10, now.month, now.day);

      final u1 = User(
        id: '1',
        firstName: 'A',
        lastName: 'A',
        birthDate: adultBirth,
        addresses: [Address.create(country: 'CO', state: 'Cund', city: 'Bta')],
      );
      final u2 = User(
        id: '2',
        firstName: 'B',
        lastName: 'B',
        birthDate: adultBirth,
        addresses: [
          Address.create(country: 'CO', state: 'Ant', city: 'Mde'),
          Address.create(country: 'CO', state: 'Val', city: 'Cali'),
        ],
      );
      final u3 = User(
        id: '3',
        firstName: 'C',
        lastName: 'C',
        birthDate: minorBirth,
        addresses: const [],
      );

      when(() => repo.getAllUsers()).thenAnswer((_) async => [u1, u2, u3]);

      final stats = await service.getUserStatistics();

      expect(stats['totalUsers'], 3);
      expect(stats['adultUsers'], 2);
      expect(stats['minorUsers'], 1);
      expect(stats['usersWithAddresses'], 2);
      expect(stats['usersWithoutAddresses'], 1);

      // Valores aproximados: averageAge ≈ 23.3 y addressPerUser ≈ 1.0
      // (dependerá del día exacto; validamos tipos/rangos)
      expect(stats['averageAge'], isA<double>());
      expect((stats['averageAge'] as double) > 0, true);

      expect(stats['addressPerUser'], isA<double>());
      expect((stats['addressPerUser'] as double) >= 1.0, true);
    });
  });
}
