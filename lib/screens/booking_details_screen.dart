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
        return AppColors.statusConfirmed;
      case 'in progress':
        return const Color(0xFF7C3AED);
      case 'completed':
        return AppColors.statusCompleted;
      case 'rejected':
      case 'cancelled':
        return AppColors.statusCancelled;
      case 'pending approval':
      case 'pending':
      default:
        return const Color(0xFFD97706);
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase().trim()) {
      case 'confirmed':
        return AppColors.accentSoftGreen;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Cancel Booking Request?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel booking ${_currentBooking.id} for ${_currentBooking.serviceTitle}?',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Keep Booking',
                style: TextStyle(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _performCancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusCancelled,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
    });

    if (success) {
      setState(() {
        _currentBooking = _currentBooking.copyWith(
          bookingStatus: 'Cancelled',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.charcoal,
          content: Text('Booking has been cancelled.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.statusCancelled,
          content: Text('Failed to cancel booking. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        DateFormat('EEEE, dd MMMM yyyy').format(_currentBooking.bookingDate);
    final statusColor = _getStatusColor(_currentBooking.bookingStatus);
    final statusBg = _getStatusBg(_currentBooking.bookingStatus);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.charcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentBooking.id,
          style: const TextStyle(
            color: AppColors.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
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
                              'Current Status',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentBooking.bookingStatus,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
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
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
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

              const SizedBox(height: 20),

              // Service & Price
              _buildSectionTitle('Service Info'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentBooking.serviceTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentBooking.serviceCategory,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _currentBooking.formattedAmount,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Schedule & Appointment Details
              _buildSectionTitle('Requested Schedule & Address'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'Preferred Date',
                      value: dateFormatted,
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Preferred Slot',
                      value: _currentBooking.timeSlot,
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Customer',
                      value:
                          '${_currentBooking.customerName}\n${_currentBooking.customerPhone}',
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Dhule Address',
                      value:
                          '${_currentBooking.fullAddress}\nLocality: ${_currentBooking.dhuleArea}, Dhule',
                    ),
                    if (_currentBooking.specialInstructions.isNotEmpty) ...[
                      const Divider(height: 20, color: AppColors.divider),
                      _buildDetailRow(
                        icon: Icons.notes_rounded,
                        label: 'Instructions',
                        value: _currentBooking.specialInstructions,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Assigned Worker & Payment Details
              _buildSectionTitle('Staff & Payment'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Assigned Staff',
                      value: _currentBooking.assignedStaff,
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow(
                      icon: Icons.payments_outlined,
                      label: 'Payment Method',
                      value: _currentBooking.paymentMethod,
                    ),
                    const Divider(height: 20, color: AppColors.divider),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.hourglass_top_rounded,
                color: Color(0xFFB45309), size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Awaiting Owner Approval: Your booking request is being reviewed by the Mopster business owner. Once approved, the status will update to Confirmed.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF92400E),
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentBooking.isConfirmed) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accentSoftGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.check_circle_rounded,
                color: AppColors.primaryMintDark, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Booking Confirmed: The business owner has approved your appointment. Our Dhule team will arrive at your requested time slot.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryMintDark,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentBooking.isInProgress) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.build_circle_rounded,
                color: Color(0xFF7C3AED), size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Service In Progress: Our specialist is currently executing the service at your address.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6D28D9),
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentBooking.isRejected) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.cancel_rounded,
                color: AppColors.statusCancelled, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Request Declined: The business owner was unable to accommodate this request. Please contact support or book another slot.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.statusCancelled,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentBooking.isCompleted) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFDBEAFE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.task_alt_rounded,
                color: AppColors.statusCompleted, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Service Completed: Thank you for trusting Mopster for your home in Dhule!',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1E40AF),
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentBooking.isCancelled) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info_outline_rounded,
                color: AppColors.statusCancelled, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'This booking was cancelled. No charges were incurred.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.statusCancelled,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.charcoal,
      ),
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
        Icon(icon, size: 18, color: AppColors.primaryMintDark),
        const SizedBox(width: 10),
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
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
              color: AppColors.charcoal,
            ),
          ),
        ),
      ],
    );
  }
}
