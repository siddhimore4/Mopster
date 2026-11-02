import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../data/booking_storage.dart';
import '../models/booking_model.dart';
import '../widgets/custom_button.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late BookingModel _currentBooking;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'confirmed':
        return const Color(0xFF15803D);
      case 'in progress':
        return const Color(0xFF7C3AED);
      case 'completed':
        return const Color(0xFF2563EB);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFDC2626);
      case 'pending approval':
      case 'pending':
      default:
        return const Color(0xFFD97706);
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase().trim()) {
      case 'confirmed':
        return const Color(0xFFDCFCE7);
      case 'in progress':
        return const Color(0xFFEDE9FE);
      case 'completed':
        return const Color(0xFFDBEAFE);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      case 'pending approval':
      case 'pending':
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase().trim()) {
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Cancel Booking Request?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.deepCharcoal,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel booking ${_currentBooking.id} for ${_currentBooking.serviceTitle}?',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mutedGrey,
              height: 1.45,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Keep Booking',
                style: TextStyle(
                  color: AppColors.deepCharcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _performCancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performCancel() async {
    setState(() {
      _isCancelling = true;
    });

    final success = await BookingStorage().cancelBooking(_currentBooking.id);

    if (!mounted) return;

    setState(() {
      _isCancelling = false;
      if (success) {
        _currentBooking = _currentBooking.copyWith(
          bookingStatus: 'Cancelled',
        );
      }
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.forestGreen,
          content: const Text('Booking request cancelled successfully.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFFDC2626),
          content: const Text('Could not cancel booking. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_currentBooking.bookingStatus);
    final statusBg = _getStatusBg(_currentBooking.bookingStatus);
    final dateFormatted =
        DateFormat('EEEE, dd MMMM yyyy').format(_currentBooking.bookingDate);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softBorder),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.deepCharcoal,
                  size: 16,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        title: Text(
          _currentBooking.id,
          style: const TextStyle(
            color: AppColors.deepCharcoal,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Banner Card
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
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CURRENT STATUS',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.mutedGrey,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _currentBooking.bookingStatus,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: statusColor,
                                letterSpacing: -0.2,
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
                                _getStatusIcon(_currentBooking.bookingStatus),
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _currentBooking.bookingStatus,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Descriptive status helper box
                    _buildStatusExplanationBox(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Service & Price
              _buildSectionTitle('Service Info'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentBooking.serviceTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepCharcoal,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.freshMint.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _currentBooking.serviceCategory,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _currentBooking.formattedAmount,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Schedule & Appointment Details
              _buildSectionTitle('Requested Schedule & Address'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'Preferred Date',
                      value: dateFormatted,
                    ),
                    const Divider(height: 24, color: AppColors.softBorder),
                    _buildDetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Preferred Slot',
                      value: _currentBooking.timeSlot,
                    ),
                    const Divider(height: 24, color: AppColors.softBorder),
                    _buildDetailRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Customer',
                      value:
                          '${_currentBooking.customerName}\n${_currentBooking.customerPhone}',
                    ),
                    const Divider(height: 24, color: AppColors.softBorder),
                    _buildDetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Dhule Address',
                      value:
                          '${_currentBooking.fullAddress}\nLocality: ${_currentBooking.dhuleArea}, Dhule',
                    ),
                    if (_currentBooking.specialInstructions.isNotEmpty) ...[
                      const Divider(height: 24, color: AppColors.softBorder),
                      _buildDetailRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Instructions',
                        value: _currentBooking.specialInstructions,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Assigned Worker & Payment Details
              _buildSectionTitle('Staff & Payment'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Assigned Staff',
                      value: _currentBooking.assignedStaff,
                    ),
                    const Divider(height: 24, color: AppColors.softBorder),
                    _buildDetailRow(
                      icon: Icons.payments_outlined,
                      label: 'Payment Method',
                      value: _currentBooking.paymentMethod,
                    ),
                    const Divider(height: 24, color: AppColors.softBorder),
                    _buildDetailRow(
                      icon: Icons.receipt_rounded,
                      label: 'Payment Status',
                      value: _currentBooking.paymentStatus,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Cancellation Action (Allowed only when Pending Approval or Confirmed)
              if (_currentBooking.canCancel)
                CustomButton(
                  text: 'Cancel This Booking',
                  isOutlined: true,
                  icon: Icons.cancel_outlined,
                  isLoading: _isCancelling,
                  onPressed: _showCancelDialog,
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusExplanationBox() {
    if (_currentBooking.isPendingApproval) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.hourglass_top_rounded,
                color: Color(0xFFB45309), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Awaiting Owner Approval: Your booking request is being reviewed by the Mopster business owner. Once approved, the status will update to Confirmed.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF92400E),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentBooking.isConfirmed) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.freshMint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.check_circle_rounded,
                color: AppColors.forestGreen, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Booking Confirmed: The business owner has approved your appointment. Our Dhule team will arrive at your requested time slot.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.forestGreen,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentBooking.isInProgress) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.build_circle_rounded,
                color: Color(0xFF7C3AED), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Service In Progress: Our specialist is currently executing the service at your address.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6D28D9),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentBooking.isRejected) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.cancel_rounded,
                color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Request Declined: The business owner was unable to accommodate this request. Please contact support or book another slot.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF991B1B),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentBooking.isCompleted) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFDBEAFE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.task_alt_rounded,
                color: Color(0xFF2563EB), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Service Completed: Thank you for trusting Mopster for your home in Dhule!',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1E40AF),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentBooking.isCancelled) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info_outline_rounded,
                color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'This booking was cancelled. No charges were incurred.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF991B1B),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.electricLime,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.deepCharcoal,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.freshMint.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.forestGreen),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.deepCharcoal,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
