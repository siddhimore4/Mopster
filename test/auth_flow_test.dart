import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mopster/models/customer_profile_model.dart';
import 'package:mopster/models/booking_model.dart';
import 'package:mopster/services/auth_service.dart';
import 'package:mopster/data/booking_storage.dart';
import 'package:mopster/screens/admin/admin_dashboard_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CustomerProfileModel Tests', () {
    test('Constructs profile with required and optional fields correctly', () {
      final profile = CustomerProfileModel(
        id: 'cust_dhule_001',
        phone: '+919823012345',
        fullName: 'Ramesh Patil',
        email: 'ramesh.dhule@example.com',
        dhuleArea: 'Deopur',
        homeAddress: 'Plot 45, Near ITI Ground, Deopur',
        role: 'customer',
      );

      expect(profile.id, equals('cust_dhule_001'));
      expect(profile.phone, equals('+919823012345'));
      expect(profile.fullName, equals('Ramesh Patil'));
      expect(profile.email, equals('ramesh.dhule@example.com'));
      expect(profile.dhuleArea, equals('Deopur'));
      expect(profile.homeAddress, equals('Plot 45, Near ITI Ground, Deopur'));
      expect(profile.role, equals('customer'));
      expect(profile.isCustomer, isTrue);
      expect(profile.isAdmin, isFalse);
      expect(profile.initials, equals('RP'));
    });

    test('Computes initials accurately for single names and blank names', () {
      final singleNameProfile = CustomerProfileModel(
        id: 'cust_002',
        phone: '+919823012346',
        fullName: 'Kailash',
      );
      expect(singleNameProfile.initials, equals('K'));

      final blankNameProfile = CustomerProfileModel(
        id: 'cust_003',
        phone: '+919823012347',
        fullName: '',
      );
      expect(blankNameProfile.initials, equals('M'));
    });

    test('Serializes to and from JSON and Supabase Map', () {
      final profile = CustomerProfileModel(
        id: 'cust_dhule_004',
        phone: '+919823012348',
        fullName: 'Sunita Mali',
        email: 'sunita@mopster.in',
        dhuleArea: 'Walwadi',
        homeAddress: 'Lane 2, Near Hanuman Mandir',
        role: 'customer',
        createdAt: DateTime(2026, 10, 20, 10, 30),
      );

      final json = profile.toJson();
      expect(json['id'], equals('cust_dhule_004'));
      expect(json['phone'], equals('+919823012348'));
      expect(json['full_name'], equals('Sunita Mali'));

      final deserializedFromJson = CustomerProfileModel.fromJson(json);
      expect(deserializedFromJson.id, equals(profile.id));
      expect(deserializedFromJson.fullName, equals(profile.fullName));
      expect(deserializedFromJson.dhuleArea, equals(profile.dhuleArea));

      final supabaseMap = profile.toSupabaseMap();
      expect(supabaseMap['id'], equals('cust_dhule_004'));
      expect(supabaseMap['role'], equals('customer'));

      final deserializedFromSupabase =
          CustomerProfileModel.fromSupabaseMap(supabaseMap);
      expect(deserializedFromSupabase.id, equals(profile.id));
      expect(deserializedFromSupabase.phone, equals(profile.phone));
    });

    test('copyWith produces updated immutable instance without side-effects', () {
      final original = CustomerProfileModel(
        id: 'cust_dhule_005',
        phone: '+919823012349',
        fullName: 'Ganesh Shinde',
        dhuleArea: 'Deopur',
      );

      final updated = original.copyWith(
        fullName: 'Ganesh S. Shinde',
        homeAddress: 'Survey 12, Wadi Bhokar Road',
      );

      expect(updated.id, equals(original.id));
      expect(updated.phone, equals(original.phone));
      expect(updated.fullName, equals('Ganesh S. Shinde'));
      expect(updated.homeAddress, equals('Survey 12, Wadi Bhokar Road'));
      expect(original.fullName, equals('Ganesh Shinde'));
      expect(original.homeAddress, isEmpty);
    });
  });

  group('AuthService Indian Phone Validation & Formatting Tests', () {
    test('Validates 10-digit Indian phone numbers', () {
      expect(AuthService.isValidIndianPhone('9823012345'), isTrue);
      expect(AuthService.isValidIndianPhone('8123456789'), isTrue);
      expect(AuthService.isValidIndianPhone('7028123456'), isTrue);
      expect(AuthService.isValidIndianPhone('6281234567'), isTrue);

      // With +91 prefix
      expect(AuthService.isValidIndianPhone('+919823012345'), isTrue);
      expect(AuthService.isValidIndianPhone('+91 98230 12345'), isTrue);
      expect(AuthService.isValidIndianPhone('919823012345'), isTrue);

      // With leading 0
      expect(AuthService.isValidIndianPhone('09823012345'), isTrue);

      // Invalid cases
      expect(AuthService.isValidIndianPhone('1234567890'), isFalse); // starts with 1
      expect(AuthService.isValidIndianPhone('5523012345'), isFalse); // starts with 5
      expect(AuthService.isValidIndianPhone('9823012'), isFalse); // too short
      expect(AuthService.isValidIndianPhone('982301234567'), isFalse); // too long
      expect(AuthService.isValidIndianPhone('abcdefghij'), isFalse); // letters
    });

    test('Formats Indian numbers to standard E.164 (+91XXXXXXXXXX)', () {
      expect(
        AuthService.formatIndianPhone('9823012345'),
        equals('+919823012345'),
      );
      expect(
        AuthService.formatIndianPhone('+91 98230 12345'),
        equals('+919823012345'),
      );
      expect(
        AuthService.formatIndianPhone('09823012345'),
        equals('+919823012345'),
      );
      expect(
        AuthService.formatIndianPhone('919823012345'),
        equals('+919823012345'),
      );
    });
  });

  group('AuthService OTP, Session & Profile Lifecycle Tests', () {
    test('Development OTP flow: sendOtp and verifyOtp creates active session', () async {
      final auth = AuthService();
      final sendResult = await auth.sendOtp('9823012345');

      expect(sendResult['success'], isTrue);
      expect(auth.activeVerificationPhone, equals('+919823012345'));

      // Verify with test OTP
      final verifyResult = await auth.verifyOtp(
        phone: '9823012345',
        otp: auth.devOtpCode,
      );

      expect(verifyResult['success'], isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.currentProfile, isNotNull);
      expect(auth.currentProfile!.phone, equals('+919823012345'));

      // Rejects invalid OTP
      final invalidOtpResult = await auth.verifyOtp(
        phone: '9823012345',
        otp: '999999',
      );
      expect(invalidOtpResult['success'], isFalse);
    });

    test('Profile update synchronizes profile model and local storage', () async {
      final auth = AuthService();
      await auth.sendOtp('9823099999');
      await auth.verifyOtp(phone: '9823099999', otp: auth.devOtpCode);

      final updateRes = await auth.updateProfile(
        fullName: 'Amit Deshmukh',
        email: 'amit.deshmukh@mopster.in',
        dhuleArea: 'Deopur',
        homeAddress: 'Bungalow 7, Ram Nagar, Deopur',
      );

      expect(updateRes, isTrue);
      expect(auth.currentProfile!.fullName, equals('Amit Deshmukh'));
      expect(auth.currentProfile!.email, equals('amit.deshmukh@mopster.in'));
      expect(auth.currentProfile!.dhuleArea, equals('Deopur'));
      expect(auth.currentProfile!.homeAddress,
          equals('Bungalow 7, Ram Nagar, Deopur'));

      // BookingStorage should have synced values
      final storage = BookingStorage();
      expect(storage.customerName, equals('Amit Deshmukh'));
      expect(storage.customerPhone, equals('+919823099999'));
      expect(
          storage.customerAddress, equals('Bungalow 7, Ram Nagar, Deopur'));
      expect(storage.customerId, equals(auth.currentUserId));
    });

    test('SignOut clears session and wipes local booking storage cache', () async {
      final auth = AuthService();
      await auth.sendOtp('9823055555');
      await auth.verifyOtp(phone: '9823055555', otp: auth.devOtpCode);
      expect(auth.isLoggedIn, isTrue);

      await auth.signOut();

      expect(auth.isLoggedIn, isFalse);
      expect(auth.currentProfile, isNull);
      expect(auth.currentUserId, isEmpty);

      // BookingStorage should be cleared
      final storage = BookingStorage();
      expect(storage.customerName, isEmpty);
      expect(storage.customerPhone, isEmpty);
      expect(storage.customerAddress, isEmpty);
      expect(storage.customerId, isEmpty);
      expect(storage.bookings, isEmpty);
    });
  });

  group('Customer Data Isolation Tests', () {
    test('BookingModel records customerId and preserves isolation', () {
      final bookingCustA = BookingModel(
        id: 'MOP-DHU-1001',
        customerId: 'user_cust_a',
        serviceId: 'clean_full',
        serviceTitle: 'Full-Home Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 1899.0,
        customerName: 'Customer A',
        customerPhone: '+919823011111',
        dhuleArea: 'Deopur',
        fullAddress: 'A-101, Deopur, Dhule',
        bookingDate: DateTime(2026, 10, 25),
        timeSlot: '9:00 AM - 12:00 PM',
        specialInstructions: 'Handle plants with care',
        paymentMethod: 'Cash on Delivery (Pay after service)',
        paymentStatus: 'Pending (Pay upon completion)',
        bookingStatus: 'Pending Approval',
        assignedStaff: 'Awaiting Owner Approval',
        createdAt: DateTime.now(),
      );

      final supabaseMap = bookingCustA.toSupabaseMap();
      expect(supabaseMap['customer_id'], equals('user_cust_a'));

      final reconstructed = BookingModel.fromSupabaseMap(supabaseMap);
      expect(reconstructed.customerId, equals('user_cust_a'));
      expect(reconstructed.customerName, equals('Customer A'));
    });

    test('AdminCustomerSummary aggregates customer bookings accurately', () {
      final booking1 = BookingModel(
        id: 'MOP-DHU-2001',
        customerId: 'user_cust_a',
        serviceId: 'clean_full',
        serviceTitle: 'Full-Home Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 1899.0,
        customerName: 'Customer A',
        customerPhone: '+919823011111',
        dhuleArea: 'Deopur',
        fullAddress: 'A-101, Deopur, Dhule',
        bookingDate: DateTime(2026, 10, 25),
        timeSlot: '9:00 AM - 12:00 PM',
        specialInstructions: '',
        paymentMethod: 'Cash',
        paymentStatus: 'Settled',
        bookingStatus: 'Completed',
        assignedStaff: 'Sachin Shinde',
        createdAt: DateTime(2026, 10, 20),
      );

      final booking2 = BookingModel(
        id: 'MOP-DHU-2002',
        customerId: 'user_cust_a',
        serviceId: 'clean_kitchen',
        serviceTitle: 'Kitchen Deep Clean',
        serviceCategory: 'Home Cleaning',
        totalAmount: 649.0,
        customerName: 'Customer A',
        customerPhone: '+919823011111',
        dhuleArea: 'Deopur',
        fullAddress: 'A-101, Deopur, Dhule',
        bookingDate: DateTime(2026, 10, 28),
        timeSlot: '2:00 PM - 5:00 PM',
        specialInstructions: '',
        paymentMethod: 'Cash',
        paymentStatus: 'Pending',
        bookingStatus: 'Pending Approval',
        assignedStaff: 'Awaiting Owner Approval',
        createdAt: DateTime(2026, 10, 21),
      );

      final summary = AdminCustomerSummary(
        id: 'user_cust_a',
        name: 'Customer A',
        phone: '+919823011111',
        email: 'customer.a@example.com',
        dhuleArea: 'Deopur',
        homeAddress: 'A-101, Deopur, Dhule',
        registrationDate: DateTime(2026, 10, 19),
        bookings: [booking1, booking2],
      );

      expect(summary.bookingCount, equals(2));
      expect(summary.totalSpend, equals(1899.0)); // Only completed booking counts as settled revenue
      expect(summary.initials, equals('CA'));
    });
  });
}
