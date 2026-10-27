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
  String _selectedPaymentMethod = 'cash'; // 'cash' or 'online_gateway'
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
        const SnackBar(
          backgroundColor: AppColors.statusCancelled,
          content: Text(
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
        const SnackBar(
          backgroundColor: AppColors.statusCancelled,
          content: Text(
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
        const SnackBar(
          backgroundColor: AppColors.statusCancelled,
          content: Text(
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
                      label: 'Preferred Date',
                      value: dateFormatted,
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Preferred Slot',
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

              // Option B: Direct UPI Payment (ACTIVE)
              Container(
                decoration: BoxDecoration(
                  color: _selectedPaymentMethod == 'direct_upi'
                      ? AppColors.primaryMintLight
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedPaymentMethod == 'direct_upi'
                        ? AppColors.primaryMint
                        : AppColors.borderLight,
                    width: _selectedPaymentMethod == 'direct_upi' ? 1.5 : 1.0,
                  ),
                ),
                child: RadioListTile<String>(
                  value: 'direct_upi',
                  groupValue: _selectedPaymentMethod,
                  activeColor: AppColors.primaryMint,
                  title: const Text(
                    'Direct UPI to Business (GPay / PhonePe / Paytm)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  subtitle: const Text(
                    'Scan Mopster QR code or pay via UPI ID upon service completion. Verified and recorded by business.',
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

              // Approval Required Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
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
                          fontWeight: FontWeight.w500,
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
                icon: Icons.send_rounded,
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
