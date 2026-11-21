import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/typography.dart';
import '../models/service_item.dart';
import '../services/ratings_service.dart';
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
        backgroundColor: AppColors.ivoryCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.softBorder, height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkCharcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          service.title,
          style: AppTypography.headingMedium(
            color: AppColors.darkCharcoal,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Service Header Card with Real Service Photograph
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.ivoryCard,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.softBorder, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkCharcoal.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Realistic Service Image Banner
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      child: SizedBox(
                        height: 210,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              service.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: isGardening
                                    ? AppColors.lightBeige
                                    : AppColors.lightBeige,
                                child: Center(
                                  child: Icon(
                                    service.icon,
                                    size: 56,
                                    color: AppColors.primaryForestGreen,
                                  ),
                                ),
                              ),
                            ),
                            // Gradient shadow overlay
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.0),
                                      Colors.black.withOpacity(0.48),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            // Service Tag (e.g. MOST POPULAR)
                            if (service.tag.isNotEmpty)
                              Positioned(
                                top: 14,
                                left: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentOlive,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    service.tag.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            // Category Icon Badge in corner
                            Positioned(
                              top: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  service.icon,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Service Info Below Image
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            service.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.headingLarge(
                              color: AppColors.darkCharcoal,
                              fontSize: 22,
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
                                  color: AppColors.lightBeige,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.secondarySage.withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  service.categoryName.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryForestGreen,
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
                                  color: AppColors.lightBeige,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.accentOlive.withOpacity(0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 12,
                                      color: AppColors.accentOlive,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'DHULE PRO',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.accentOlive,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),
                          const Divider(color: AppColors.softBorder, height: 1),
                          const SizedBox(height: 16),

                          // Stats Row (Dynamic genuine rating)
                          ListenableBuilder(
                            listenable: RatingsService(),
                            builder: (context, _) {
                              final summary = RatingsService()
                                  .getSummaryForService(service.id);
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  if (summary.hasRatings)
                                    _buildStatItem(
                                      icon: Icons.star_rounded,
                                      iconColor: const Color(0xFFD97706),
                                      title:
                                          '${summary.averageRating!.toStringAsFixed(1)} (${summary.totalReviews})',
                                      subtitle: 'Customer Rating',
                                    )
                                  else
                                    _buildStatItem(
                                      icon: Icons.verified_outlined,
                                      iconColor: AppColors.primaryForestGreen,
                                      title: 'New Service',
                                      subtitle: 'Dhule Verified',
                                    ),
                                  _buildStatItem(
                                    icon: Icons.timer_rounded,
                                    iconColor: AppColors.primaryForestGreen,
                                    title: service.duration,
                                    subtitle: 'Estimated Time',
                                  ),
                                  _buildStatItem(
                                    icon: Icons.currency_rupee_rounded,
                                    iconColor: AppColors.darkCharcoal,
                                    title: service.formattedPrice,
                                    subtitle: 'Base Price',
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Description Section
              Text(
                'About This Service',
                style: AppTypography.headingMedium(
                  color: AppColors.darkCharcoal,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.ivoryCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softBorder, width: 1.2),
                ),
                child: Text(
                  service.fullDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedGreyText,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Inclusions List
              Text(
                "What's Included",
                style: AppTypography.headingMedium(
                  color: AppColors.darkCharcoal,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.ivoryCard,
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
                              color: AppColors.lightBeige,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppColors.primaryForestGreen,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.darkCharcoal,
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

              const SizedBox(height: 24),

              // Exclusions List
              if (service.exclusions.isNotEmpty) ...[
                Text(
                  "What's Not Included",
                  style: AppTypography.headingMedium(
                    color: AppColors.darkCharcoal,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.ivoryCard,
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
                              decoration: const BoxDecoration(
                                color: AppColors.lightBeige,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.mutedGreyText,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mutedGreyText,
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
              ],

              const SizedBox(height: 24),

              // Customer Ratings & Reviews Section (strictly genuine, dynamic)
              ListenableBuilder(
                listenable: RatingsService(),
                builder: (context, _) {
                  final summary = RatingsService().getSummaryForService(service.id);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Customer Reviews',
                            style: AppTypography.headingMedium(
                              color: AppColors.darkCharcoal,
                              fontSize: 18,
                            ),
                          ),
                          if (summary.hasRatings)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lightBeige,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.softBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 16, color: Color(0xFFD97706)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${summary.averageRating!.toStringAsFixed(1)} (${summary.totalReviews})',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (summary.reviews.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.ivoryCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: AppColors.softBorder, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.lightBeige,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.rate_review_outlined,
                                    color: AppColors.primaryForestGreen, size: 20),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No customer reviews yet',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkCharcoal,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Genuine ratings appear here after customers complete their booked service.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.mutedGreyText,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: summary.reviews.take(5).map((rev) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.ivoryCard,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: AppColors.softBorder, width: 1.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        rev.customerName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkCharcoal,
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (index) => Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color: index < rev.rating.round()
                                                ? const Color(0xFFD97706)
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (rev.comment.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      rev.comment,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.mutedGreyText,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 100), // Space for sticky bottom bar
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        decoration: BoxDecoration(
          color: AppColors.ivoryCard,
          border: Border(top: BorderSide(color: AppColors.softBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkCharcoal.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
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
                    'TOTAL RATE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedGreyText,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.formattedPrice,
                    style: AppTypography.headingLarge(
                      color: AppColors.primaryForestGreen,
                      fontSize: 22,
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
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.darkCharcoal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.mutedGreyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
