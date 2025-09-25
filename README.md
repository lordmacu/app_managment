# User Management App

A Flutter mobile application for comprehensive user and address management, built following SOLID principles and clean architecture patterns.

## Features

- **User Management**: Create, read, update, and delete users with personal information
- **Address Management**: Multiple addresses per user with country, state, and city selection
- **Search & Filtering**: Real-time search by name with category filters
- **Data Persistence**: Local SQLite database with relational structure
- **State Management**: Provider pattern for reactive UI updates
- **Responsive UI**: Material Design 3 with adaptive layouts

## Requirements

- Flutter SDK 3.0+
- Dart 3.0+
- Android SDK / iOS development tools

## Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.0.5      # State management
  sqflite: ^2.3.0       # SQLite database
  intl: ^0.18.0         # Internationalization
  path: ^1.8.3          # File system paths

dev_dependencies:
  flutter_test: sdk: flutter
  mockito: ^5.4.2       # Testing mocks
  flutter_lints: ^2.0.0
```

## Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd user_management_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

## Database Structure

### Users Table
- `id` (TEXT PRIMARY KEY)
- `firstName` (TEXT NOT NULL)
- `lastName` (TEXT NOT NULL)
- `birthDate` (TEXT NOT NULL)
- `addresses` (TEXT NOT NULL) - JSON serialized

### Addresses Table
- `id` (TEXT PRIMARY KEY)
- `userId` (TEXT NOT NULL) - Foreign Key
- `country` (TEXT NOT NULL)
- `state` (TEXT NOT NULL)
- `city` (TEXT NOT NULL)
- `detailedAddress` (TEXT)
- `isPrimary` (INTEGER NOT NULL)

### Location Tables
- `countries` - Available countries
- `states` - States/departments by country
- `cities` - Cities/municipalities by state

## Screens

1. **User List Screen** - Main screen with search, filters, and user cards
2. **User Form Screen** - Create/edit user with personal information
3. **Address Form Screen** - Hierarchical location selection
4. **User Detail Screen** - Complete user information with tabs

## Testing Strategy

The application includes comprehensive testing coverage:

```bash
# Run all tests
flutter test


### Test Categories

- **Unit Tests**: Models, services, repositories
- **Widget Tests**: Custom components and screens
- **Integration Tests**: Database operations and provider state
- **Mock Testing**: Using Mockito for isolated testing

## Configuration

The application supports flexible data source configuration, allowing you to switch between local SQLite storage and remote API integration.

### Data Source Configuration

In `main.dart`, you can configure the data source by changing the `useSqlite` flag:

```dart
const bool useSqlite = true;  // Set to false for API mode

void main() {
  final userRepo = useSqlite
      ? UserRepositoryImpl()                                    // Local SQLite
      : UserApiRepository(baseUrl: 'http://192.168.11.7:3000'); // Remote API

  final locationRepo = useSqlite
      ? LocationRepositoryImpl()                                // Local SQLite  
      : LocationApiRepository(baseUrl: 'http://192.168.11.7:3000'); // Remote API

  runApp(MyApp(
    userRepo: userRepo,
    locationRepo: locationRepo,
  ));
}
```

### Configuration Options

**SQLite Mode** (`useSqlite = true`):
- Local data storage
- Offline functionality
- No network dependency
- Faster response times
- Visual indicator: "SQLite" banner

**API Mode** (`useSqlite = false`):
- Remote data synchronization
- Real-time data sharing
- Requires network connection
- Backend integration
- Visual indicator: "API" banner

## Backend Integration

This Flutter app works with a complementary backend service for additional functionality and data synchronization. You can switch between local SQLite storage and remote API integration.

**Backend Repository**: [https://github.com/lordmacu/server_app_managment](https://github.com/lordmacu/server_app_managment)

### API Integration Setup

To use the app with the backend API:

1. Clone and set up the backend repository
2. Configure the API base URL in `main.dart`
3. Set `useSqlite = false` to enable API mode
4. Ensure network connectivity for full functionality

The app automatically handles data synchronization and provides appropriate error handling for network-related issues.

## Key Features Implementation

### State Management
- Provider pattern with reactive UI updates
- Separated concerns with multiple providers
- Hot reload support with automatic data reloading

### Data Validation
- Client-side form validation
- Business rule validation in services
- Database constraints and relationships

### Search & Filtering
- Real-time search with debouncing
- Multiple filter categories
- Preserved search state during navigation

### Error Handling
- Comprehensive try-catch blocks
- User-friendly error messages
- Graceful degradation and recovery

## Performance Optimizations

- Lazy loading of location data
- Efficient database queries with indexes
- Provider state optimization
- Widget rebuild minimization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the established architecture patterns
4. Add tests for new functionality
5. Submit a pull request

## Code Quality

The project maintains high code quality through:

- SOLID principle adherence
- Comprehensive documentation
- Unit test coverage
- Consistent naming conventions
- Clean architecture patterns
 