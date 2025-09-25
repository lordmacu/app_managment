
abstract class LocationRepositoryContract {
  Future<List<String>> getCountries();
  Future<List<String>> getStatesByCountry(String country);
  Future<List<String>> getCitiesByState(String country, String state);
  Future<bool> isValidLocation(String country, String state, String city);
  Future<Map<String, List<String>>> getAllLocationData();

  // Additional helper methods contracts
  Future<List<String>> getAllCitiesByCountry(String country);
  Future<List<Map<String, String>>> searchCities(String cityName);
  Future<List<String>> getLocationSuggestions(String query);
  Future<bool> isCountrySupported(String country);
  Future<Map<String, int>> getLocationStats();
  Future<bool> addCountry(String countryName, {String? countryCode});
  Future<bool> addState(String countryName, String stateName);
  Future<bool> addCity(String countryName, String stateName, String cityName);
 }
