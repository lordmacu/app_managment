import 'package:flutter/material.dart';

class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Database constants
  static const String userDatabaseName = 'user_management.db';
  static const String locationDatabaseName = 'locations.db';
  static const int databaseVersion = 1;

  // Table names
  static const String usersTable = 'users';
  static const String addressesTable = 'addresses';
  static const String countriesTable = 'countries';
  static const String statesTable = 'states';
  static const String citiesTable = 'cities';

  // Validation constants
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minAddressLength = 5;
  static const int maxAddressLength = 200;
  static const int minAge = 0;
  static const int maxAge = 150;

  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double defaultElevation = 4.0;
  static const double defaultBorderRadius = 8.0;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Cache durations
  static const Duration locationCacheDuration = Duration(hours: 1);
  static const Duration userCacheDuration = Duration(minutes: 30);

  // Error messages
  static const String genericErrorMessage = 'An unexpected error occurred';
  static const String networkErrorMessage = 'Network connection error';
  static const String validationErrorMessage = 'Please check your input';
  static const String saveErrorMessage = 'Failed to save data';
  static const String loadErrorMessage = 'Failed to load data';

  // Success messages
  static const String userCreatedMessage = 'User created successfully';
  static const String userUpdatedMessage = 'User updated successfully';
  static const String userDeletedMessage = 'User deleted successfully';
  static const String addressAddedMessage = 'Address added successfully';
  static const String addressUpdatedMessage = 'Address updated successfully';
  static const String addressDeletedMessage = 'Address deleted successfully';

  // Regex patterns
  static const String namePattern = r'^[a-zA-Z\s]+$';
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[\d\s\-\(\)]{10,15}$';

  // Date formats
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String fullDateFormat = 'MMMM dd, yyyy';
  static const String shortDateFormat = 'MM/dd/yyyy';
  static const String isoDateFormat = 'yyyy-MM-dd';
}

/// Color constants for the application
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryDarkColor = Color(0xFF1976D2);
  static const Color primaryLightColor = Color(0xFFBBDEFB);

  // Secondary colors
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryDarkColor = Color(0xFF018786);
  static const Color secondaryLightColor = Color(0xFF66FFF9);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Neutral colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text colors
  static const Color primaryTextColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color hintTextColor = Color(0xFFBDBDBD);

  // Border colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color focusedBorderColor = primaryColor;
  static const Color errorBorderColor = errorColor;

  // Shadow colors
  static const Color shadowColor = Color(0x1F000000);
  static const Color lightShadowColor = Color(0x0F000000);
}

/// Text style constants
class AppTextStyles {
  AppTextStyles._();

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryTextColor,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryTextColor,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryTextColor,
  );

  // Special styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryTextColor,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryTextColor,
    letterSpacing: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );
}
