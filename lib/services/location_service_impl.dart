import '../contracts/location_service_contract.dart';
import '../contracts/location_repository_contract.dart';

/// Implementation of LocationServiceContract following SOLID principles
/// S - Single Responsibility: Only handles location business logic
/// O - Open/Closed: Can be extended without modification
/// L - Liskov Substitution: Can replace LocationServiceContract interface
/// D - Dependency Inversion: Depends on LocationRepositoryContract abstraction
class LocationServiceImpl implements LocationServiceContract {
  final LocationRepositoryContract _locationRepository;

  // Cache for frequently accessed data
  Map<String, List<String>>? _cachedLocationData;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidDuration = Duration(hours: 1);

  LocationServiceImpl(this._locationRepository);

  @override
  Future<List<String>> getAvailableCountries() async {
    try {
      final countries = await _locationRepository.getCountries();
      return countries.where((country) => country.trim().isNotEmpty).toList();
    } catch (e) {
      throw Exception('Fallo al traer las ciudades: $e');
    }
  }

  @override
  Future<List<String>> getStatesByCountry(String country) async {
    if (!validateCountryName(country)) {
      throw ArgumentError('Páis invalido');
    }

    try {
      final states =
          await _locationRepository.getStatesByCountry(country.trim());
      return states.where((state) => state.trim().isNotEmpty).toList();
    } catch (e) {
      throw Exception('Fallo al traer detapartamentos por pais: "$country": $e');
    }
  }

  @override
  Future<List<String>> getCitiesByState(String country, String state) async {
    if (!validateCountryName(country) || !validateStateName(state)) {
      throw ArgumentError('Pais o departamento invalido');
    }

    try {
      final cities = await _locationRepository.getCitiesByState(
          country.trim(), state.trim());
      return cities.where((city) => city.trim().isNotEmpty).toList();
    } catch (e) {
      throw Exception(
          'Erroe en Departamento o pais "$state" in "$country": $e');
    }
  }

  @override
  Future<bool> validateLocation(
      String country, String state, String city) async {
    if (!isLocationComplete(country, state, city)) {
      return false;
    }

    try {
      return await _locationRepository.isValidLocation(
          country.trim(), state.trim(), city.trim());
    } catch (e) {
      throw Exception('no se pudo validar ubicación: $e');
    }
  }

  @override
  Future<Map<String, List<String>>> getCompleteLocationHierarchy() async {
    try {
       if (_isCacheValid()) {
        return _cachedLocationData!;
      }

      final locationData = await _locationRepository.getAllLocationData();

       _cachedLocationData = locationData;
      _cacheTimestamp = DateTime.now();

      return locationData;
    } catch (e) {
      throw Exception('Falla: $e');
    }
  }

  @override
  Future<List<String>> searchCities(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final cityResults = await _locationRepository.searchCities(query.trim());
      return cityResults.map((result) => result['city']!).toList();
    } catch (e) {
      throw Exception('Failed to search cities: $e');
    }
  }

  @override
  Future<List<Map<String, String>>> searchCitiesWithDetails(
      String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      return await _locationRepository.searchCities(query.trim());
    } catch (e) {
      throw Exception('Failed to search cities with details: $e');
    }
  }

  @override
  Future<List<String>> getLocationSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      return await _locationRepository.getLocationSuggestions(query.trim());
    } catch (e) {
      throw Exception('Failed to get location suggestions: $e');
    }
  }

  @override
  Future<List<String>> getAllCitiesInCountry(String country) async {
    if (!validateCountryName(country)) {
      throw ArgumentError('Invalid country name');
    }

    try {
      return await _locationRepository.getAllCitiesByCountry(country.trim());
    } catch (e) {
      throw Exception('Failed to get all cities in country "$country": $e');
    }
  }

  @override
  bool validateCountryName(String country) {
    if (country.trim().isEmpty) return false;
    if (country.trim().length < 2) return false;
    if (country.trim().length > 100) return false;

     final validPattern = RegExp(r"^[a-zA-Z\s\-']+$");
    return validPattern.hasMatch(country.trim());
  }

  @override
  bool validateStateName(String state) {
    if (state.trim().isEmpty) return false;
    if (state.trim().length < 2) return false;
    if (state.trim().length > 100) return false;

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final validPattern = RegExp(r"^[a-zA-Z\s\-']+$");
    return validPattern.hasMatch(state.trim());
  }

  @override
  bool validateCityName(String city) {
    if (city.trim().isEmpty) return false;
    if (city.trim().length < 2) return false;
    if (city.trim().length > 100) return false;

    // Check for valid characters (letters, spaces, hyphens, apostrophes, periods)
    final validPattern = RegExp(r"^[a-zA-Z\s\-'.]+$");
    return validPattern.hasMatch(city.trim());
  }

  @override
  bool isLocationComplete(String country, String state, String city) {
    return validateCountryName(country) &&
        validateStateName(state) &&
        validateCityName(city);
  }

  @override
  String formatLocationString(String country, String state, String city) {
    final parts = <String>[];

    if (validateCityName(city)) parts.add(city.trim());
    if (validateStateName(state)) parts.add(state.trim());
    if (validateCountryName(country)) parts.add(country.trim());

    return parts.join(', ');
  }

  @override
  Map<String, String> parseLocationString(String locationString) {
    final result = <String, String>{
      'country': '',
      'state': '',
      'city': '',
    };

    if (locationString.trim().isEmpty) {
      return result;
    }

    final parts = locationString.split(',').map((part) => part.trim()).toList();

    // Assume format: "City, State, Country" or "State, Country" or "Country"
    if (parts.length >= 3) {
      result['city'] = parts[0];
      result['state'] = parts[1];
      result['country'] = parts[2];
    } else if (parts.length == 2) {
      result['state'] = parts[0];
      result['country'] = parts[1];
    } else if (parts.length == 1) {
      result['country'] = parts[0];
    }

    return result;
  }

  @override
  Future<bool> addNewCountry(String countryName, {String? countryCode}) async {
    if (!validateCountryName(countryName)) {
      throw ArgumentError('Invalid country name');
    }

    try {
      final success = await _locationRepository.addCountry(
        countryName.trim(),
        countryCode: countryCode?.trim(),
      );

      if (success) {
        _clearCache();
      }

      return success;
    } catch (e) {
      throw Exception('Error al agregar el país: $e');
    }
  }

  @override
  Future<bool> addNewState(String countryName, String stateName) async {
    if (!validateCountryName(countryName) || !validateStateName(stateName)) {
      throw ArgumentError('País o departamento invalido');
    }

    try {
      final success = await _locationRepository.addState(
        countryName.trim(),
        stateName.trim(),
      );

      if (success) {
        _clearCache();
      }

      return success;
    } catch (e) {
      throw Exception('Error al agregar departamento: $e');
    }
  }

  @override
  Future<bool> addNewCity(
      String countryName, String stateName, String cityName) async {
    if (!isLocationComplete(countryName, stateName, cityName)) {
      throw ArgumentError('Ubicación imcompleta');
    }

    try {
      final success = await _locationRepository.addCity(
        countryName.trim(),
        stateName.trim(),
        cityName.trim(),
      );

      if (success) {
        _clearCache();
      }

      return success;
    } catch (e) {
      throw Exception('Error al agregar ciudad: $e');
    }
  }

  @override
  Future<bool> isCountrySupported(String country) async {
    if (!validateCountryName(country)) {
      return false;
    }

    try {
      return await _locationRepository.isCountrySupported(country.trim());
    } catch (e) {
      throw Exception('Error al seleccioar País: $e');
    }
  }

  @override
  Future<Map<String, int>> getLocationStatistics() async {
    try {
      return await _locationRepository.getLocationStats();
    } catch (e) {
      throw Exception('Error al traer las estadisticas: $e');
    }
  }

  @override
  Future<List<String>> getMostPopularCountries() async {
    try {
      // For now, return all countries sorted by name
      // In a real app, this might be based on usage statistics
      final countries = await getAvailableCountries();
      countries.sort();
      return countries;
    } catch (e) {
      throw Exception('No se puede popular los paises: $e');
    }
  }

  @override
  Future<List<String>> getMostPopularStatesInCountry(String country) async {
    if (!validateCountryName(country)) {
      throw ArgumentError('País invalido');
    }

    try {
      final states = await getStatesByCountry(country);
      states.sort();
      return states;
    } catch (e) {
      throw Exception('Error al traer los Departamentos: $e');
    }
  }

  @override
  Future<List<String>> getMostPopularCitiesInState(
      String country, String state) async {
    if (!validateCountryName(country) || !validateStateName(state)) {
      throw ArgumentError('País o departamento invalidos');
    }

    try {
      // For now, return all cities sorted by name
      // In a real app, this might be based on usage statistics
      final cities = await getCitiesByState(country, state);
      cities.sort();
      return cities;
    } catch (e) {
      throw Exception('Error en ciudades $e');
    }
  }

  @override
  Future<List<String>> getCountriesSorted({bool ascending = true}) async {
    try {
      final countries = await getAvailableCountries();
      countries.sort();
      return ascending ? countries : countries.reversed.toList();
    } catch (e) {
      throw Exception('Error al organizar paises: $e');
    }
  }

  @override
  Future<List<String>> getStatesSortedByCountry(String country,
      {bool ascending = true}) async {
    try {
      final states = await getStatesByCountry(country);
      states.sort();
      return ascending ? states : states.reversed.toList();
    } catch (e) {
      throw Exception('Error al organizar departamentos: $e');
    }
  }

  @override
  Future<List<String>> getCitiesSortedByState(String country, String state,
      {bool ascending = true}) async {
    try {
      final cities = await getCitiesByState(country, state);
      cities.sort();
      return ascending ? cities : cities.reversed.toList();
    } catch (e) {
      throw Exception('Error al organizar ciudades: $e');
    }
  }

  @override
  Future<void> preloadLocationData() async {
    try {
      await getCompleteLocationHierarchy();
    } catch (e) {
      throw Exception('Error general: $e');
    }
  }

  @override
  Future<void> clearLocationCache() async {
    _clearCache();
  }

  @override
  Future<bool> isLocationDataLoaded() async {
    return _isCacheValid();
  }

  // Private helper methods

  bool _isCacheValid() {
    if (_cachedLocationData == null || _cacheTimestamp == null) {
      return false;
    }

    final now = DateTime.now();
    final cacheAge = now.difference(_cacheTimestamp!);
    return cacheAge < _cacheValidDuration;
  }

  void _clearCache() {
    _cachedLocationData = null;
    _cacheTimestamp = null;
  }


   Future<List<String>> getSmartLocationSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final suggestions = await getLocationSuggestions(query);

       suggestions.sort((a, b) {
        final aLower = a.toLowerCase();
        final bLower = b.toLowerCase();
        final queryLower = query.toLowerCase();

        // Exact matches first
        if (aLower == queryLower && bLower != queryLower) return -1;
        if (bLower == queryLower && aLower != queryLower) return 1;

        // Starts with query
        if (aLower.startsWith(queryLower) && !bLower.startsWith(queryLower)) {
          return -1;
        }
        if (bLower.startsWith(queryLower) && !aLower.startsWith(queryLower)) {
          return 1;
        }

        // Shorter strings first
        return a.length.compareTo(b.length);
      });

      return suggestions.take(10).toList();
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Validates a complete address structure
  Future<Map<String, dynamic>> validateCompleteAddress({
    required String country,
    required String state,
    required String city,
    String? detailedAddress,
  }) async {
    final result = <String, dynamic>{
      'isValid': false,
      'errors': <String>[],
      'warnings': <String>[],
    };

    // Basic validation
    if (!validateCountryName(country)) {
      result['errors'].add('País invalido');
    }

    if (!validateStateName(state)) {
      result['errors'].add('Departamento invalido');
    }

    if (!validateCityName(city)) {
      result['errors'].add('Ciudad Invalida');
    }

    if ((result['errors'] as List).isNotEmpty) {
      return result;
    }

    try {
       final isValid = await validateLocation(country, state, city);

      if (!isValid) {
        result['errors'].add('No se encontró la ubicación.');

         final countryExists = await isCountrySupported(country);
        if (!countryExists) {
          result['warnings'].add('Pais "$country" no encontrado');
        } else {
           final states = await getStatesByCountry(country);
          if (!states.contains(state)) {
            result['warnings'].add('Departamento "$state" no encontrado en: "$country"');
          } else {
            result['warnings']
                .add('Ciudad "$city" no encnotrada en "$state, $country"');
          }
        }
      } else {
        result['isValid'] = true;
      }

       if (detailedAddress != null && detailedAddress.trim().isNotEmpty) {
        if (detailedAddress.trim().length < 5) {
          result['warnings'].add('El detalle de la dirección es muy corto');
        }
        if (detailedAddress.trim().length > 200) {
          result['warnings'].add('El detalle de la dirección es muy largo');
        }
      }
    } catch (e) {
      result['errors'].add('Error al validar dirección: $e');
    }

    return result;
  }
}
