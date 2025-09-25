import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'contracts/user_repository_contract.dart';
import 'contracts/location_repository_contract.dart';
import 'contracts/user_service_contract.dart';
import 'contracts/location_service_contract.dart';

import 'repositories/user_repository.dart';           // SQLite
import 'repositories/location_repository.dart';       // SQLite
import 'repositories/user_api_repository.dart';       // API
import 'repositories/location_api_repository.dart';   // API

import 'services/user_service_impl.dart';
import 'services/location_service_impl.dart';

import 'providers/user_provider.dart';
import 'providers/location_provider.dart';
import 'screens/user_list_screen.dart';

 const bool useSqlite = true;

void main() {
   final userRepo = useSqlite
      ? UserRepositoryImpl()
      : UserApiRepository(baseUrl: 'http://192.168.11.7:3000');

  final locationRepo = useSqlite
      ? LocationRepositoryImpl()
      : LocationApiRepository(baseUrl: 'http://192.168.11.7:3000');

  runApp(MyApp(
    userRepo: userRepo,
    locationRepo: locationRepo,
  ));
}

class MyApp extends StatelessWidget {
  final UserRepositoryContract userRepo;
  final LocationRepositoryContract locationRepo;

  const MyApp({
    super.key,
    required this.userRepo,
    required this.locationRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserRepositoryContract>(create: (_) => userRepo),
        Provider<LocationRepositoryContract>(create: (_) => locationRepo),

        ProxyProvider<UserRepositoryContract, UserServiceContract>(
          update: (_, repo, __) => UserServiceImpl(repo),
        ),
        ProxyProvider<LocationRepositoryContract, LocationServiceContract>(
          update: (_, repo, __) => LocationServiceImpl(repo),
        ),

        ChangeNotifierProxyProvider<UserServiceContract, UserProvider>(
          lazy: false,
          create: (context) => UserProvider(
            Provider.of<UserServiceContract>(context, listen: false),
          )..bootstrap(),
          update: (_, service, notifier) {
            notifier!.updateService(service);
            return notifier;
          },
        ),
        ChangeNotifierProxyProvider<LocationServiceContract, LocationProvider>(
          lazy: false,
          create: (context) => LocationProvider(
            Provider.of<LocationServiceContract>(context, listen: false),
          )..bootstrap(),
          update: (_, service, notifier) {
            notifier!.updateService(service);
            return notifier;
          },
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Banner(
          message: useSqlite ? 'SQLite' : 'API',
          location: BannerLocation.topStart,
          child: UserListScreen(),
        ),
      ),
    );
  }
}
