import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

/// Central Booking Repository for Mopster.
/// Coordinates between Supabase Cloud Database and device SharedPreferences for offline capability.
/// Strictly enforces genuine customer data: no fake seed bookings, no default customer information.
class BookingStorage extends ChangeNotifier {
  static final BookingStorage _instance = BookingStorage._internal();
  factory BookingStorage() => _instance;
  BookingStorage._internal();

  static const String _storageKey = 'mopster_user_bookings_v2';
  static const String _legacyStorageKey = 'mopster_user_bookings_v1';
  static const String _myBookingIdsKey = 'mopster_my_booking_ids_v1';
  static const String _userLocationKey = 'mopster_selected_locality';
  static const String _userNameKey = 'mopster_user_name';
  static const String _userPhoneKey = 'mopster_user_phone';
  static const String _userAddressKey = 'mopster_user_address';

  List<BookingModel> _bookings = [];
  List<String> _myBookingIds = [];
  bool _isInitialized = false;
  bool _isSyncing = false;

  // New customers start completely blank. No hardcoded or dummy names/phones/addresses!
  String _currentLocality = 'Deopur, Dhule';
  String _customerName = '';
  String _customerPhone = '';
  String _customerAddress = '';

  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  List<BookingModel> get upcomingBookings =>
      _bookings.where((b) => b.isUpcoming).toList();
  List<BookingModel> get inProgressBookings =>
      _bookings.where((b) => b.isInProgress).toList();
  List<BookingModel> get pastBookings =>
      _bookings.where((b) => !b.isUpcoming && !b.isInProgress).toList();

  bool get hasAnyBookings => _bookings.isNotEmpty;

  String get currentLocality => _currentLocality;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get customerAddress => _customerAddress;
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;

  /// Detect and eliminate any dummy or test bookings
  static bool isDummyBooking(BookingModel b) {
    final id = b.id.toUpperCase();
    final name = b.customerName.toLowerCase().trim();
    final phone = b.customerPhone.replaceAll(' ', '').trim();
    return id == 'MOP-DHU-8102' ||
        id == 'MOP-DHU-7954' ||
        id == 'MOP-DHU-5506' ||
        name == 'rohan patil' ||
        name == 'rohit patel' ||
        name == 'rohan patel' ||
        phone.contains('9822144556') ||
        phone.contains('98221 44556');
  }

  /// Initialize and load saved bookings from disk and synchronize with Supabase
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      _currentLocality =
          prefs.getString(_userLocationKey) ?? 'Deopur, Dhule';
      _customerName = prefs.getString(_userNameKey) ?? '';
      _customerPhone = prefs.getString(_userPhoneKey) ?? '';
      _customerAddress = prefs.getString(_userAddressKey) ?? '';

      // Purge any legacy dummy/sample customer profile data
      final lowerName = _customerName.toLowerCase().trim();
      final cleanPhone = _customerPhone.replaceAll(' ', '').trim();
      if (lowerName == 'rohan patil' ||
          lowerName == 'rohit patel' ||
          lowerName == 'rohan patel') {
        _customerName = '';
        await prefs.remove(_userNameKey);
      }
      if (cleanPhone.contains('9822144556')) {
        _customerPhone = '';
        await prefs.remove(_userPhoneKey);
      }
      if (_customerAddress.contains('Row House 14, Anand Nagar')) {
        _customerAddress = '';
        await prefs.remove(_userAddressKey);
      }

      // Load IDs of bookings created by this customer on this device
      _myBookingIds = prefs.getStringList(_myBookingIdsKey) ?? [];

      // Load bookings from local storage
      final String? jsonString =
          prefs.getString(_storageKey) ?? prefs.getString(_legacyStorageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _bookings = decoded
            .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
            .where((b) => !isDummyBooking(b))
            .toList();

        // Remove legacy seed storage if found
        if (prefs.containsKey(_legacyStorageKey)) {
          await prefs.remove(_legacyStorageKey);
          await _persistToDisk(prefs);
        }
      } else {
        // New customer starts with ZERO bookings (no fake seeds!)
        _bookings = [];
      }
    } catch (e) {
      debugPrint('Error loading local bookings: $e');
      _bookings = [];
    }

    _isInitialized = true;
    notifyListeners();

    // Trigger cloud synchronization in the background
    refreshFromCloud();
  }

  /// Fetch genuine customer bookings from Supabase and merge with local store.
  /// Customers only see their own bookings (matching device IDs or phone number).
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
            .where((b) => !isDummyBooking(b))
            .toList();

        // Filter: only show bookings belonging to the current customer
        final customerPhoneClean =
            _customerPhone.replaceAll(' ', '').replaceAll('+91', '').trim();

        final myRemoteBookings = remoteBookings.where((b) {
          final isMineById = _myBookingIds.contains(b.id);
          final bookingPhoneClean =
              b.customerPhone.replaceAll(' ', '').replaceAll('+91', '').trim();
          final isMineByPhone = customerPhoneClean.isNotEmpty &&
              bookingPhoneClean.isNotEmpty &&
              bookingPhoneClean == customerPhoneClean;
          return isMineById || isMineByPhone;
        }).toList();

        // Merge local and remote
        final Map<String, BookingModel> mergedMap = {};
        for (final b in _bookings) {
          if (!isDummyBooking(b)) {
            mergedMap[b.id] = b;
          }
        }
        for (final b in myRemoteBookings) {
          mergedMap[b.id] = b; // Remote supersedes local
          if (!_myBookingIds.contains(b.id)) {
            _myBookingIds.add(b.id);
          }
        }

        _bookings = mergedMap.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_myBookingIdsKey, _myBookingIds);
        await _persistToDisk(prefs);
      }
    } catch (e) {
      debugPrint('Note: Supabase sync skipped or offline: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Create a new booking with Pending Approval status
  Future<bool> addBooking(BookingModel newBooking) async {
    try {
      // 1. Add locally first for instant user feedback
      _bookings.insert(0, newBooking);
      if (!_myBookingIds.contains(newBooking.id)) {
        _myBookingIds.add(newBooking.id);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_myBookingIdsKey, _myBookingIds);
      await _persistToDisk(prefs);
      notifyListeners();

      // 2. Persist to Supabase Cloud Database with 'Pending Approval' status
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

  /// Update an existing booking's status in Supabase and locally
  Future<bool> updateBookingStatus(String bookingId, String newStatus) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final updated = _bookings[index].copyWith(
        bookingStatus: newStatus,
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
            .update({'booking_status': newStatus}).eq('id', bookingId);
      } catch (cloudErr) {
        debugPrint('Supabase status update warning (saved locally): $cloudErr');
      }

      return true;
    }
    return false;
  }

  /// Cancel an existing booking in Supabase and locally
  Future<bool> cancelBooking(String bookingId) async {
    return updateBookingStatus(bookingId, 'Cancelled');
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

    // Re-sync bookings for this phone number if provided
    if (_customerPhone.isNotEmpty) {
      refreshFromCloud();
    }
  }

  Future<void> _persistToDisk(SharedPreferences prefs) async {
    final List<Map<String, dynamic>> rawList =
        _bookings.map((b) => b.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(rawList));
  }
}
