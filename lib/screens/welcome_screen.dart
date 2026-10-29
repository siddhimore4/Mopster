import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../data/booking_storage.dart';
import '../widgets/custom_button.dart';
import 'main_nav_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late String _selectedArea;

  @override
  void initState() {
    super.initState();
    _selectedArea = BookingStorage().currentLocality.split(',').first.trim();
    if (!AppConstants.dhuleLocalities.contains(_selectedArea)) {
      _selectedArea = AppConstants.dhuleLocalities.first;
    }
  }

  void _onAreaSelected(String area) {
    setState(() {
      _selectedArea = area;
    });
    BookingStorage().updateLocality('$area, Dhule');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Brand Hero Badge
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMint,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primaryMintDark.withOpacity(0.25),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryMint.withOpacity(0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Welcome Title
              const Center(
                child: Text(
                  'Welcome to Mopster',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Your trusted partner for sparkling clean homes and flourishing gardens in Dhule.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Location Selector Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primaryMint,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Select your Dhule Locality',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Mopster is currently focused on providing fast 2-hour doorstep response across Dhule city.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Locality Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.dhuleLocalities.map((area) {
                        final isSelected = area == _selectedArea;
                        return ChoiceChip(
                          label: Text(area),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) _onAreaSelected(area);
                          },
                          selectedColor: AppColors.primaryMint,
                          backgroundColor: AppColors.surfaceMuted,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.charcoal,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primaryMint
                                  : Colors.transparent,
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Trust Highlights
              _buildFeatureRow(
                icon: Icons.verified_user_rounded,
                title: 'Verified Dhule Local Specialists',
                subtitle: 'Trained, background-checked cleaners and gardeners.',
              ),
              const SizedBox(height: 14),
              _buildFeatureRow(
                icon: Icons.currency_rupee_rounded,
                title: 'Clear Transparent Pricing',
                subtitle: 'No surprises. Pay in cash after the job is completed.',
              ),
              const SizedBox(height: 14),
              _buildFeatureRow(
                icon: Icons.eco_rounded,
                title: 'Eco-Friendly Cleaning Products',
                subtitle: 'Safe for your family, pets, and plants.',
              ),

              const SizedBox(height: 36),

              // Continue Button
              CustomButton(
                text: 'Continue in $_selectedArea',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryMintLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryMintDark, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
