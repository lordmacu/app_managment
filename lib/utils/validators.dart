/// Validation utilities following SOLID principles
/// S - Single Responsibility: Only handles validation logic
/// O - Open/Closed: Can be extended with new validators without modification
/// I - Interface Segregation: Specific validation methods for different data types
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  // Name validation
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'First name must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'First name can only contain letters and spaces';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Last name must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Last name can only contain letters and spaces';
    }
    return null;
  }

  // Date validation
  static String? validateBirthDate(DateTime? value) {
    if (value == null) {
      return 'Birth date is required';
    }

    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'Birth date cannot be in the future';
    }

    // Calculate age
    int age = now.year - value.year;
    if (now.month < value.month ||
        (now.month == value.month && now.day < value.day)) {
      age--;
    }

    if (age < 0 || age > 150) {
      return 'Please enter a valid birth date';
    }

    return null;
  }

  // Location validation
  static String? validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a country';
    }
    return null;
  }

  static String? validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a state/department';
    }
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a city/municipality';
    }
    return null;
  }

  // Address validation
  static String? validateDetailedAddress(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length < 5) {
        return 'Address details must be at least 5 characters';
      }
      if (value.trim().length > 200) {
        return 'Address details must be less than 200 characters';
      }
    }
    return null;
  }

  // Email validation (for future use)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailPattern).hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Phone validation (for future use)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number must be less than 15 digits';
    }

    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Generic length validation
  static String? validateLength(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
  }) {
    if (value == null) return null;

    final trimmedValue = value.trim();

    if (minLength != null && trimmedValue.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (maxLength != null && trimmedValue.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }
}
