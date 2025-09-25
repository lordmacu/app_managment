import 'package:get/get_connect/connect.dart';
import 'package:user_management_app/contracts/location_repository_contract.dart';


class LocationApiRepository extends GetConnect implements LocationRepositoryContract {
  final String baseUrl;

  LocationApiRepository({required this.baseUrl}) {
    httpClient.baseUrl = baseUrl;
    httpClient.timeout = const Duration(seconds: 10);
  }

  @override
  Future<bool> isCountrySupported(String country) async {
    if (country.trim().isEmpty) return false;
    final res = await get('/api/locations/country-supported', query: {'country': country});
    if (!res.isOk || res.body == null) return false;
    return (res.body['valid'] == true);
  }


  @override
  Future<List<String>> getLocationSuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await get('/api/locations/suggestions', query: {'q': query});
    if (!res.isOk || res.body == null) return [];
    final List data = res.body;
    return data.map((e) => e.toString()).toList();
  }


  @override
  Future<bool> addState(String countryName, String stateName) async {
    if (countryName.trim().isEmpty || stateName.trim().isEmpty) return false;

    final res = await post('/api/locations/state', {
      'countryName': countryName,
      'stateName'  : stateName,
    });

    if (res.isOk) return true;
    if (res.statusCode == 409) return false; // duplicate
    return false;
  }

  @override
  Future<bool> addCountry(String countryName, {String? countryCode}) async {
    if (countryName.trim().isEmpty) return false;

    final payload = <String, dynamic>{"name": countryName};
    if (countryCode != null && countryCode.trim().isNotEmpty) {
      payload["code"] = countryCode.trim();
    }

    final res = await post('/api/locations/country', payload);

    // Treat 2xx as success. For 409 (duplicate), return false.
    if (res.isOk) return true;
    if (res.statusCode == 409) return false;
    return false;
  }


  @override
  Future<bool> addCity(String countryName, String stateName, String cityName) async {
    if (countryName.trim().isEmpty || stateName.trim().isEmpty || cityName.trim().isEmpty) {
      return false;
    }

    final res = await post('/api/locations/city', {
      'countryName': countryName,
      'stateName'  : stateName,
      'cityName'   : cityName,
    });

    if (res.isOk) return true;
    if (res.statusCode == 409) return false; // duplicate
    return false;
  }


  @override
  Future<Map<String, int>> getLocationStats() async {
    final res = await get('/api/locations/stats');

    if (!res.isOk || res.body == null) {
      return {"countries": 0, "states": 0, "cities": 0};
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(res.body);

    return {
      "countries": int.tryParse(data["countries"].toString()) ?? 0,
      "states": int.tryParse(data["states"].toString()) ?? 0,
      "cities": int.tryParse(data["cities"].toString()) ?? 0,
    };
  }

  /// Returns country names sorted ASC.
  @override
  Future<List<String>> getCountries() async {
    final res = await get('/api/locations/countries');
    if (!res.isOk || res.body == null) return [];
    final List data = res.body;
    return data.map((e) => e.toString()).toList();
  }
  /// Gets all cities by country (across all states).
  @override
  Future<List<String>> getAllCitiesByCountry(String country) async {
    if (country.trim().isEmpty) return [];
    final res = await get('/api/locations/all-cities', query: {'country': country});
    if (!res.isOk || res.body == null) return [];
    final List data = res.body;
    return data.map((e) => e.toString()).toList();
  }

  /// Returns states for a given country.
  @override
  Future<List<String>> getStatesByCountry(String country) async {
    if (country.trim().isEmpty) return [];
    final res = await get('/api/locations/states', query: {'country': country});
    if (!res.isOk || res.body == null) return [];
    final List data = res.body;
    return data.map((e) => e.toString()).toList();
  }

  /// Returns cities for a given (country, state).
  @override
  Future<List<String>> getCitiesByState(String country, String state) async {
    if (country.trim().isEmpty || state.trim().isEmpty) return [];
    final res = await get('/api/locations/cities', query: {
      'country': country,
      'state': state,
    });
    if (!res.isOk || res.body == null) return [];
    final List data = res.body;
    return data.map((e) => e.toString()).toList();
  }

  /// Validates a (country, state, city) triple.
  @override
  Future<bool> isValidLocation(String country, String state, String city) async {
    if (country.trim().isEmpty || state.trim().isEmpty || city.trim().isEmpty) {
      return false;
    }
    final res = await get('/api/locations/validate', query: {
      'country': country,
      'state': state,
      'city': city,
    });
    if (!res.isOk || res.body == null) return false;
    return (res.body['valid'] == true);
  }

  /// Returns a map { country: [states...] }.
  @override
  Future<Map<String, List<String>>> getAllLocationData() async {
    final res = await get('/api/locations/all');
    if (!res.isOk || res.body == null) return {};
    final Map<String, dynamic> raw = Map<String, dynamic>.from(res.body);
    return raw.map((k, v) => MapEntry(k, List<String>.from(v)));
  }

  // Helpers analogous to your SQLite extras (optional)
  @override
  Future<List<Map<String, String>>> searchCities(String cityName) async {
    if (cityName.trim().isEmpty) return [];
    final res = await get('/api/locations/search-cities', query: {'q': cityName});
    if (!res.isOk || res.body == null) return [];
    final List data = res.body;
    return data.map((e) => {
      'country': e['country'].toString(),
      'state': e['state'].toString(),
      'city': e['city'].toString(),
    }).toList();
  }
}
