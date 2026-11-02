import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../data/booking_storage.dart';
import '../models/service_item.dart';
import '../services/auth_service.dart';
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
    final profile = AuthService().currentProfile;

    final initialName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : storage.customerName;
    final initialPhone = profile?.phone.isNotEmpty == true
        ? profile!.phone.replaceAll('+91 ', '').replaceAll('+91', '').trim()
        : storage.customerPhone
            .replaceAll('+91 ', '')
            .replaceAll('+91', '')
            .trim();
    final initialAddress = profile?.homeAddress.isNotEmpty == true
        ? profile!.homeAddress
        : storage.customerAddress;

    _nameController = TextEditingController(text: initialName);
    _phoneController = TextEditingController(text: initialPhone);
    _addressController = TextEditingController(text: initialAddress);
    _instructionsController = TextEditingController();

    _selectedDhuleArea = profile?.dhuleArea.isNotEmpty == true
        ? profile!.dhuleArea
        : storage.currentLocality.split(',').first.trim();
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
              primary: AppColors.forestGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.deepCharcoal,
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
      final name = _nameController.text.trim();
      final phone = '+91 ${_phoneController.text.trim()}';
      final address = _addressController.text.trim();

      // Save customer details back to storage for future bookings
      BookingStorage().updateProfile(
        name: name,
        phone: phone,
        address: address,
      );
      BookingStorage().updateLocality('$_selectedDhuleArea, Dhule');

      // Also sync to customer auth profile if logged in
      if (AuthService().isLoggedIn) {
        AuthService().updateProfile(
          fullName: name,
          dhuleArea: _selectedDhuleArea,
          homeAddress: address,
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSummaryScreen(
            service: widget.service,
            customerName: name,
            customerPhone: phone,
            dhuleArea: _selectedDhuleArea,
            fullAddress: address,
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
              color: AppColors.deepCharcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Service',
          style: TextStyle(
            color: AppColors.deepCharcoal,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Mini Preview Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.softBorder, width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepCharcoal.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          widget.service.icon,
                          color: AppColors.electricLime,
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
                                fontWeight: FontWeight.w800,
                                color: AppColors.deepCharcoal,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.service.categoryName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.service.formattedPrice,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepCharcoal,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // SECTION 1: Preferred Date & Time Selection
                _buildSectionHeader(
                  number: '1',
                  title: 'Select Preferred Date & Time Slot',
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your slot will be reviewed by the business owner for rapid approval.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Date Picker Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.softBorder, width: 1.2),
                  ),
                  child: InkWell(
                    onTap: _pickDate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.forestGreenLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.forestGreen,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SERVICE DATE',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepCharcoal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Time Slots Grid/Cards
                const Text(
                  'Available Time Windows',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.deepCharcoal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: AppConstants.bookingTimeSlots.map((slot) {
                    final isSelected = slot == _selectedTimeSlot;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeSlot = slot;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.forestGreen
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.forestGreen
                                : AppColors.softBorder,
                            width: isSelected ? 1.6 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.forestGreen.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 20,
                              color: isSelected
                                  ? AppColors.electricLime
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              slot,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.deepCharcoal,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.electricLime,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'SELECTED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.deepCharcoal,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 26),

                // SECTION 2: Contact & Dhule Address
                _buildSectionHeader(
                  number: '2',
                  title: 'Your Dhule Service Address',
                ),
                const SizedBox(height: 14),

                // Customer Name
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline_rounded,
                  validator: (val) {
                    if (val == null || val.trim().length < 2) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Phone Number
                _buildTextField(
                  controller: _phoneController,
                  label: 'Contact Number',
                  hint: 'Enter 10-digit mobile number',
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.softBorder, width: 1.2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDhuleArea,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Dhule Locality / Sector',
                        labelStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        icon: Icon(
                          Icons.location_city_rounded,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      items: AppConstants.dhuleLocalities.map((area) {
                        return DropdownMenuItem<String>(
                          value: area,
                          child: Text(
                            area,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepCharcoal,
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
                  label: 'Full Street Address in Dhule',
                  hint: 'House/Flat no., Society name, Landmark',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                  validator: (val) {
                    if (val == null || val.trim().length < 5) {
                      return 'Please enter your complete street address';
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
                      'e.g. Ring doorbell twice, terrace keys with security...',
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

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String number,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.forestGreen,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: AppColors.deepCharcoal,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder, width: 1.2),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.deepCharcoal,
        ),
        decoration: InputDecoration(
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            color: AppColors.deepCharcoal,
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
          ),
          prefixIcon: Icon(icon, color: AppColors.forestGreen, size: 20),
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
