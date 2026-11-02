import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../models/service_item.dart';
import '../widgets/custom_button.dart';
import 'booking_form_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServiceItem service;

  const ServiceDetailScreen({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final isGardening = service.category == ServiceCategory.gardening;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.deepCharcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          service.title,
          style: const TextStyle(
            color: AppColors.deepCharcoal,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Service Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.softBorder, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepCharcoal.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icon Emblem Box
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isGardening
                              ? [const Color(0xFF15803D), AppColors.forestGreen]
                              : [AppColors.forestGreen, const Color(0xFF0F3629)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestGreen.withOpacity(0.24),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        service.icon,
                        size: 40,
                        color: AppColors.electricLime,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      service.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepCharcoal,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Category & Verified Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreenLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.forestGreen.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            service.categoryName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.forestGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.electricLime.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: AppColors.forestGreenDark,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'DHULE PRO',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.forestGreenDark,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 16),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFFD97706),
                          title: '${service.rating} (${service.reviewCount})',
                          subtitle: 'Verified Rating',
                        ),
                        _buildStatItem(
                          icon: Icons.timer_rounded,
                          iconColor: AppColors.forestGreen,
                          title: service.duration,
                          subtitle: 'Estimated Time',
                        ),
                        _buildStatItem(
                          icon: Icons.currency_rupee_rounded,
                          iconColor: AppColors.deepCharcoal,
                          title: service.formattedPrice,
                          subtitle: 'Base Price',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // Description Section
              const Text(
                'About This Service',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepCharcoal,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softBorder, width: 1.2),
                ),
                child: Text(
                  service.fullDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // Inclusions List
              const Text(
                "What's Included",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepCharcoal,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softBorder, width: 1.2),
                ),
                child: Column(
                  children: service.inclusions.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.forestGreenLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppColors.forestGreen,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.deepCharcoal,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 26),

              // Exclusions List
              if (service.exclusions.isNotEmpty) ...[
                const Text(
                  "What's Not Included",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepCharcoal,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.softBorder, width: 1.2),
                  ),
                  child: Column(
                    children: service.exclusions.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textMuted,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 26),
              ],

              // Dhule Service Area Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.forestGreenLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.forestGreen.withOpacity(0.18),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.location_on_rounded,
                      color: AppColors.forestGreen,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Direct doorstep service available throughout Dhule city & surrounding sectors.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.deepCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: AppColors.softBorder, width: 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepCharcoal.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BASE RATE',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    service.formattedPrice,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepCharcoal,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomButton(
                  text: 'Book This Service',
                  icon: Icons.calendar_today_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookingFormScreen(service: service),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.deepCharcoal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
