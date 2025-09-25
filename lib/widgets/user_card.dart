import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';


class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildUserInfo(context),
              if (user.addresses.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAddressInfo(context),
              ],
              if (showActions) ...[
                const SizedBox(height: 16),
                _buildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            _getInitials(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    user.isAdult ? Icons.verified_user : Icons.child_care,
                    size: 16,
                    color: user.isAdult ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${user.age} años • ${user.isAdult ? 'Adulto' : 'Niño'}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (user.addresses.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user.addresses.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.person,
            'Primer nombre',
            user.firstName,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.person_outline,
            'Apellido',
            user.lastName,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.cake,
            'Fecha de nacimiento',
            DateFormat('MMM dd, yyyy').format(user.birthDate),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfo(BuildContext context) {
    final primaryAddress = user.primaryAddress;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                'Direcciones (${user.addresses.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          if (primaryAddress != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.home,
                  size: 14,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    primaryAddress.fullAddress,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (user.addresses.length > 1) ...[
            const SizedBox(height: 4),
            Text(
              '+${user.addresses.length - 1} direccion${user.addresses.length > 2 ? 'es' : 'n'}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (onEdit != null)
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Editar'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
        if (onDelete != null)
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Borrar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade600,
            ),
          ),
      ],
    );
  }

  String _getInitials() {
    final firstInitial =
        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final lastInitial =
        user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
}
