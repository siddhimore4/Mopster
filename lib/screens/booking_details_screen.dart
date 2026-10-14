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
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.statusConfirmed;
      case 'completed':
        return AppColors.statusCompleted;
      case 'cancelled':
        return AppColors.statusCancelled;
      case 'pending':
      default:
        return AppColors.statusPending;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.accentSoftGreen;
      case 'completed':
        return const Color(0xFFDBEAFE);
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      case 'pending':
      default:
        return const Color(0xFFFEF3C7);
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
            'Cancel Booking?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel appointment ${_currentBooking.id} for ${_currentBooking.serviceTitle}?',
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
                child: Row(
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
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentBooking.bookingStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
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
              _buildSectionTitle('Schedule & Address'),
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
                      label: 'Date',
                      value: dateFormatted,
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time Window',
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

              // Cancellation Action (Eligible when Confirmed or Pending)
              if (_currentBooking.canCancel)
                CustomButton(
                  text: 'Cancel This Booking',
                  isOutlined: true,
                  icon: Icons.cancel_outlined,
                  isLoading: _isCancelling,
                  onPressed: _showCancelDialog,
                )
              else if (_currentBooking.bookingStatus == 'Cancelled')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'This booking was cancelled. No charges incurred.',
                      style: TextStyle(
                        color: AppColors.statusCancelled,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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
