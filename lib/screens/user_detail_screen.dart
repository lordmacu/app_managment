import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../widgets/user_card.dart';
import 'user_form_screen.dart';
import 'address_form_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _tabController = TabController(length: 3, vsync: this);

    // Set current user in provider for potential updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().setSelectedUser(_currentUser);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      title: Text(_currentUser.fullName),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _navigateToEditUser,
          tooltip: 'Editar Usuario',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Recarcar'),
                ],
              ),
            ),

            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text('Borrar',
                      style: TextStyle(color: Colors.red.shade700)),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(icon: Icon(Icons.person), text: 'Perfil'),
          Tab(icon: Icon(Icons.location_on), text: 'Direcciones'),
          Tab(icon: Icon(Icons.analytics), text: 'Detalles'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Update current user if it changed in provider
        if (userProvider.selectedUser != null &&
            userProvider.selectedUser!.id == _currentUser.id) {
          _currentUser = userProvider.selectedUser!;
        }

        if (userProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(),
            _buildAddressesTab(),
            _buildSummaryTab(),
          ],
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, bottom: 56, left: 16, right: 16),
      child: Column(
        children: [
          UserCard(user: _currentUser),
          const SizedBox(height: 16),
          _buildPersonalInfoCard(),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información básica',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Nombre completo', _currentUser.fullName),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.badge, 'Primer nombre', _currentUser.firstName),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.badge_outlined, 'Segundo nombre', _currentUser.lastName),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.cake,
              'Fecha de nacimiento',
              DateFormat('MMMM dd, yyyy').format(_currentUser.birthDate),
            ),
            const SizedBox(height: 12),

          ],
        ),
      ),
    );
  }

  Widget _buildAddressesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildAddressesHeader(),
          const SizedBox(height: 16),
          if (_currentUser.addresses.isEmpty)
            _buildEmptyAddressesCard()
          else
            ..._currentUser.addresses.map((address) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAddressCard(address),
                )),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [

          _buildLocationSummaryCard(),
          const SizedBox(height: 16),
          _buildAccountInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildAddressesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Direcciones (${_currentUser.addresses.length})',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        ElevatedButton.icon(
          onPressed: _navigateToAddAddress,
          icon: const Icon(Icons.add),
          label: const Text('Agregar dirección'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyAddressesCard() {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aun no hay direcciones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToAddAddress,
              icon: const Icon(Icons.add_location),
              label: const Text('Agregar la primera direccion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  address.isPrimary ? Icons.home : Icons.location_on,
                  color: address.isPrimary ? Colors.blue : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.fullAddress,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressDetail('Pais', address.country),
                      _buildAddressDetail('Departamento', address.state),
                      _buildAddressDetail('Ciudad', address.city),
                      if (address.detailedAddress?.isNotEmpty == true)
                        _buildAddressDetail(
                            'Detalles', address.detailedAddress!),
                    ],
                  ),
                ),
                Column(
                  children: [

                    IconButton(
                      onPressed: () => _editAddress(address),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar dirección',
                    ),
                    IconButton(
                      onPressed: () => _deleteAddress(address.id),
                      icon: Icon(Icons.delete, color: Colors.red.shade600),
                      tooltip: 'Borrar dirección',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLocationSummaryCard() {
    if (_currentUser.addresses.isEmpty) {
      return const SizedBox.shrink();
    }


    final countries =
        _currentUser.addresses.map((addr) => addr.country).toSet();
    final states = _currentUser.addresses.map((addr) => addr.state).toSet();

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

            _buildInfoRow(Icons.public, 'Paises', countries.join(', ')),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.location_city, 'Departamentos', states.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard() {
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
            _buildInfoRow(Icons.fingerprint, 'Id', _currentUser.id),
            const SizedBox(height: 12),

          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'edit',
          onPressed: _navigateToEditUser,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.edit),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'add',
          onPressed: _navigateToAddAddress,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_location),
        ),
      ],
    );
  }

  // Event handlers
  void _handleMenuAction(String action) {
    switch (action) {

      case 'delete':
        _deleteUser();
        break;
    }
  }

  Future<void> _deleteUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar usuario'),
        content: Text(
            'Estas seguro de querer borrar a ${_currentUser.fullName}?'),
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
    final success = await userProvider.deleteUser(_currentUser.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario borrado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falla en borrado'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _editAddress(Address address) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(
          userId: _currentUser.id,
          initialAddress: address,
        ),
      ),
    );
  }

  Future<void> _deleteAddress(String addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar direccion'),
        content: const Text('¿Estas seguro que quieres borrar este dirección?'),
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
    final success =
        await userProvider.removeAddressFromUser(_currentUser.id, addressId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dirección borrada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToEditUser() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserFormScreen(initialUser: _currentUser),
      ),
    );
  }

  void _navigateToAddAddress() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(userId: _currentUser.id),
      ),
    );
  }
}
