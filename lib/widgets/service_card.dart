import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../models/service_item.dart';

class ServiceCard extends StatefulWidget {
  final ServiceItem service;
  final VoidCallback onTap;
  final VoidCallback? onBookNow;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.onBookNow,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final isGardening = service.category == ServiceCategory.gardening;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.softBorder, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepCharcoal.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: Icon box, Tag & Title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Icon Box with Forest / Lime gradient
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isGardening
                                  ? [const Color(0xFF15803D), AppColors.forestGreen]
                                  : [AppColors.forestGreen, const Color(0xFF0F3629)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.forestGreen.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                service.icon,
                                color: AppColors.electricLime,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title, Tag & Stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (service.tag.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricLime.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.electricLimeDark.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    service.tag.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.forestGreenDark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              Text(
                                service.title,
                                style: const TextStyle(
                                  color: AppColors.deepCharcoal,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 14,
                                          color: Color(0xFFD97706),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${service.rating}',
                                          style: const TextStyle(
                                            color: Color(0xFF92400E),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${service.reviewCount})',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 13,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    service.duration,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Short Description
                    Text(
                      service.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 14),

                    // Bottom Row: Price & Call to Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BASE PRICE',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              service.formattedPrice,
                              style: const TextStyle(
                                color: AppColors.deepCharcoal,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.forestGreen.withOpacity(0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: widget.onBookNow ?? widget.onTap,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'View & Book',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: AppColors.electricLime,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
