import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../models/booking_model.dart';
import '../widgets/custom_button.dart';
import 'main_nav_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        DateFormat('EEEE, dd MMMM yyyy').format(booking.bookingDate);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Animated Celebratory Badge
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.freshMint.withOpacity(0.5),
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.electricLime,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forestGreen.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.hourglass_top_rounded,
                        color: Color(0xFFD97706),
                        size: 44,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Headline
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Request Submitted!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepCharcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text('🌱', style: TextStyle(fontSize: 24)),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'Your booking request has been submitted and is currently awaiting owner approval. We will review your preferred slot shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedGrey,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              // Booking Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.softBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Booking ID & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BOOKING REFERENCE',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.mutedGrey,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.id,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.forestGreen,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.access_time_filled_rounded,
                                size: 14,
                                color: Color(0xFFB45309),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Pending Approval',
                                style: TextStyle(
                                  color: Color(0xFFB45309),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 28, color: AppColors.softBorder),

                    _buildInfoRow('Service', booking.serviceTitle),
                    const SizedBox(height: 12),
                    _buildInfoRow('Preferred Date', dateFormatted),
                    const SizedBox(height: 12),
                    _buildInfoRow('Preferred Slot', booking.timeSlot),
                    const SizedBox(height: 12),
                    _buildInfoRow('Location', '${booking.dhuleArea}, Dhule'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Amount Due', booking.formattedAmount,
                        isHighlight: true),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Payment', 'Cash on Delivery (Pay after service)'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Owner Approval Warning Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFB45309),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Notice: Your service is NOT yet confirmed. The business owner in Dhule will review and confirm availability. You will see the updated status in "My Bookings" once approved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Buttons
              CustomButton(
                text: 'View in My Bookings',
                icon: Icons.calendar_month_rounded,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MainNavScreen(initialIndex: 1),
                    ),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 12),

              CustomButton(
                text: 'Back to Home',
                isOutlined: true,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MainNavScreen(initialIndex: 0),
                    ),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.mutedGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
            color: isHighlight ? AppColors.forestGreen : AppColors.deepCharcoal,
          ),
        ),
      ],
    );
  }
}
