import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:user_management_app/contracts/location_repository_contract.dart';

/// SQLite implementation of LocationRepository
/// S - Single Responsibility: Only handles location data operations with SQLite
/// L - Liskov Substitution: Can replace LocationRepository interface
class LocationRepositoryImpl implements LocationRepositoryContract {
  static Database? _database;
  static const String _countriesTable = 'countries';
  static const String _statesTable = 'states';
  static const String _citiesTable = 'cities';

  /// Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize SQLite database for locations
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'locations.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  /// Create database tables and populate with initial data
  Future<void> _createTables(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE $_countriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        code TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_statesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        countryId INTEGER NOT NULL,
        FOREIGN KEY (countryId) REFERENCES $_countriesTable (id) ON DELETE CASCADE,
        UNIQUE(name, countryId)
      )
    ''');

    await db.execute('''
      CREATE TABLE $_citiesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        stateId INTEGER NOT NULL,
        FOREIGN KEY (stateId) REFERENCES $_statesTable (id) ON DELETE CASCADE,
        UNIQUE(name, stateId)
      )
    ''');

    // Create indexes for better performance
    await db
        .execute('CREATE INDEX idx_countries_name ON $_countriesTable (name)');
    await db.execute(
        'CREATE INDEX idx_states_country ON $_statesTable (countryId)');
    await db.execute('CREATE INDEX idx_states_name ON $_statesTable (name)');
    await db
        .execute('CREATE INDEX idx_cities_state ON $_citiesTable (stateId)');
    await db.execute('CREATE INDEX idx_cities_name ON $_citiesTable (name)');

    // Populate with initial data
    await _populateInitialData(db);
  }

  /// Populate database with initial location data
  Future<void> _populateInitialData(Database db) async {
    // Insert countries
    final colombiaId =
        await db.insert(_countriesTable, {'name': 'Colombia', 'code': 'CO'});
    final usaId = await db
        .insert(_countriesTable, {'name': 'United States', 'code': 'US'});
    final mexicoId =
        await db.insert(_countriesTable, {'name': 'Mexico', 'code': 'MX'});

    // Colombia states and cities
    final antioquiaId = await db
        .insert(_statesTable, {'name': 'Antioquia', 'countryId': colombiaId});
    final bogotaId = await db
        .insert(_statesTable, {'name': 'Bogota', 'countryId': colombiaId});
    final valleId = await db.insert(
        _statesTable, {'name': 'Valle del Cauca', 'countryId': colombiaId});
    final atlanticoId = await db
        .insert(_statesTable, {'name': 'Atlantico', 'countryId': colombiaId});
    final santanderId = await db
        .insert(_statesTable, {'name': 'Santander', 'countryId': colombiaId});
    final cundinamarcaId = await db.insert(
        _statesTable, {'name': 'Cundinamarca', 'countryId': colombiaId});
    final norteSantanderId = await db.insert(
        _statesTable, {'name': 'Norte de Santander', 'countryId': colombiaId});
    final cordobaId = await db
        .insert(_statesTable, {'name': 'Cordoba', 'countryId': colombiaId});
    final bolivarId = await db
        .insert(_statesTable, {'name': 'Bolivar', 'countryId': colombiaId});
    final tolimaId = await db
        .insert(_statesTable, {'name': 'Tolima', 'countryId': colombiaId});

    // Antioquia cities
    final antioquiaCities = [
      'Medellin',
      'Bello',
      'Itagui',
      'Envigado',
      'Apartado',
      'Turbo',
      'Rionegro',
      'Sabaneta'
    ];
    for (final city in antioquiaCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': antioquiaId});
    }

    // Bogota cities
    await db.insert(_citiesTable, {'name': 'Bogota', 'stateId': bogotaId});

    // Valle del Cauca cities
    final valleCities = [
      'Cali',
      'Palmira',
      'Buenaventura',
      'Tulua',
      'Cartago',
      'Buga',
      'Jamundi'
    ];
    for (final city in valleCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': valleId});
    }

    // Atlantico cities
    final atlanticoCities = [
      'Barranquilla',
      'Soledad',
      'Malambo',
      'Sabanagrande',
      'Puerto Colombia'
    ];
    for (final city in atlanticoCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': atlanticoId});
    }

    // Santander cities
    final santanderCities = [
      'Bucaramanga',
      'Floridablanca',
      'Giron',
      'Piedecuesta',
      'Barrancabermeja'
    ];
    for (final city in santanderCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': santanderId});
    }

    // Cundinamarca cities
    final cundinamarcaCities = [
      'Soacha',
      'Facatativa',
      'Zipaquira',
      'Chía',
      'Mosquera',
      'Funza',
      'Madrid'
    ];
    for (final city in cundinamarcaCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': cundinamarcaId});
    }

    // Norte de Santander cities
    final norteSantanderCities = [
      'Cucuta',
      'Ocaña',
      'Pamplona',
      'Villa del Rosario'
    ];
    for (final city in norteSantanderCities) {
      await db
          .insert(_citiesTable, {'name': city, 'stateId': norteSantanderId});
    }

    // Cordoba cities
    final cordobaCities = ['Monteria', 'Lorica', 'Cerete', 'Sahagun'];
    for (final city in cordobaCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': cordobaId});
    }

    // Bolivar cities
    final bolivarCities = ['Cartagena', 'Magangue', 'Turbaco', 'Arjona'];
    for (final city in bolivarCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': bolivarId});
    }

    // Tolima cities
    final tolimaCities = ['Ibague', 'Espinal', 'Melgar', 'Honda'];
    for (final city in tolimaCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': tolimaId});
    }

    // United States states and cities
    final californiaId = await db
        .insert(_statesTable, {'name': 'California', 'countryId': usaId});
    final newYorkId =
        await db.insert(_statesTable, {'name': 'New York', 'countryId': usaId});
    final texasId =
        await db.insert(_statesTable, {'name': 'Texas', 'countryId': usaId});
    final floridaId =
        await db.insert(_statesTable, {'name': 'Florida', 'countryId': usaId});

    // California cities
    final californiaCities = [
      'Los Angeles',
      'San Francisco',
      'San Diego',
      'Sacramento',
      'Oakland',
      'Fresno'
    ];
    for (final city in californiaCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': californiaId});
    }

    // New York cities
    final newYorkCities = [
      'New York City',
      'Buffalo',
      'Rochester',
      'Syracuse',
      'Albany'
    ];
    for (final city in newYorkCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': newYorkId});
    }

    // Texas cities
    final texasCities = [
      'Houston',
      'Dallas',
      'Austin',
      'San Antonio',
      'Fort Worth'
    ];
    for (final city in texasCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': texasId});
    }

    // Florida cities
    final floridaCities = [
      'Miami',
      'Orlando',
      'Tampa',
      'Jacksonville',
      'Tallahassee'
    ];
    for (final city in floridaCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': floridaId});
    }

    // Mexico states and cities
    final cdmxId = await db.insert(
        _statesTable, {'name': 'Ciudad de Mexico', 'countryId': mexicoId});
    final jaliscoId = await db
        .insert(_statesTable, {'name': 'Jalisco', 'countryId': mexicoId});
    final nuevoLeonId = await db
        .insert(_statesTable, {'name': 'Nuevo Leon', 'countryId': mexicoId});

    // Mexico cities
    await db.insert(_citiesTable, {'name': 'Mexico City', 'stateId': cdmxId});

    final jaliscoCities = [
      'Guadalajara',
      'Zapopan',
      'Tlaquepaque',
      'Puerto Vallarta'
    ];
    for (final city in jaliscoCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': jaliscoId});
    }

    final nuevoLeonCities = [
      'Monterrey',
      'San Nicolas de los Garza',
      'Guadalupe',
      'Apodaca'
    ];
    for (final city in nuevoLeonCities) {
      await db.insert(_citiesTable, {'name': city, 'stateId': nuevoLeonId});
    }
  }

  @override
  Future<List<String>> getCountries() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      _countriesTable,
      columns: ['name'],
      orderBy: 'name ASC',
    );

    return result.map((row) => row['name'] as String).toList();
  }

  @override
  Future<List<String>> getStatesByCountry(String country) async {
    if (country.trim().isEmpty) {
      return [];
    }

    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT s.name
      FROM $_statesTable s
      INNER JOIN $_countriesTable c ON s.countryId = c.id
      WHERE c.name = ?
      ORDER BY s.name ASC
    ''', [country]);

    return result.map((row) => row['name'] as String).toList();
  }

  @override
  Future<List<String>> getCitiesByState(String country, String state) async {
    if (country.trim().isEmpty || state.trim().isEmpty) {
      return [];
    }

    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT ci.name
      FROM $_citiesTable ci
      INNER JOIN $_statesTable s ON ci.stateId = s.id
      INNER JOIN $_countriesTable c ON s.countryId = c.id
      WHERE c.name = ? AND s.name = ?
      ORDER BY ci.name ASC
    ''', [country, state]);

    return result.map((row) => row['name'] as String).toList();
  }

  @override
  Future<bool> isValidLocation(
      String country, String state, String city) async {
    if (country.trim().isEmpty || state.trim().isEmpty || city.trim().isEmpty) {
      return false;
    }

    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM $_citiesTable ci
      INNER JOIN $_statesTable s ON ci.stateId = s.id
      INNER JOIN $_countriesTable c ON s.countryId = c.id
      WHERE c.name = ? AND s.name = ? AND ci.name = ?
    ''', [country, state, city]);

    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  @override
  Future<Map<String, List<String>>> getAllLocationData() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.name as country, s.name as state
      FROM $_statesTable s
      INNER JOIN $_countriesTable c ON s.countryId = c.id
      ORDER BY c.name ASC, s.name ASC
    ''');

    final locationData = <String, List<String>>{};

    for (final row in result) {
      final country = row['country'] as String;
      final state = row['state'] as String;

      if (!locationData.containsKey(country)) {
        locationData[country] = [];
      }
      locationData[country]!.add(state);
    }

    return locationData;
  }

  // Additional helper methods for SQLite operations

  /// Gets all cities for a specific country (across all states)
  @override
  Future<List<String>> getAllCitiesByCountry(String country) async {
    if (country.trim().isEmpty) {
      return [];
    }

    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT DISTINCT ci.name
      FROM $_citiesTable ci
      INNER JOIN $_statesTable s ON ci.stateId = s.id
      INNER JOIN $_countriesTable c ON s.countryId = c.id
      WHERE c.name = ?
      ORDER BY ci.name ASC
    ''', [country]);

    return result.map((row) => row['name'] as String).toList();
  }

  /// Searches for cities by name across all countries
  @override
  Future<List<Map<String, String>>> searchCities(String cityName) async {
    if (cityName.trim().isEmpty) {
      return [];
    }

    final db = await database;
    final searchTerm = '%${cityName.toLowerCase()}%';

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.name as country, s.name as state, ci.name as city
      FROM $_citiesTable ci
      INNER JOIN $_statesTable s ON ci.stateId = s.id
      INNER JOIN $_countriesTable c ON s.countryId = c.id
      WHERE LOWER(ci.name) LIKE ?
      ORDER BY ci.name ASC
    ''', [searchTerm]);

    return result
        .map((row) => {
              'country': row['country'] as String,
              'state': row['state'] as String,
              'city': row['city'] as String,
            })
        .toList();
  }

  /// Gets location suggestions based on partial input
  @override
  Future<List<String>> getLocationSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final db = await database;
    final searchTerm = '%${query.toLowerCase()}%';
    final suggestions = <String>[];

    // Search in countries
    final countries = await db.rawQuery('''
      SELECT name FROM $_countriesTable 
      WHERE LOWER(name) LIKE ? 
      ORDER BY name ASC 
      LIMIT 3
    ''', [searchTerm]);

    for (final row in countries) {
      suggestions.add(row['name'] as String);
    }

    // Search in states
    final states = await db.rawQuery('''
      SELECT s.name as state, c.name as country
      FROM $_statesTable s
      INNER JOIN $_countriesTable c ON s.countryId = c.id
      WHERE LOWER(s.name) LIKE ?
      ORDER BY s.name ASC
      LIMIT 3
    ''', [searchTerm]);

    for (final row in states) {
      suggestions.add('${row['state']}, ${row['country']}');
    }

    // Search in cities
    final cities = await db.rawQuery('''
      SELECT ci.name as city, s.name as state, c.name as country
      FROM $_citiesTable ci
      INNER JOIN $_statesTable s ON ci.stateId = s.id
      INNER JOIN $_countriesTable c ON s.countryId = c.id
      WHERE LOWER(ci.name) LIKE ?
      ORDER BY ci.name ASC
      LIMIT 4
    ''', [searchTerm]);

    for (final row in cities) {
      suggestions.add('${row['city']}, ${row['state']}, ${row['country']}');
    }

    return suggestions.take(10).toList();
  }

  /// Checks if a country is supported
  @override
  Future<bool> isCountrySupported(String country) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      _countriesTable,
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [country],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// Gets the total count of locations
  @override
  Future<Map<String, int>> getLocationStats() async {
    final db = await database;

    final countriesCount =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_countriesTable');
    final statesCount =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_statesTable');
    final citiesCount =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_citiesTable');

    return {
      'countries': Sqflite.firstIntValue(countriesCount) ?? 0,
      'states': Sqflite.firstIntValue(statesCount) ?? 0,
      'cities': Sqflite.firstIntValue(citiesCount) ?? 0,
    };
  }

  /// Adds a new country
  @override
  Future<bool> addCountry(String countryName, {String? countryCode}) async {
    try {
      final db = await database;
      await db.insert(
        _countriesTable,
        {
          'name': countryName,
          'code': countryCode,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Adds a new state to a country
  @override
  Future<bool> addState(String countryName, String stateName) async {
    try {
      final db = await database;

      // Get country ID
      final countryResult = await db.query(
        _countriesTable,
        columns: ['id'],
        where: 'name = ?',
        whereArgs: [countryName],
        limit: 1,
      );

      if (countryResult.isEmpty) return false;

      final countryId = countryResult.first['id'] as int;

      await db.insert(
        _statesTable,
        {
          'name': stateName,
          'countryId': countryId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Adds a new city to a state
  @override
  Future<bool> addCity(
      String countryName, String stateName, String cityName) async {
    try {
      final db = await database;

      // Get state ID
      final stateResult = await db.rawQuery('''
        SELECT s.id
        FROM $_statesTable s
        INNER JOIN $_countriesTable c ON s.countryId = c.id
        WHERE c.name = ? AND s.name = ?
        LIMIT 1
      ''', [countryName, stateName]);

      if (stateResult.isEmpty) return false;

      final stateId = stateResult.first['id'] as int;

      await db.insert(
        _citiesTable,
        {
          'name': cityName,
          'stateId': stateId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Close database connection
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
