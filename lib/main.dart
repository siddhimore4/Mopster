import 'package:flutter/material.dart';
import 'config/colors.dart';
import 'config/constants.dart';
import 'data/booking_storage.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline booking persistence service
  await BookingStorage().init();

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryMint,
          primary: AppColors.primaryMint,
          secondary: AppColors.primaryMintDark,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.charcoal,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderLight),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
