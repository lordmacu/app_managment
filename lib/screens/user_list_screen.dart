import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../widgets/user_card.dart';
import 'user_form_screen.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Load users when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      title: const Text('Users'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
          tooltip: 'Buscar',
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
                  Text('Recargar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'statistics',
              child: Row(
                children: [
                  Icon(Icons.analytics),
                  SizedBox(width: 8),
                  Text('Estadisticas'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'clear_all',
              child: Row(
                children: [
                  Icon(Icons.clear_all, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Borrar todos', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: _buildSearchAndFilters(),
    );
  }

  PreferredSizeWidget? _buildSearchAndFilters() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'Todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('adults', 'Adultos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('minors', 'Niños'),
                  const SizedBox(width: 8),
                  _buildFilterChip('with_addresses', 'Con dirección'),
                  const SizedBox(width: 8),
                  _buildFilterChip('no_addresses', 'Sin Dirección'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _onFilterChanged(value),
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildBody() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading && !userProvider.hasUsers) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando usuarios...'),
              ],
            ),
          );
        }

        if (userProvider.hasError && !userProvider.hasUsers) {
          return _buildErrorState(userProvider);
        }

        if (!userProvider.hasUsers) {
          return _buildEmptyState();
        }

        return _buildUsersList(userProvider);
      },
    );
  }

  Widget _buildErrorState(UserProvider userProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error cargando usuarios',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              userProvider.errorMessage ?? 'Hay un error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => userProvider.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Volver a intentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay usuarios',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer usuario',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreateUser,
              icon: const Icon(Icons.person_add),
              label: const Text('Crear primer usuario'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(UserProvider userProvider) {
    final users = _getFilteredUsers(userProvider);

    if (users.isEmpty && _searchController.text.isNotEmpty) {
      return _buildNoSearchResults();
    }

    return Column(
      children: [
        // Stats header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${users.length} usuario${users.length != 1 ? 's' : ''} encontrados',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (userProvider.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        // Users list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => userProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Added bottom padding for FAB
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: UserCard(
                    user: user,
                    onTap: () => _navigateToUserDetail(user),
                    showActions: true,
                    onEdit: () => _navigateToEditUser(user),
                    onDelete: () => _deleteUser(user),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay resultados',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Cambia el filtro',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Resetear'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToCreateUser,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: const Icon(Icons.person_add),
    );
  }

  // Helper methods
  List<User> _getFilteredUsers(UserProvider userProvider) {
    List<User> users;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      users = userProvider.filteredUsers;
    } else {
      users = userProvider.users;
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'adults':
        return users.where((user) => user.isAdult).toList();
      case 'minors':
        return users.where((user) => !user.isAdult).toList();
      case 'with_addresses':
        return users.where((user) => user.addresses.isNotEmpty).toList();
      case 'no_addresses':
        return users.where((user) => user.addresses.isEmpty).toList();
      case 'all':
      default:
        return users;
    }
  }

  // Event handlers
  void _onSearchChanged(String query) {
    final userProvider = context.read<UserProvider>();
    userProvider.searchUsers(query);
  }

  void _clearSearch() {
    _searchController.clear();
    final userProvider = context.read<UserProvider>();
    userProvider.clearSearch();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _toggleSearch() {
    // Could implement a search overlay or expanded search here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Intenta buscar usuarios...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuAction(String action) {
    final userProvider = context.read<UserProvider>();

    switch (action) {
      case 'refresh':
        userProvider.refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recargando...')),
        );
        break;
      case 'statistics':
        _showStatistics();
        break;
      case 'clear_all':
        _confirmClearAll();
        break;
    }
  }

  Future<void> _showStatistics() async {
    final userProvider = context.read<UserProvider>();
    final stats = await userProvider.getUserStatistics();

    if (!mounted || stats == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estadisticas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total', stats['totalUsers'].toString()),
            _buildStatRow('Adults', stats['adultUsers'].toString()),
            _buildStatRow('Niños', stats['minorUsers'].toString()),
            _buildStatRow('Con Dirección', stats['usersWithAddresses'].toString()),
            _buildStatRow('Sin dirección', stats['usersWithoutAddresses'].toString()),
           ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar todos'),
        content: const Text(
          '¿Estas seguro que quieres borrar todos los usuarios?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Borrar todos'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.deleteAllUsers();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos los usuarios borrados'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falla al intentar borrar todos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar usuarios'),
        content: Text('Realmente quieres borrar a ${user.fullName}?'),
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

    if (confirmed == true) {
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.deleteUser(user.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} borrado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo borrar el usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigation methods
  void _navigateToCreateUser() {
    final userProvider = context.read<UserProvider>();
    userProvider.clearCurrentUser();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UserFormScreen()),
    );
  }

  void _navigateToEditUser(User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserFormScreen(initialUser: user),
      ),
    );
  }

  void _navigateToUserDetail(User user) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(user: user),
      ),
    );
    // ⬇️ Esto se ejecuta cuando el usuario regresa
    if (mounted) {
      context.read<UserProvider>().refresh();
    }
  }
}