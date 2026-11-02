import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../data/booking_storage.dart';
import '../data/sample_services.dart';
import '../models/booking_model.dart';
import '../models/service_item.dart';
import '../services/auth_service.dart';
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
  String _selectedPaymentMethod = 'cash'; // 'cash' or 'direct_upi'
  bool _isSubmitting = false;

  String _generateBookingId() {
    final randomDigits = 100000 + Random().nextInt(900000);
    return 'MOP-DHU-$randomDigits';
  }

  Future<void> _handleConfirmBooking() async {
    if (_isSubmitting) return; // Prevent duplicate submissions

    // Validate required fields
    if (widget.customerName.trim().isEmpty ||
        widget.customerPhone.trim().isEmpty ||
        widget.fullAddress.trim().isEmpty ||
        widget.service.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.statusCancelled,
          content: const Text(
            'Please fill in all required customer details (name, phone, address).',
          ),
        ),
      );
      return;
    }

    // Verify service authenticity and price against official service catalogue
    final verifiedService = SampleServices.allServices.firstWhere(
      (s) => s.id == widget.service.id,
      orElse: () => widget.service,
    );

    if (verifiedService.basePrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.statusCancelled,
          content: const Text(
            'Invalid service rate. Please select a valid service.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final currentUid = AuthService().currentUserId;
    final newBooking = BookingModel(
      id: _generateBookingId(),
      customerId: currentUid.isNotEmpty ? currentUid : null,
      serviceId: verifiedService.id,
      serviceTitle: verifiedService.title,
      serviceCategory: verifiedService.categoryName,
      totalAmount: verifiedService.basePrice,
      customerName: widget.customerName.trim(),
      customerPhone: widget.customerPhone.trim(),
      dhuleArea: widget.dhuleArea.trim(),
      fullAddress: widget.fullAddress.trim(),
      bookingDate: widget.bookingDate,
      timeSlot: widget.timeSlot,
      specialInstructions: widget.specialInstructions.trim(),
      paymentMethod: _selectedPaymentMethod == 'cash'
          ? 'Cash on Delivery (Pay after service)'
          : 'Direct UPI to Business (Pay after service)',
      paymentStatus: 'Pending (Pay upon completion)',
      bookingStatus: 'Pending Approval',
      assignedStaff: 'Awaiting Owner Approval',
      createdAt: DateTime.now(),
    );

    // Save to local device storage and sync with Supabase Cloud
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
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.statusCancelled,
          content: const Text(
            'Failed to save booking. Please check your network and try again.',
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
        title: const Text(
          'Booking Summary',
          style: TextStyle(
            color: AppColors.deepCharcoal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
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
              // 1. Service Review Card
              _buildSectionTitle('Selected Service'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 58,
                        height: 58,
                        child: Image.asset(
                          widget.service.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.freshMint, Color(0xFFEAF9ED)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.forestGreen.withOpacity(0.12),
                              ),
                            ),
                            child: Icon(
                              widget.service.icon,
                              color: AppColors.forestGreen,
                              size: 28,
                            ),
                          ),
                        ),
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
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepCharcoal,
                              letterSpacing: -0.2,
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
                                  color: AppColors.freshMint,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.service.duration,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forestGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.electricLime.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.electricLime),
                      ),
                      child: Text(
                        widget.service.formattedPrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Schedule & Location Details
              _buildSectionTitle('Appointment & Dhule Address'),
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
                      icon: Icons.access_time_filled_rounded,
                      label: 'Preferred Slot',
                      value: widget.timeSlot,
                    ),
                    const Divider(height: 24, color: AppColors.softBorder),
                    _buildDetailRow(
                      icon: Icons.person_rounded,
                      label: 'Customer',
                      value: '${widget.customerName} • ${widget.customerPhone}',
                    ),
                    const Divider(height: 24, color: AppColors.softBorder),
                    _buildDetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Service Address',
                      value:
                          '${widget.fullAddress}\nLocality: ${widget.dhuleArea}, Dhule',
                    ),
                    if (widget.specialInstructions.isNotEmpty) ...[
                      const Divider(height: 24, color: AppColors.softBorder),
                      _buildDetailRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Notes',
                        value: widget.specialInstructions,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Payment Mode
              _buildSectionTitle('Payment Method'),
              const SizedBox(height: 4),
              const Text(
                'Choose how you would like to settle the service charges:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Option A: Cash on Delivery
              _buildPaymentOption(
                value: 'cash',
                title: 'Cash on Delivery (Pay After Service)',
                subtitle:
                    'Inspect the work first, then pay directly to your Dhule specialist upon completion.',
                icon: Icons.payments_rounded,
              ),

              const SizedBox(height: 10),

              // Option B: Direct UPI Payment
              _buildPaymentOption(
                value: 'direct_upi',
                title: 'Direct UPI (GPay / PhonePe / Paytm)',
                subtitle:
                    'Scan Mopster QR code or pay via verified UPI upon service completion.',
                icon: Icons.qr_code_2_rounded,
              ),

              const SizedBox(height: 24),

              // 4. Price Breakdown
              _buildSectionTitle('Bill Details'),
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
                    _buildBillRow('Item Total (Standard Rate)',
                        widget.service.formattedPrice),
                    const SizedBox(height: 10),
                    _buildBillRow('Dhule Doorstep Convenience Fee', 'FREE',
                        isGreen: true),
                    const SizedBox(height: 10),
                    _buildBillRow('Local Taxes & Service Cess', '₹0',
                        isGreen: true),
                    const Divider(height: 26, color: AppColors.softBorder),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepCharcoal,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          widget.service.formattedPrice,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Approval Required Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.hourglass_top_rounded,
                      color: Color(0xFFB45309),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Approval Required: This booking request will be saved as "Pending Approval". The business owner will review your requested time and address before confirming.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Submit Request Button
              CustomButton(
                text: 'Submit Booking Request',
                icon: Icons.arrow_forward_rounded,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleConfirmBooking,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.forestGreen : AppColors.softBorder,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.forestGreen.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.freshMint : const Color(0xFFF3F5F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.forestGreen : AppColors.mutedGrey,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppColors.forestGreen : AppColors.deepCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedGrey,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.forestGreen : AppColors.mutedGrey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.forestGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
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
          width: 95,
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

  Widget _buildBillRow(String label, String value, {bool isGreen = false}) {
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
            fontWeight: FontWeight.w800,
            color: isGreen ? AppColors.forestGreen : AppColors.deepCharcoal,
          ),
        ),
      ],
    );
  }
}
