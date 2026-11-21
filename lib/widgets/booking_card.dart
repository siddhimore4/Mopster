import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../config/typography.dart';
import '../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (booking.bookingStatus.toLowerCase().trim()) {
      case 'confirmed':
        return AppColors.statusConfirmed;
      case 'in progress':
        return AppColors.accentOlive;
      case 'completed':
        return AppColors.statusCompleted;
      case 'rejected':
      case 'cancelled':
        return AppColors.statusCancelled;
      case 'pending approval':
      case 'pending':
      default:
        return AppColors.statusPending;
    }
  }

  Color _getStatusBg() {
    switch (booking.bookingStatus.toLowerCase().trim()) {
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      default:
        return AppColors.lightBeige;
    }
  }

  IconData _getStatusIcon() {
    switch (booking.bookingStatus.toLowerCase().trim()) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'in progress':
        return Icons.autorenew_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'rejected':
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'pending approval':
      case 'pending':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  int _getLifecycleStep() {
    final status = booking.bookingStatus.toLowerCase().trim();
    if (status == 'pending approval' || status == 'pending') return 1;
    if (status == 'confirmed') return 2;
    if (status == 'in progress') return 3;
    if (status == 'completed') return 4;
    return 0; // cancelled / rejected
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEE, dd MMM yyyy').format(booking.bookingDate);
    final statusColor = _getStatusColor();
    final statusBg = _getStatusBg();
    final step = _getLifecycleStep();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.ivoryCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.softBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCharcoal.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Booking ID & Status Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBeige,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.id,
                        style: const TextStyle(
                          color: AppColors.darkCharcoal,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 13,
                            color: statusColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            booking.bookingStatus,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Service Title & Category
                Text(
                  booking.serviceTitle,
                  style: AppTypography.headingSmall(
                    color: AppColors.darkCharcoal,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBeige,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.serviceCategory,
                        style: const TextStyle(
                          color: AppColors.primaryForestGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Date & Time details box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBeige.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.softBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 15,
                            color: AppColors.primaryForestGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: AppColors.darkCharcoal,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: AppColors.primaryForestGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking.timeSlot,
                              style: const TextStyle(
                                color: AppColors.darkCharcoal,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: AppColors.primaryForestGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dhule (${booking.dhuleArea})',
                              style: const TextStyle(
                                color: AppColors.mutedGreyText,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Mini Timeline (if active status)
                if (step > 0) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildStepDot('Requested', isActive: step >= 1),
                      _buildStepConnector(isActive: step >= 2),
                      _buildStepDot('Approved', isActive: step >= 2),
                      _buildStepConnector(isActive: step >= 3),
                      _buildStepDot('In Progress', isActive: step >= 3),
                      _buildStepConnector(isActive: step >= 4),
                      _buildStepDot('Completed', isActive: step >= 4),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.softBorder),
                const SizedBox(height: 14),

                // Bottom row: Amount & View Details Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(
                            color: AppColors.mutedGreyText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          booking.formattedAmount,
                          style: AppTypography.headingMedium(
                            color: AppColors.primaryForestGreen,
                            fontSize: 19,
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
                        color: AppColors.lightBeige,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: AppColors.primaryForestGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: AppColors.primaryForestGreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepDot(String label, {required bool isActive}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryForestGreen : AppColors.softBorder,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primaryForestGreen : AppColors.mutedGreyText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Container(
      width: 14,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isActive ? AppColors.primaryForestGreen : AppColors.softBorder,
    );
  }
}
