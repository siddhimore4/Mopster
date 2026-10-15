import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

/// Central Booking Repository for Mopster.
/// Coordinates between Supabase Cloud Database and device SharedPreferences for offline capability.
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
  bool _isSyncing = false;

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
  bool get isSyncing => _isSyncing;

  /// Initialize and load saved bookings from disk and synchronize with Supabase
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
        _seedInitialSample();
        await _persistToDisk(prefs);
      }
    } catch (e) {
      debugPrint('Error loading local bookings: $e');
      if (_bookings.isEmpty) {
        _seedInitialSample();
      }
    }

    _isInitialized = true;
    notifyListeners();

    // Trigger cloud synchronization in the background
    refreshFromCloud();
  }

  /// Fetch latest customer bookings from Supabase and merge with local store
  Future<void> refreshFromCloud() async {
    try {
      _isSyncing = true;
      notifyListeners();

      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('bookings')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> records = response as List<dynamic>;
      if (records.isNotEmpty) {
        final List<BookingModel> remoteBookings = records
            .map((row) =>
                BookingModel.fromSupabaseMap(row as Map<String, dynamic>))
            .toList();

        // Merge: take remote bookings and update matching or add new
        final Map<String, BookingModel> mergedMap = {};
        for (final b in _bookings) {
          mergedMap[b.id] = b;
        }
        for (final b in remoteBookings) {
          mergedMap[b.id] = b; // Remote supersedes local
        }

        _bookings = mergedMap.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final prefs = await SharedPreferences.getInstance();
        await _persistToDisk(prefs);
      }
    } catch (e) {
      debugPrint('Note: Supabase sync skipped or offline: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
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

  /// Create a new booking: saves to Supabase and saves locally
  Future<bool> addBooking(BookingModel newBooking) async {
    try {
      // 1. Add locally first for instant user feedback
      _bookings.insert(0, newBooking);
      final prefs = await SharedPreferences.getInstance();
      await _persistToDisk(prefs);
      notifyListeners();

      // 2. Persist to Supabase Cloud Database
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('bookings').insert(newBooking.toSupabaseMap());
      } catch (cloudErr) {
        debugPrint('Supabase insert warning (saved locally): $cloudErr');
      }

      return true;
    } catch (e) {
      debugPrint('Error saving booking: $e');
      return false;
    }
  }

  /// Cancel an existing booking in Supabase and locally
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

      // Update in Supabase
      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('bookings')
            .update({'booking_status': 'Cancelled'}).eq('id', bookingId);
      } catch (cloudErr) {
        debugPrint('Supabase cancel warning (saved locally): $cloudErr');
      }

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
