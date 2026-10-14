import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../data/booking_storage.dart';
import '../models/service_item.dart';
import '../widgets/custom_button.dart';
import 'booking_summary_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final ServiceItem service;

  const BookingFormScreen({
    super.key,
    required this.service,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _instructionsController;

  late String _selectedDhuleArea;
  late DateTime _selectedDate;
  late String _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    final storage = BookingStorage();

    _nameController = TextEditingController(text: storage.customerName);
    _phoneController = TextEditingController(
      text: storage.customerPhone.replaceAll('+91 ', '').trim(),
    );
    _addressController = TextEditingController(text: storage.customerAddress);
    _instructionsController = TextEditingController();

    _selectedDhuleArea =
        storage.currentLocality.split(',').first.trim();
    if (!AppConstants.dhuleLocalities.contains(_selectedDhuleArea)) {
      _selectedDhuleArea = AppConstants.dhuleLocalities.first;
    }

    // Default booking date: tomorrow
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTimeSlot = AppConstants.bookingTimeSlots.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 45)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryMint,
              onPrimary: Colors.white,
              onSurface: AppColors.charcoal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _proceedToSummary() {
    if (_formKey.currentState?.validate() ?? false) {
      // Save customer details back to storage for future bookings
      BookingStorage().updateProfile(
        name: _nameController.text.trim(),
        phone: '+91 ${_phoneController.text.trim()}',
        address: _addressController.text.trim(),
      );
      BookingStorage().updateLocality('$_selectedDhuleArea, Dhule');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSummaryScreen(
            service: widget.service,
            customerName: _nameController.text.trim(),
            customerPhone: '+91 ${_phoneController.text.trim()}',
            dhuleArea: _selectedDhuleArea,
            fullAddress: _addressController.text.trim(),
            bookingDate: _selectedDate,
            timeSlot: _selectedTimeSlot,
            specialInstructions: _instructionsController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, dd MMMM yyyy').format(_selectedDate);

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
          'Book Service',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Mini Preview Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryMintLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          widget.service.icon,
                          color: AppColors.primaryMintDark,
                          size: 26,
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
                            const SizedBox(height: 2),
                            Text(
                              widget.service.categoryName,
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

                const SizedBox(height: 24),

                // SECTION 1: Date & Time Selection
                _buildSectionHeader('1. Choose Date & Time Slot'),
                const SizedBox(height: 12),

                // Date Picker Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: InkWell(
                    onTap: _pickDate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.primaryMint,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Service Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryMintLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              color: AppColors.primaryMintDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Time Slots Radio Chips
                const Text(
                  'Select preferred time window:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: AppConstants.bookingTimeSlots.map((slot) {
                    final isSelected = slot == _selectedTimeSlot;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryMintLight
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryMint
                              : AppColors.borderLight,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: slot,
                        groupValue: _selectedTimeSlot,
                        activeColor: AppColors.primaryMint,
                        title: Text(
                          slot,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primaryMintDark
                                : AppColors.charcoal,
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedTimeSlot = val;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // SECTION 2: Contact & Dhule Address
                _buildSectionHeader('2. Your Dhule Address & Contact'),
                const SizedBox(height: 12),

                // Customer Name
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your name',
                  icon: Icons.person_outline_rounded,
                  validator: (val) {
                    if (val == null || val.trim().length < 2) {
                      return 'Please enter a valid full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Phone Number
                _buildTextField(
                  controller: _phoneController,
                  label: 'Contact Number',
                  hint: '98221XXXXX',
                  icon: Icons.phone_android_rounded,
                  prefixText: '+91 ',
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.trim().length != 10) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(val.trim())) {
                      return 'Numbers only';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Dhule Locality Selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDhuleArea,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Dhule Locality / Zone',
                        labelStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        icon: Icon(
                          Icons.location_city_rounded,
                          color: AppColors.primaryMint,
                        ),
                      ),
                      items: AppConstants.dhuleLocalities.map((area) {
                        return DropdownMenuItem<String>(
                          value: area,
                          child: Text(
                            area,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedDhuleArea = val;
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Full Street Address
                _buildTextField(
                  controller: _addressController,
                  label: 'House / Flat No., Society / Landmark',
                  hint: 'e.g. Flat 302, Sai Residency, Near Agra Road',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                  validator: (val) {
                    if (val == null || val.trim().length < 5) {
                      return 'Please provide your full street address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Special Instructions (Optional)
                _buildTextField(
                  controller: _instructionsController,
                  label: 'Special Instructions (Optional)',
                  hint:
                      'e.g. Ring the bell twice, terrace key is with security...',
                  icon: Icons.notes_rounded,
                  maxLines: 2,
                ),

                const SizedBox(height: 32),

                // Review Summary Button
                CustomButton(
                  text: 'Review Booking Summary',
                  icon: Icons.receipt_long_rounded,
                  onPressed: _proceedToSummary,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.charcoal,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
        ),
        decoration: InputDecoration(
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryMint, size: 20),
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
