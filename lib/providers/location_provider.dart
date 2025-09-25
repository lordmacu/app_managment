import 'package:flutter/foundation.dart';
import '../contracts/location_service_contract.dart';


class LocationProvider with ChangeNotifier {
  LocationServiceContract _locationService;

  LocationProvider(this._locationService);

   List<String> _countries = [];
  List<String> _states = [];
  List<String> _cities = [];
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  bool _isLoading = false;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;
  String? _errorMessage;
  List<String> _locationSuggestions = [];
  String _searchQuery = '';
  Map<String, int>? _locationStats;

   List<String> get countries => List.unmodifiable(_countries);
  List<String> get states => List.unmodifiable(_states);
  List<String> get cities => List.unmodifiable(_cities);
  String? get selectedCountry => _selectedCountry;
  String? get selectedState => _selectedState;
  String? get selectedCity => _selectedCity;
  bool get isLoading => _isLoading;
  bool get isLoadingStates => _isLoadingStates;
  bool get isLoadingCities => _isLoadingCities;
  String? get errorMessage => _errorMessage;
  List<String> get locationSuggestions =>
      List.unmodifiable(_locationSuggestions);
  String get searchQuery => _searchQuery;
  Map<String, int>? get locationStats => _locationStats;
  bool get hasError => _errorMessage != null;
  bool get hasCountries => _countries.isNotEmpty;
  bool get hasStates => _states.isNotEmpty;
  bool get hasCities => _cities.isNotEmpty;
  bool get isLocationComplete =>
      _selectedCountry != null &&
      _selectedState != null &&
      _selectedCity != null;


  void updateService(LocationServiceContract service) {
    _locationService = service;
  }

  /// Load initial data once at app start (idempotent).
  Future<void> bootstrap() async {
     if (!hasCountries && !_isLoading) {
      await loadCountries();
    }
  }

  /// Load all countries from the service
  Future<void> loadCountries() async {
    _setLoading(true);
    _clearError();

    try {
      _countries = await _locationService.getAvailableCountries();
      notifyListeners();
    } catch (e) {
      _setError('Fallo al cargar Paises: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load states for a specific country
  Future<void> loadStates(String country) async {
    if (country.trim().isEmpty) {
      _clearStates();
      return;
    }

    _setLoadingStates(true);
    _clearError();

    try {
      _states = await _locationService.getStatesByCountry(country);

      // Clear selected state and cities if states changed
      if (_selectedState != null && !_states.contains(_selectedState)) {
        _selectedState = null;
        _clearCities();
      }

      notifyListeners();
    } catch (e) {
      _setError('Fallo al cargar Departamentos: $e');
      _clearStates();
    } finally {
      _setLoadingStates(false);
    }
  }

  /// Load cities for a specific country and state
  Future<void> loadCities(String country, String state) async {
    if (country.trim().isEmpty || state.trim().isEmpty) {
      _clearCities();
      return;
    }

    _setLoadingCities(true);
    _clearError();

    try {
      _cities = await _locationService.getCitiesByState(country, state);

      // Clear selected city if it's not in the new list
      if (_selectedCity != null && !_cities.contains(_selectedCity)) {
        _selectedCity = null;
      }

      notifyListeners();
    } catch (e) {
      _setError('Fallo al cargar ciudades: $e');
      _clearCities();
    } finally {
      _setLoadingCities(false);
    }
  }

  /// Set selected country and load its states
  Future<void> setSelectedCountry(String? country) async {
    if (_selectedCountry == country) return;

    _selectedCountry = country;
    _selectedState = null;
    _selectedCity = null;
    _clearStates();
    _clearCities();

    if (country != null) {
      await loadStates(country);
    }

    notifyListeners();
  }

  /// Set selected state and load its cities
  Future<void> setSelectedState(String? state) async {
    if (_selectedState == state) return;

    _selectedState = state;
    _selectedCity = null;
    _clearCities();

    if (state != null && _selectedCountry != null) {
      await loadCities(_selectedCountry!, state);
    }

    notifyListeners();
  }

  /// Set selected city
  void setSelectedCity(String? city) {
    if (_selectedCity == city) return;

    _selectedCity = city;
    notifyListeners();
  }

  /// Clear all selections
  void clearSelections() {
    _selectedCountry = null;
    _selectedState = null;
    _selectedCity = null;
    _clearStates();
    _clearCities();
    notifyListeners();
  }

  /// Search for location suggestions
  Future<void> searchLocationSuggestions(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _locationSuggestions = [];
      notifyListeners();
      return;
    }

    if (_searchQuery.length < 2) {
      return; // Don't search for queries too short
    }

    _setLoading(true);
    _clearError();

    try {
      _locationSuggestions =
          await _locationService.getLocationSuggestions(_searchQuery);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get location suggestions: $e');
      _locationSuggestions = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Search cities with details
  Future<List<Map<String, String>>> searchCitiesWithDetails(
      String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    _setLoading(true);
    _clearError();

    try {
      final results =
          await _locationService.searchCitiesWithDetails(query.trim());
      return results;
    } catch (e) {
      _setError('Fallo al cargar Ciudades: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Validate current location selection
  Future<bool> validateCurrentLocation() async {
    if (!isLocationComplete) {
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final isValid = await _locationService.validateLocation(
        _selectedCountry!,
        _selectedState!,
        _selectedCity!,
      );
      return isValid;
    } catch (e) {
      _setError('Fallo al validar la ubiación: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Validate a specific location
  Future<bool> validateLocation(
      String country, String state, String city) async {
    _setLoading(true);
    _clearError();

    try {
      final isValid =
          await _locationService.validateLocation(country, state, city);
      return isValid;
    } catch (e) {
      _setError('Fallo al validar la ubicación: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get location statistics
  Future<void> loadLocationStatistics() async {
    _setLoading(true);
    _clearError();

    try {
      _locationStats = await _locationService.getLocationStatistics();
      notifyListeners();
    } catch (e) {
      _setError('Fallo al cargar estadisticas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new country
  Future<bool> addCountry(String countryName, {String? countryCode}) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _locationService.addNewCountry(countryName,
          countryCode: countryCode);

      if (success) {
        // Refresh countries list
        await loadCountries();
      }

      return success;
    } catch (e) {
      _setError('Fallo al agregar el país: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new state
  Future<bool> addState(String countryName, String stateName) async {
    _setLoading(true);
    _clearError();

    try {
      final success =
          await _locationService.addNewState(countryName, stateName);

      if (success && _selectedCountry == countryName) {
        // Refresh states list if we're currently viewing this country
        await loadStates(countryName);
      }

      return success;
    } catch (e) {
      _setError('Fallo al agregar el estado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new city
  Future<bool> addCity(
      String countryName, String stateName, String cityName) async {
    _setLoading(true);
    _clearError();

    try {
      final success =
          await _locationService.addNewCity(countryName, stateName, cityName);

      if (success &&
          _selectedCountry == countryName &&
          _selectedState == stateName) {
        // Refresh cities list if we're currently viewing this state
        await loadCities(countryName, stateName);
      }

      return success;
    } catch (e) {
      _setError('Fallo al agregar la ciudad: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if a country is supported
  Future<bool> isCountrySupported(String country) async {
    try {
      return await _locationService.isCountrySupported(country);
    } catch (e) {
      _setError('no hay paises: $e');
      return false;
    }
  }

  /// Format location as string
  String formatLocationString() {
    if (!isLocationComplete) {
      return '';
    }

    return _locationService.formatLocationString(
      _selectedCountry!,
      _selectedState!,
      _selectedCity!,
    );
  }

  /// Parse location string and set selections
  Future<void> parseAndSetLocation(String locationString) async {
    final parsedLocation = _locationService.parseLocationString(locationString);

    final country = parsedLocation['country'];
    final state = parsedLocation['state'];
    final city = parsedLocation['city'];

    if (country?.isNotEmpty == true) {
      await setSelectedCountry(country);

      if (state?.isNotEmpty == true) {
        await setSelectedState(state);

        if (city?.isNotEmpty == true) {
          setSelectedCity(city);
        }
      }
    }
  }

  /// Get sorted countries
  Future<List<String>> getSortedCountries({bool ascending = true}) async {
    try {
      return await _locationService.getCountriesSorted(ascending: ascending);
    } catch (e) {
      _setError('Fallo al organizar: $e');
      return [];
    }
  }

  /// Get all cities in current country
  Future<List<String>> getAllCitiesInCurrentCountry() async {
    if (_selectedCountry == null) {
      return [];
    }

    try {
      return await _locationService.getAllCitiesInCountry(_selectedCountry!);
    } catch (e) {
      _setError('Fallo al traer todas las ciudades: $e');
      return [];
    }
  }

  /// Preload location data for better performance
  Future<void> preloadLocationData() async {
    _setLoading(true);
    _clearError();

    try {
      await _locationService.preloadLocationData();
      // Load countries after preloading
      await loadCountries();
    } catch (e) {
      _setError('Fallo al hacer preload de la ubicación: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear location cache
  Future<void> clearLocationCache() async {
    try {
      await _locationService.clearLocationCache();
      // Reload countries after clearing cache
      await loadCountries();
    } catch (e) {
      _setError('Fallo al borrar cache: $e');
    }
  }

  /// Validate location input fields
  bool validateLocationFields({
    String? country,
    String? state,
    String? city,
  }) {
    if (country != null && !_locationService.validateCountryName(country)) {
      return false;
    }

    if (state != null && !_locationService.validateStateName(state)) {
      return false;
    }

    if (city != null && !_locationService.validateCityName(city)) {
      return false;
    }

    return true;
  }

  /// Get current location as map
  Map<String, String?> getCurrentLocationAsMap() {
    return {
      'country': _selectedCountry,
      'state': _selectedState,
      'city': _selectedCity,
    };
  }

  /// Set location from map
  Future<void> setLocationFromMap(Map<String, String?> locationMap) async {
    final country = locationMap['country'];
    final state = locationMap['state'];
    final city = locationMap['city'];

    if (country != null) {
      await setSelectedCountry(country);

      if (state != null) {
        await setSelectedState(state);

        if (city != null) {
          setSelectedCity(city);
        }
      }
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Clear search suggestions
  void clearSuggestions() {
    _locationSuggestions = [];
    _searchQuery = '';
    notifyListeners();
  }

  /// Refresh all location data
  Future<void> refresh() async {
    await loadCountries();
    if (_selectedCountry != null) {
      await loadStates(_selectedCountry!);
      if (_selectedState != null) {
        await loadCities(_selectedCountry!, _selectedState!);
      }
    }
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      notifyListeners();
    }
  }

  void _setLoadingStates(bool loading) {
    _isLoadingStates = loading;
    if (loading) {
      notifyListeners();
    }
  }

  void _setLoadingCities(bool loading) {
    _isLoadingCities = loading;
    if (loading) {
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    _isLoadingStates = false;
    _isLoadingCities = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _clearStates() {
    _states = [];
    _selectedState = null;
  }

  void _clearCities() {
    _cities = [];
    _selectedCity = null;
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
