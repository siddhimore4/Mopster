import 'package:flutter/material.dart';
import '../config/colors.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavScreen> createState() => MainNavScreenState();
}

class MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        onNavigateToBookings: () => switchTab(1),
        onNavigateToProfile: () => switchTab(2),
      ),
      const MyBookingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.softBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepCharcoal.withOpacity(0.08),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.forestGreen.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Home',
                selectedIcon: Icons.home_rounded,
                unselectedIcon: Icons.home_outlined,
              ),
              _buildNavItem(
                index: 1,
                label: 'Bookings',
                selectedIcon: Icons.calendar_month_rounded,
                unselectedIcon: Icons.calendar_today_outlined,
              ),
              _buildNavItem(
                index: 2,
                label: 'Profile',
                selectedIcon: Icons.person_rounded,
                unselectedIcon: Icons.person_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData selectedIcon,
    required IconData unselectedIcon,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => switchTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.forestGreen.withOpacity(0.26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              size: 20,
              color: isSelected ? AppColors.electricLime : AppColors.mutedGrey,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
