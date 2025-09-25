import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final List<T> items;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isLoading;
  final String Function(T)? itemDisplayText;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.isLoading = false,
    this.itemDisplayText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      onChanged: enabled && !isLoading ? onChanged : null,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: _buildPrefixIcon(),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: _getFillColor(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: _buildDropdownItems(),
      icon: _buildSuffixIcon(),
      isExpanded: true,
      style: TextStyle(
        color: enabled ? Colors.black87 : Colors.grey.shade600,
      ),
      dropdownColor: Colors.white,
      menuMaxHeight: 300,
    );
  }

  Widget? _buildPrefixIcon() {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    return prefixIcon != null ? Icon(prefixIcon) : null;
  }

  Widget _buildSuffixIcon() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Icon(
      Icons.arrow_drop_down,
      color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
    );
  }

  Color _getFillColor() {
    if (!enabled) return Colors.grey.shade100;
    if (isLoading) return Colors.grey.shade50;
    return Colors.white;
  }

  List<DropdownMenuItem<T>>? _buildDropdownItems() {
    if (isLoading || items.isEmpty) {
      return [
        DropdownMenuItem<T>(
          value: null,
          enabled: false,
          child: Text(
            isLoading ? 'Cargando...' : 'No hay items aun',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ];
    }

    return items.map((T item) {
      return DropdownMenuItem<T>(
        value: item,
        child: Text(
          itemDisplayText?.call(item) ?? item.toString(),
          style: const TextStyle(
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }
}
