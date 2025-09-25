import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:user_management_app/models/address.dart';
import '../providers/user_provider.dart';
import '../providers/location_provider.dart';
import '../models/user.dart';
import '../widgets/custom_text_field.dart';
import 'address_form_screen.dart';
import 'user_detail_screen.dart';

class UserFormScreen extends StatefulWidget {
  final User? initialUser;

  const UserFormScreen({super.key, this.initialUser});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  DateTime? _selectedBirthDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialUser != null;

    if (_isEditing) {
      _loadInitialData();
    } else {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserProvider>().clearCurrentUser();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadCountries();
    });
  }

  void _loadInitialData() {
    final user = widget.initialUser!;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _selectedBirthDate = user.birthDate;

     WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().setCurrentUser(user);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
      title: Text(_isEditing ? 'Editar Usuario' : 'Creear Usuario'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      actions: [
        if (_isEditing)
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: _navigateToUserDetail,
            tooltip: 'Detalles',
          ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer2<UserProvider, LocationProvider>(
      builder: (context, userProvider, locationProvider, child) {
        if (userProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 56),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUserInfoCard(),
                const SizedBox(height: 16),
                _buildAddressesCard(userProvider),
                const SizedBox(height: 16),
                _buildActionButtons(userProvider),
                if (userProvider.hasError) ...[
                  const SizedBox(height: 16),
                  _buildErrorCard(userProvider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _firstNameController,
              labelText: 'Primer nobmre',
              hintText: 'Ingresa el primer nombre',
              prefixIcon: Icons.person,
              validator: _validateFirstName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _lastNameController,
              labelText: 'Apellido',
              hintText: 'Ingresa el apellido',
              prefixIcon: Icons.person_outline,
              validator: _validateLastName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            _buildBirthDateField(),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthDateField() {
    return InkWell(
      onTap: _selectBirthDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de nacimiento',
          hintText: 'Selecciona una fecha de nacimiento',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _selectedBirthDate != null
              ? DateFormat('MMM dd, yyyy').format(_selectedBirthDate!)
              : 'Selecciona una fecha de nacimiento',
          style: TextStyle(
            color: _selectedBirthDate != null
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressesCard(UserProvider userProvider) {
    final currentUser = userProvider.currentUser;
    final addresses = _isEditing ? (currentUser?.addresses ?? []) : const <Address>[];

    if(!_isEditing){
      return Container();
    }
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Direcciones',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _navigateToAddressForm,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar dirección'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (addresses.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 48,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aún no hay direcciones',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),

                  ],
                ),
              )
            else
              ...addresses.map((address) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: Icon(
                          address.isPrimary ? Icons.home : Icons.location_on,
                          color: address.isPrimary ? Colors.blue : Colors.grey,
                        ),
                        title: Text(address.fullAddress),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editAddress(address.id),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteAddress(address.id),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(UserProvider userProvider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: userProvider.isLoading ? null : _saveUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: userProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(_isEditing ? 'Actualizar usuario' : 'Crear usuario'),
          ),
        ),
        const SizedBox(height: 8),
        if (_isEditing)
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

  Widget _buildErrorCard(UserProvider userProvider) {
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
                userProvider.errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            IconButton(
              onPressed: () => userProvider.clearError(),
              icon: Icon(Icons.close, color: Colors.red.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentUser = userProvider.currentUser;

        if (currentUser != null && currentUser.addresses.isNotEmpty) {
          return FloatingActionButton(
            onPressed: _navigateToUserDetail,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.visibility),
          );
        }

        return FloatingActionButton(
          onPressed: _navigateToAddressForm,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_location),
        );
      },
    );
  }

  // Form validation methods
  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Primer nombre requerido';
    }
    if (value.trim().length < 2) {
      return 'El primer nombre esta muy corto';
    }
    if (value.trim().length > 50) {
      return 'El primer nombre esta muy largo ';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Solo puede tener letras';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Apellido requerido';
    }
    if (value.trim().length < 2) {
      return 'El apellido nombre esta muy corto';
    }
    if (value.trim().length > 50) {
      return 'El apellido nombre esta muy largo ';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Solo puede tener letras';
    }
    return null;
  }

  // Event handlers
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecciona fecha de nacimiento',
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione una fecha'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    final userProvider = context.read<UserProvider>();

    // Additional validation using service
    if (!userProvider.validateUserData(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      birthDate: _selectedBirthDate!,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data invalida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool success;

    if (_isEditing) {
      final updatedUser = widget.initialUser!.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _selectedBirthDate!,
      );
      success = await userProvider.updateUser(updatedUser);
    } else {
      success = await userProvider.createUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _selectedBirthDate!,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Se ha actualizado con éxito'
              : 'Se ha creado con éxito'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to address form if it's a new user
      if (!_isEditing) {
        _navigateToAddressForm();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.errorMessage ?? 'Falla al guardar el usuario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editAddress(String addressId) async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return;

    final address = currentUser.addresses.firstWhere(
      (addr) => addr.id == addressId,
      orElse: () => throw StateError('Problema con la dirección'),
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(
          userId: currentUser.id,
          initialAddress: address,
        ),
      ),
    );
  }

  Future<void> _deleteAddress(String addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar dirección'),
        content: const Text('¿Quieres borrar esta dirección?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return;

    final success =
        await userProvider.removeAddressFromUser(currentUser.id, addressId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dirección borrada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fallo al borrar la dirección'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToAddressForm() {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor crear un usuario primero '),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(userId: currentUser.id),
      ),
    );
  }

  void _navigateToUserDetail() {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falla en el usuario, intenta de nuevo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(user: currentUser),
      ),
    );
  }
}
