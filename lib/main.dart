import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/services/location_service.dart';
import 'core/services/database_service.dart';
import 'core/services/permission_service.dart';
import 'core/repositories/photo_repository.dart';
import 'view_models/map_view_model.dart';
import 'view_models/camera_view_model.dart';
import 'view_models/home_view_model.dart';
import 'screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => PermissionService()),
        Provider(create: (_) => LocationService()),
        Provider(create: (_) => DatabaseService()),
        ProxyProvider<DatabaseService, PhotoRepository>(
          update: (_, db, __) => PhotoRepository(db),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read<PermissionService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => MapViewModel(context.read<PhotoRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CameraViewModel()..initialize(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 13/14 base size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'GPS Camera',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        );
      },
    );
  }
}
