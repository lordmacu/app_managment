import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/location_provider.dart';
import '../models/address.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import 'user_detail_screen.dart';


class AddressFormScreen extends StatefulWidget {
  final String userId;
  final Address? initialAddress;

  const AddressFormScreen({
    super.key,
    required this.userId,
    this.initialAddress,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailedAddressController = TextEditingController();

  bool _isEditing = false;
  bool _isPrimary = false;

  String? _safeDropdownValue(String? value, List<String> items) {
    if (value == null) return null;
    final matches = items.where((e) => e == value).length;
    return matches == 1 ? value : null;
  }

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialAddress != null;

    if (_isEditing) {
      _loadInitialData();
    }

     WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationData();
    });
  }

  void _loadInitialData() {
    final address = widget.initialAddress!;
    _detailedAddressController.text = address.detailedAddress ?? '';
    _isPrimary = address.isPrimary;
  }

  Future<void> _initializeLocationData() async {
    final locationProvider = context.read<LocationProvider>();

     await locationProvider.loadCountries();

    if (_isEditing) {
      final address = widget.initialAddress!;

       await locationProvider.setSelectedCountry(address.country);
      await locationProvider.setSelectedState(address.state);
      locationProvider.setSelectedCity(address.city);
    }
  }

  @override
  void dispose() {
    _detailedAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'Editar Dirección' : 'Agregar Dirección'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,

    );
  }

  Widget _buildBody() {
    return Consumer2<LocationProvider, UserProvider>(
      builder: (context, locationProvider, userProvider, child) {
        if (locationProvider.isLoading && !locationProvider.hasCountries) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLocationCard(locationProvider),
                const SizedBox(height: 16),
                _buildAddressDetailsCard(),
                const SizedBox(height: 16),

                const SizedBox(height: 16),
                _buildActionButtons(locationProvider, userProvider),
                if (locationProvider.hasError || userProvider.hasError) ...[
                  const SizedBox(height: 16),
                  _buildErrorCard(locationProvider, userProvider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationCard(LocationProvider locationProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubicación',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              value: _safeDropdownValue(
                locationProvider.selectedCountry,
                locationProvider.countries,
              ),
              labelText: 'Pais',
              hintText: 'Seleccione un pais',
              prefixIcon: Icons.public,
              items: locationProvider.countries,
              onChanged: (country) async {
                await locationProvider.setSelectedCountry(country);
              },
              validator: _validateCountry,
              isLoading: locationProvider.isLoading,
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              value: _safeDropdownValue(
                locationProvider.selectedState,
                locationProvider.states,
              ),
              labelText: 'Departamento',
              hintText: locationProvider.selectedCountry == null
                  ? 'Seleccione una ciudad primero'
                  : 'Seleccione un departamento primero ',
              prefixIcon: Icons.location_city,
              items: locationProvider.states,
              onChanged: locationProvider.selectedCountry == null
                  ? null
                  : (state) async {
                      await locationProvider.setSelectedState(state);
                    },
              validator: _validateState,
              isLoading: locationProvider.isLoadingStates,
              enabled: locationProvider.selectedCountry != null,
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              value: _safeDropdownValue(
                locationProvider.selectedCity,
                locationProvider.cities,
              ),
              labelText: 'Ciudad',
              hintText: locationProvider.selectedState == null
                  ? 'Seleccione un departamento primero'
                  : 'Seleccione una ciudad primero',
              prefixIcon: Icons.location_on,
              items: locationProvider.cities,
              onChanged: locationProvider.selectedState == null
                  ? null
                  : (city) {
                      locationProvider.setSelectedCity(city);
                    },
              validator: _validateCity,
              isLoading: locationProvider.isLoadingCities,
              enabled: locationProvider.selectedState != null,
            ),
            if (locationProvider.isLocationComplete) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ubicación: ${locationProvider.formatLocationString()}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetailsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles adicionales',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _detailedAddressController,
              labelText: 'Detalles adicionales (Opcional)',
              hintText: 'Casa, apartamento, etc',
              prefixIcon: Icons.home,
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.words,
              validator: _validateDetailedAddress,
            ),
            const SizedBox(height: 8),
            Text(
              'Ejemplo: Calle 123 #45-67, Barrio El Centro',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildActionButtons(
      LocationProvider locationProvider, UserProvider userProvider) {
    final isLoading = locationProvider.isLoading || userProvider.isLoading;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(_isEditing ? 'Actualizar Dirección' : 'Guardar Dirección'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _navigateToUserDetail,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ver detalles'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(
      LocationProvider locationProvider, UserProvider userProvider) {
    final errorMessage =
        locationProvider.errorMessage ?? userProvider.errorMessage;

    if (errorMessage == null) return const SizedBox.shrink();

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            IconButton(
              onPressed: () {
                locationProvider.clearError();
                userProvider.clearError();
              },
              icon: Icon(Icons.close, color: Colors.red.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        if (locationProvider.isLocationComplete) {
          return FloatingActionButton(
            onPressed: _validateAndShowSummary,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.check),
          );
        }
        return const SizedBox.shrink();

      },
    );
  }

  // Validation methods
  String? _validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Seleccione una ciudad';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Seleccione un Departamento';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Seleccione una ciudad';
    }
    return null;
  }

  String? _validateDetailedAddress(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length < 5) {
        return 'La direcciopn debe ser mas larga';
      }
      if (value.trim().length > 200) {
        return 'La dirección es muy larga';
      }
    }
    return null;
  }

  // Event handlers
  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final locationProvider = context.read<LocationProvider>();

    if (!locationProvider.isLocationComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione la ubicación'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate location exists in database
    final isValidLocation = await locationProvider.validateCurrentLocation();
    if (!isValidLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Verifica la ubicación'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    // Check if user has other addresses to determine if this should be primary
    final shouldBePrimary = _isPrimary ||
        currentUser?.addresses.isEmpty == true ||
        (currentUser?.addresses.length == 1 && _isEditing);

    final address = _isEditing
        ? widget.initialAddress!.copyWith(
            country: locationProvider.selectedCountry!,
            state: locationProvider.selectedState!,
            city: locationProvider.selectedCity!,
            detailedAddress: _detailedAddressController.text.trim().isNotEmpty
                ? _detailedAddressController.text.trim()
                : null,
            isPrimary: shouldBePrimary,
          )
        : Address.create(
            country: locationProvider.selectedCountry!,
            state: locationProvider.selectedState!,
            city: locationProvider.selectedCity!,
            detailedAddress: _detailedAddressController.text.trim().isNotEmpty
                ? _detailedAddressController.text.trim()
                : null,
            isPrimary: shouldBePrimary,
          );

    bool success;

    if (_isEditing) {
      success = await userProvider.updateUserAddress(
        widget.userId,
        widget.initialAddress!.id,
        address,
      );
    } else {
      success = await userProvider.addAddressToUser(widget.userId, address);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Dirección actualizada correctamente'
              : 'Dirección agregada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to user detail screen
      _navigateToUserDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.errorMessage ?? 'Hay un fallo agregando la dirección'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _validateAndShowSummary() async {
    final locationProvider = context.read<LocationProvider>();



    final isValid = await locationProvider.validateCurrentLocation();

    if (!mounted) return;

    if (isValid) {
      _showLocationSummary();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Verifica la dirección'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showLocationSummary() {
    final locationProvider = context.read<LocationProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resumen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pais: ${locationProvider.selectedCountry}'),
            Text('Departamento: ${locationProvider.selectedState}'),
            Text('Ciudad: ${locationProvider.selectedCity}'),
            if (_detailedAddressController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Detalles: ${_detailedAddressController.text.trim()}'),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade700, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Location verified',
                    style:
                        TextStyle(color: Colors.green.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Listo!!'),
          ),
        ],
      ),
    );
  }


  void _navigateToUserDetail() {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(user: currentUser),
      ),
    );
  }
}
