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
  static const String _userCustomerIdKey = 'mopster_user_customer_id';

  List<BookingModel> _bookings = [];
  List<String> _myBookingIds = [];
  bool _isInitialized = false;
  bool _isSyncing = false;

  // New customers start completely blank. No hardcoded or dummy names/phones/addresses!
  String _currentLocality = 'Deopur, Dhule';
  String _customerName = '';
  String _customerPhone = '';
  String _customerAddress = '';
  String _customerId = '';

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
  String get customerId => _customerId;
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;

  bool _lastCloudSyncSuccess = true;
  String? _lastCloudError;
  RealtimeChannel? _realtimeChannel;

  bool get lastCloudSyncSuccess => _lastCloudSyncSuccess;
  String? get lastCloudError => _lastCloudError;

  /// Detect and eliminate any dummy, sample, or test bookings
  static bool isDummyBooking(BookingModel b) {
    final id = b.id.toUpperCase().trim();
    final name = b.customerName.toLowerCase().trim();
    final phone = b.customerPhone
        .replaceAll(' ', '')
        .replaceAll('+91', '')
        .replaceAll('-', '')
        .trim();
    final address = b.fullAddress.toLowerCase();

    // 1. Check ID patterns
    if (id == 'MOP-DHU-8102' ||
        id == 'MOP-DHU-7954' ||
        id == 'MOP-DHU-5506' ||
        id.startsWith('MOP-TEST') ||
        id.startsWith('MOP-INSPECT') ||
        id.contains('TEST') ||
        id.contains('DUMMY') ||
        id.contains('SAMPLE')) {
      return true;
    }

    // 2. Check customer name patterns
    if (name == 'rohan patil' ||
        name == 'rohit patel' ||
        name == 'rohan patel' ||
        name == 'inspect' ||
        name == 'test sync' ||
        name == 'test customer' ||
        name == 'test user' ||
        name == 'dummy user' ||
        name == 'sample customer' ||
        name == 'sample user' ||
        name == 'test') {
      return true;
    }

    // 3. Check dummy test phone numbers
    if (phone.contains('9822144556') ||
        phone.contains('9822100000') ||
        phone.contains('9876543210') ||
        phone.contains('0000000000') ||
        phone == '1234567890') {
      return true;
    }

    // 4. Check dummy addresses
    if (address.contains('row house 14') || address.contains('test street')) {
      return true;
    }

    return false;
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
      _customerId = prefs.getString(_userCustomerIdKey) ?? '';

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

    // Trigger cloud synchronization and realtime updates
    refreshFromCloud();
    _setupRealtimeSubscription();
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
        final currentCustId = _customerId.trim();

        final myRemoteBookings = remoteBookings.where((b) {
          final isMineById = _myBookingIds.contains(b.id);
          final bookingPhoneClean =
              b.customerPhone.replaceAll(' ', '').replaceAll('+91', '').trim();
          final isMineByPhone = customerPhoneClean.isNotEmpty &&
              bookingPhoneClean.isNotEmpty &&
              bookingPhoneClean == customerPhoneClean;
          final isMineByCustId = currentCustId.isNotEmpty &&
              b.customerId != null &&
              b.customerId == currentCustId;
          return isMineById || isMineByPhone || isMineByCustId;
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

  /// Set up Supabase Realtime subscription so customer app receives live updates
  void _setupRealtimeSubscription() {
    if (_realtimeChannel != null) return;
    try {
      final supabase = Supabase.instance.client;
      _realtimeChannel = supabase.channel('customer_bookings_live_sync')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            debugPrint('Realtime customer booking change: ${payload.eventType}');
            refreshFromCloud();
          },
        )
        ..subscribe();
    } catch (e) {
      debugPrint('Note: Realtime subscription in BookingStorage: $e');
    }
  }

  /// Create a new booking with Pending Approval status and synchronize with Supabase Cloud
  Future<bool> addBooking(BookingModel newBooking) async {
    try {
      // 1. Add locally first for instant user feedback and offline capability
      _bookings.insert(0, newBooking);
      if (!_myBookingIds.contains(newBooking.id)) {
        _myBookingIds.add(newBooking.id);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_myBookingIdsKey, _myBookingIds);
      await _persistToDisk(prefs);
      notifyListeners();

      // 2. Persist to Supabase Cloud Database using standard schema columns
      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('bookings')
            .insert(newBooking.toSupabaseMap(includeCustomerId: false));
        _lastCloudSyncSuccess = true;
        _lastCloudError = null;
        debugPrint(
            'Booking ${newBooking.id} successfully saved to Supabase Cloud with "Pending Approval" status.');
      } catch (cloudErr) {
        debugPrint('Supabase cloud insert warning (saved locally): $cloudErr');
        _lastCloudSyncSuccess = false;
        _lastCloudError = cloudErr.toString();
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

  /// Update an existing booking's payment status in Supabase and locally
  Future<bool> updatePaymentStatus(
      String bookingId, String newPaymentStatus) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final updated = _bookings[index].copyWith(
        paymentStatus: newPaymentStatus,
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
            .update({'payment_status': newPaymentStatus}).eq('id', bookingId);
      } catch (cloudErr) {
        debugPrint(
            'Supabase payment status update warning (saved locally): $cloudErr');
      }

      return true;
    }
    return false;
  }

  /// Cancel an existing booking in Supabase and locally if eligible
  Future<bool> cancelBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final b = _bookings[index];
      // Business Rule: Customers cannot cancel bookings that are already in progress or completed
      if (!b.canCancel) {
        debugPrint(
            'Cancellation rejected for ${b.id}: status is "${b.bookingStatus}".');
        return false;
      }
      return updateBookingStatus(bookingId, 'Cancelled');
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
    String? customerId,
  }) async {
    _customerName = name;
    _customerPhone = phone;
    _customerAddress = address;
    if (customerId != null) {
      _customerId = customerId;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userPhoneKey, phone);
    await prefs.setString(_userAddressKey, address);
    if (customerId != null) {
      await prefs.setString(_userCustomerIdKey, customerId);
    }
    notifyListeners();

    // Re-sync bookings for this phone number or customer ID if provided
    if (_customerPhone.isNotEmpty || _customerId.isNotEmpty) {
      refreshFromCloud();
    }
  }

  /// Completely wipe local customer state and cached bookings on logout
  Future<void> clearCustomerProfile() async {
    _customerName = '';
    _customerPhone = '';
    _customerAddress = '';
    _customerId = '';
    _bookings = [];
    _myBookingIds = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userAddressKey);
    await prefs.remove(_userCustomerIdKey);
    await prefs.remove(_myBookingIdsKey);
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  Future<void> _persistToDisk(SharedPreferences prefs) async {
    final List<Map<String, dynamic>> rawList =
        _bookings.map((b) => b.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(rawList));
  }
}
