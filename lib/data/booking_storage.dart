import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';

/// Local persistence manager for Mopster customer bookings.
/// Uses SharedPreferences to persist bookings on the device without requiring Firebase or paid backends.
class BookingStorage extends ChangeNotifier {
  static final BookingStorage _instance = BookingStorage._internal();
  factory BookingStorage() => _instance;
  BookingStorage._internal();

  static const String _storageKey = 'mopster_user_bookings_v1';
  static const String _userLocationKey = 'mopster_selected_locality';
  static const String _userNameKey = 'mopster_user_name';
  static const String _userPhoneKey = 'mopster_user_phone';
  static const String _userAddressKey = 'mopster_user_address';

  List<BookingModel> _bookings = [];
  bool _isInitialized = false;

  String _currentLocality = 'Deopur, Dhule';
  String _customerName = 'Rohan Patil';
  String _customerPhone = '+91 98221 44556';
  String _customerAddress = 'Row House 14, Anand Nagar, Deopur, Dhule - 424002';

  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  List<BookingModel> get upcomingBookings =>
      _bookings.where((b) => b.isUpcoming).toList();
  List<BookingModel> get pastBookings =>
      _bookings.where((b) => !b.isUpcoming).toList();

  String get currentLocality => _currentLocality;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get customerAddress => _customerAddress;
  bool get isInitialized => _isInitialized;

  /// Initialize and load saved bookings from disk
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLocality =
          prefs.getString(_userLocationKey) ?? 'Deopur, Dhule';
      _customerName = prefs.getString(_userNameKey) ?? 'Rohan Patil';
      _customerPhone = prefs.getString(_userPhoneKey) ?? '+91 98221 44556';
      _customerAddress = prefs.getString(_userAddressKey) ??
          'Row House 14, Anand Nagar, Deopur, Dhule - 424002';

      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _bookings = decoded
            .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // Seed initial friendly sample booking so the user can immediately experience the "My Bookings" screen
        _seedInitialSample();
        await _persistToDisk(prefs);
      }
    } catch (e) {
      debugPrint('Error loading saved bookings: $e');
      if (_bookings.isEmpty) {
        _seedInitialSample();
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  void _seedInitialSample() {
    _bookings = [
      BookingModel(
        id: 'MOP-DHU-8102',
        serviceId: 'clean_bathroom',
        serviceTitle: 'Bathroom Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 499.0,
        customerName: _customerName,
        customerPhone: _customerPhone,
        dhuleArea: 'Deopur',
        fullAddress: 'Row House 14, Anand Nagar, Deopur, Dhule',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '10:30 AM - 12:30 PM (Mid-day)',
        specialInstructions: 'Please focus on shower hard-water stains.',
        paymentMethod: 'Cash on Delivery (Pay after service)',
        paymentStatus: 'Pending (Pay upon completion)',
        bookingStatus: 'Confirmed',
        assignedStaff: 'Sachin Shinde (Dhule Cleaning Associate)',
      ),
      BookingModel(
        id: 'MOP-DHU-7954',
        serviceId: 'garden_care',
        serviceTitle: 'Plant Care & Nourishment',
        serviceCategory: 'Gardening Care',
        totalAmount: 449.0,
        customerName: _customerName,
        customerPhone: _customerPhone,
        dhuleArea: 'Deopur',
        fullAddress: 'Row House 14, Anand Nagar, Deopur, Dhule',
        bookingDate: DateTime.now().subtract(const Duration(days: 5)),
        timeSlot: '08:00 AM - 10:00 AM (Morning)',
        specialInstructions: 'Terrace flower pots nourished with vermicompost.',
        paymentMethod: 'Cash on Delivery',
        paymentStatus: 'Paid (₹449)',
        bookingStatus: 'Completed',
        assignedStaff: 'Kailash Mali (Dhule Garden Specialist)',
      ),
    ];
  }

  /// Create a new booking and persist to local device storage
  Future<bool> addBooking(BookingModel newBooking) async {
    try {
      _bookings.insert(0, newBooking); // Insert at the beginning (latest first)
      final prefs = await SharedPreferences.getInstance();
      await _persistToDisk(prefs);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving booking: $e');
      return false;
    }
  }

  /// Cancel an existing booking
  Future<bool> cancelBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final updated = _bookings[index].copyWith(
        bookingStatus: 'Cancelled',
      );
      _bookings[index] = updated;
      final prefs = await SharedPreferences.getInstance();
      await _persistToDisk(prefs);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Update customer locality
  Future<void> updateLocality(String locality) async {
    _currentLocality = locality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userLocationKey, locality);
    notifyListeners();
  }

  /// Update customer profile information
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    _customerName = name;
    _customerPhone = phone;
    _customerAddress = address;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userPhoneKey, phone);
    await prefs.setString(_userAddressKey, address);
    notifyListeners();
  }

  Future<void> _persistToDisk(SharedPreferences prefs) async {
    final List<Map<String, dynamic>> rawList =
        _bookings.map((b) => b.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(rawList));
  }
}
