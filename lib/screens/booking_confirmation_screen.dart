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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Animated/Glow Success Badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryMint,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryMint.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),

              const SizedBox(height: 24),

              // Headline
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.charcoal,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your home service has been scheduled. Our local Dhule team has received your request.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Booking Details Card
              Container(
                width: double.infinity,
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
                  children: [
                    // Booking ID & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking ID',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              booking.id,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentSoftGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppColors.primaryMintDark,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Confirmed',
                                style: TextStyle(
                                  color: AppColors.primaryMintDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24, color: AppColors.divider),

                    _buildInfoRow('Service', booking.serviceTitle),
                    const SizedBox(height: 10),
                    _buildInfoRow('Scheduled Date', dateFormatted),
                    const SizedBox(height: 10),
                    _buildInfoRow('Time Slot', booking.timeSlot),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                        'Location', '${booking.dhuleArea}, Dhule'),
                    const SizedBox(height: 10),
                    _buildInfoRow('Amount Due', booking.formattedAmount),
                    const SizedBox(height: 10),
                    _buildInfoRow('Payment', 'Cash on Delivery'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Local Dispatch Note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryMintLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryMintDark,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Saved to device storage. You can view or cancel this booking anytime under "My Bookings".',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.charcoal,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}
