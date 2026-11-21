import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/colors.dart';
import 'config/constants.dart';
import 'config/supabase_config.dart';
import 'data/booking_storage.dart';
import 'services/auth_service.dart';
import 'services/ratings_service.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Cloud Backend
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('Supabase initialization warning: $e');
  }

  // Initialize authentication service and cached session
  await AuthService().init();

  // Initialize booking persistence service (local + cloud sync)
  await BookingStorage().init();

  // Initialize genuine ratings and review repository
  await RatingsService().init();

  runApp(const MopsterApp());
}

class MopsterApp extends StatelessWidget {
  const MopsterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.forestGreen,
          onPrimary: Colors.white,
          secondary: AppColors.secondarySage,
          onSecondary: AppColors.darkCharcoal,
          tertiary: AppColors.accentOlive,
          onTertiary: Colors.white,
          surface: AppColors.cardBackground,
          onSurface: AppColors.darkCharcoal,
          background: AppColors.background,
          onBackground: AppColors.darkCharcoal,
          error: AppColors.statusCancelled,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.darkCharcoal,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.softBorder, width: 1.2),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/owner': (context) => const AdminLoginScreen(),
        '/admin': (context) => const AdminLoginScreen(),
      },
    );
  }
}
