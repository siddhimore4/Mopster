import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../data/booking_storage.dart';
import '../models/booking_model.dart';
import '../models/service_item.dart';
import '../widgets/custom_button.dart';
import 'booking_confirmation_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final ServiceItem service;
  final String customerName;
  final String customerPhone;
  final String dhuleArea;
  final String fullAddress;
  final DateTime bookingDate;
  final String timeSlot;
  final String specialInstructions;

  const BookingSummaryScreen({
    super.key,
    required this.service,
    required this.customerName,
    required this.customerPhone,
    required this.dhuleArea,
    required this.fullAddress,
    required this.bookingDate,
    required this.timeSlot,
    required this.specialInstructions,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  String _selectedPaymentMethod = 'cash'; // 'cash' or 'online_gateway'
  bool _isSubmitting = false;

  String _generateBookingId() {
    final randomDigits = 1000 + Random().nextInt(9000);
    return 'MOP-DHU-$randomDigits';
  }

  Future<void> _handleConfirmBooking() async {
    setState(() {
      _isSubmitting = true;
    });

    final newBooking = BookingModel(
      id: _generateBookingId(),
      serviceId: widget.service.id,
      serviceTitle: widget.service.title,
      serviceCategory: widget.service.categoryName,
      totalAmount: widget.service.basePrice,
      customerName: widget.customerName,
      customerPhone: widget.customerPhone,
      dhuleArea: widget.dhuleArea,
      fullAddress: widget.fullAddress,
      bookingDate: widget.bookingDate,
      timeSlot: widget.timeSlot,
      specialInstructions: widget.specialInstructions,
      paymentMethod: _selectedPaymentMethod == 'cash'
          ? 'Cash on Delivery (Pay after service)'
          : 'Razorpay Online Gateway (Future)',
      paymentStatus: 'Pending (Pay upon completion)',
      bookingStatus: 'Confirmed',
      assignedStaff: 'Mopster Dhule Specialist Team',
      createdAt: DateTime.now(),
    );

    // Save to local device storage via BookingStorage
    final success = await BookingStorage().addBooking(newBooking);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(booking: newBooking),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.statusCancelled,
          content: Text(
            'Failed to save booking to local storage. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        DateFormat('EEEE, dd MMMM yyyy').format(widget.bookingDate);

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
        title: const Text(
          'Booking Summary',
          style: TextStyle(
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
              // 1. Service Review Card
              _buildSectionTitle('Selected Service'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryMintLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.service.icon,
                        color: AppColors.primaryMintDark,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Duration: ${widget.service.duration}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.service.formattedPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Schedule & Location Details
              _buildSectionTitle('Appointment & Dhule Address'),
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
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: dateFormatted,
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time Window',
                      value: widget.timeSlot,
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow(
                      icon: Icons.person_rounded,
                      label: 'Customer',
                      value: '${widget.customerName} (${widget.customerPhone})',
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Service Address',
                      value:
                          '${widget.fullAddress}\nLocality: ${widget.dhuleArea}, Dhule',
                    ),
                    if (widget.specialInstructions.isNotEmpty) ...[
                      const Divider(height: 20, color: AppColors.divider),
                      _buildDetailRow(
                        icon: Icons.notes_rounded,
                        label: 'Instructions',
                        value: widget.specialInstructions,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Payment Mode (Requirement 7)
              _buildSectionTitle('Payment Method'),
              const SizedBox(height: 4),
              const Text(
                'Choose how you would like to settle the service charges:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),

              // Option A: Cash on Delivery (ACTIVE)
              Container(
                decoration: BoxDecoration(
                  color: _selectedPaymentMethod == 'cash'
                      ? AppColors.primaryMintLight
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedPaymentMethod == 'cash'
                        ? AppColors.primaryMint
                        : AppColors.borderLight,
                    width: _selectedPaymentMethod == 'cash' ? 1.5 : 1.0,
                  ),
                ),
                child: RadioListTile<String>(
                  value: 'cash',
                  groupValue: _selectedPaymentMethod,
                  activeColor: AppColors.primaryMint,
                  title: const Text(
                    'Cash on Delivery / Pay After Service',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  subtitle: const Text(
                    'Inspect the work first, then pay in cash to the service specialist upon completion.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPaymentMethod = val;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Option B: UPI / Online Gateway (COMING SOON)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.textMuted,
                  ),
                  title: Row(
                    children: [
                      const Text(
                        'Online UPI & Card Payment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Coming Soon',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'Direct Razorpay online gateway is in preparation. Please use Pay After Service for now.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Online payments (Razorpay/UPI) are currently in sandbox setup. Please select Cash on Delivery to book!',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 4. Price Breakdown
              _buildSectionTitle('Bill Details'),
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
                    _buildBillRow('Item Total (Sample Rate)',
                        widget.service.formattedPrice),
                    const SizedBox(height: 8),
                    _buildBillRow('Dhule Doorstep Convenience Fee', 'FREE',
                        isGreen: true),
                    const SizedBox(height: 8),
                    _buildBillRow('Taxes & Local Cleaning Cess', '₹0',
                        isGreen: true),
                    const Divider(height: 24, color: AppColors.divider),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        Text(
                          widget.service.formattedPrice,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryMintDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Local Offline Booking Persistence Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.storage_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This booking will be saved on your local device storage and is visible in My Bookings.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Confirm Booking Button
              CustomButton(
                text: 'Confirm & Place Booking',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isSubmitting,
                onPressed: _handleConfirmBooking,
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
        fontSize: 16,
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
          width: 100,
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

  Widget _buildBillRow(String label, String value, {bool isGreen = false}) {
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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isGreen ? AppColors.primaryMintDark : AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}
