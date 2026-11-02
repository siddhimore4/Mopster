import 'dart:async';
import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'main_nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (scale, fade, slide-up)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Continuous breathing & floating animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _entranceController.forward();

    // Check persistent login session after 2.3 seconds
    _timer = Timer(const Duration(milliseconds: 2300), () {
      if (mounted) {
        final isLoggedIn = AuthService().isLoggedIn;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) =>
                isLoggedIn ? const MainNavScreen() : const LoginScreen(),
            transitionsBuilder: (context, anim1, anim2, child) {
              return FadeTransition(opacity: anim1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: Stack(
        children: [
          // Ambient organic gradient circles in the background
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.freshMint.withOpacity(0.55),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.electricLime.withOpacity(0.22),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Mopster Brand Logo with Ambient Glow
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final pulse = _pulseAnimation.value;
                            return Transform.translate(
                              offset: Offset(0, -6 * pulse),
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  // Pulsing ambient glow
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(42),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.forestGreen.withOpacity(
                                            0.18 + (0.12 * pulse),
                                          ),
                                          blurRadius: 30 + (12 * pulse),
                                          spreadRadius: 2 + (4 * pulse),
                                          offset: const Offset(0, 10),
                                        ),
                                        BoxShadow(
                                          color: AppColors.electricLime.withOpacity(
                                            0.25 + (0.15 * pulse),
                                          ),
                                          blurRadius: 20 + (8 * pulse),
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Logo Card
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: AppColors.forestGreen,
                                      borderRadius: BorderRadius.circular(36),
                                      border: Border.all(
                                        color: AppColors.electricLime.withOpacity(0.8),
                                        width: 2.2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(33),
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  // Sparkle accent on top-right of logo
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: Transform.rotate(
                                      angle: 0.25 * pulse,
                                      child: Transform.scale(
                                        scale: 0.9 + (0.25 * pulse),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.electricLime,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.electricLime.withOpacity(0.5),
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome_rounded,
                                            size: 16,
                                            color: AppColors.deepCharcoal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // Brand Name (Required for widget test)
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepCharcoal,
                            letterSpacing: -0.8,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tagline Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreenLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.forestGreen.withOpacity(0.18),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            AppConstants.appTagline,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forestGreen,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // City Badge
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.softBorder,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: AppColors.forestGreen,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Dhule, Maharashtra',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.deepCharcoal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // Clean loading indicator with forest/lime accent
                        const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
