
abstract class LocationServiceContract {
  // Core location operations
  Future<List<String>> getAvailableCountries();
  Future<List<String>> getStatesByCountry(String country);
  Future<List<String>> getCitiesByState(String country, String state);
  Future<bool> validateLocation(String country, String state, String city);
  Future<Map<String, List<String>>> getCompleteLocationHierarchy();

  // Location search and suggestions
  Future<List<String>> searchCities(String query);
  Future<List<Map<String, String>>> searchCitiesWithDetails(String query);
  Future<List<String>> getLocationSuggestions(String query);
  Future<List<String>> getAllCitiesInCountry(String country);

  // Location validation and utilities
  bool validateCountryName(String country);
  bool validateStateName(String state);
  bool validateCityName(String city);
  bool isLocationComplete(String country, String state, String city);
  String formatLocationString(String country, String state, String city);
  Map<String, String> parseLocationString(String locationString);

  // Location management
  Future<bool> addNewCountry(String countryName, {String? countryCode});
  Future<bool> addNewState(String countryName, String stateName);
  Future<bool> addNewCity(
      String countryName, String stateName, String cityName);
  Future<bool> isCountrySupported(String country);

  // Location statistics and analytics
  Future<Map<String, int>> getLocationStatistics();
  Future<List<String>> getMostPopularCountries();
  Future<List<String>> getMostPopularStatesInCountry(String country);
  Future<List<String>> getMostPopularCitiesInState(
      String country, String state);

  // Location filtering and sorting
  Future<List<String>> getCountriesSorted({bool ascending = true});
  Future<List<String>> getStatesSortedByCountry(String country,
      {bool ascending = true});
  Future<List<String>> getCitiesSortedByState(String country, String state,
      {bool ascending = true});

  // Location caching and performance
  Future<void> preloadLocationData();
  Future<void> clearLocationCache();
  Future<bool> isLocationDataLoaded();
}
