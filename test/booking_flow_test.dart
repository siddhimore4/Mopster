import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mopster/data/sample_services.dart';
import 'package:mopster/data/booking_storage.dart';
import 'package:mopster/models/booking_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SampleServices Repository Tests', () {
    test('Verifies 5 cleaning services and 5 gardening services', () {
      final cleaning = SampleServices.cleaningServices;
      final gardening = SampleServices.gardeningServices;

      expect(cleaning.length, equals(5));
      expect(gardening.length, equals(5));

      // Check required cleaning services
      final cleaningTitles = cleaning.map((s) => s.title).toList();
      expect(cleaningTitles, contains('Bathroom Cleaning'));
      expect(cleaningTitles, contains('Kitchen Cleaning'));
      expect(cleaningTitles, contains('Full-Home Cleaning'));
      expect(cleaningTitles, contains('Deep Home Cleaning'));
      expect(cleaningTitles, contains('Dusting & General Cleaning'));

      // Check required gardening services
      final gardeningTitles = gardening.map((s) => s.title).toList();
      expect(gardeningTitles, contains('Plant Care & Nourishment'));
      expect(gardeningTitles, contains('Garden Cleanup & Debris Removal'));
      expect(gardeningTitles, contains('Plant & Shrub Pruning'));
      expect(gardeningTitles, contains('Lawn Maintenance & Mowing'));
      expect(gardeningTitles, contains('Plant Potting & Repotting'));
    });

    test('Verifies prices are reasonable in ₹ and inclusions exist', () {
      for (final service in SampleServices.allServices) {
        expect(service.basePrice, greaterThan(0));
        expect(service.formattedPrice.startsWith('₹'), isTrue);
        expect(service.inclusions.isNotEmpty, isTrue);
        expect(service.duration.isNotEmpty, isTrue);
      }
    });
  });

  group('Requirement 1 & 2: Blank Customer Defaults & No Fake Bookings', () {
    test('New customer starts with blank name, phone, address, and zero fake bookings', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = BookingStorage();
      await storage.init();

      // Customer fields must be blank for a new user
      expect(storage.customerName, isEmpty);
      expect(storage.customerPhone, isEmpty);
      expect(storage.customerAddress, isEmpty);

      // No fake bookings or initial seed data
      expect(storage.bookings, isEmpty);
      expect(storage.upcomingBookings, isEmpty);
      expect(storage.inProgressBookings, isEmpty);
      expect(storage.pastBookings, isEmpty);
    });

    test('Detects and filters legacy test and dummy booking records safely', () {
      final dummy1 = BookingModel(
        id: 'MOP-DHU-8102',
        serviceId: 'clean_kitchen',
        serviceTitle: 'Kitchen Deep Clean',
        serviceCategory: 'Home Cleaning',
        totalAmount: 799.0,
        customerName: 'Rohan Patil',
        customerPhone: '+91 98221 44556',
        dhuleArea: 'Deopur',
        fullAddress: 'Flat 302, Deopur, Dhule',
        bookingDate: DateTime.now(),
        timeSlot: '10:00 AM',
      );

      final dummy2 = BookingModel(
        id: 'MOP-GEN-1001',
        serviceId: 'clean_bath',
        serviceTitle: 'Bathroom Clean',
        serviceCategory: 'Home Cleaning',
        totalAmount: 499.0,
        customerName: 'Rohit Patel',
        customerPhone: '+91 94220 00000',
        dhuleArea: 'Agra Road',
        fullAddress: 'Agra Road, Dhule',
        bookingDate: DateTime.now(),
        timeSlot: '02:00 PM',
      );

      final genuine = BookingModel(
        id: 'MOP-DHU-9999',
        serviceId: 'clean_full',
        serviceTitle: 'Full-Home Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 2499.0,
        customerName: 'Ananya Deshmukh',
        customerPhone: '+91 98900 11223',
        dhuleArea: 'Walwadi',
        fullAddress: 'Plot 45, Gulmohar Colony, Walwadi, Dhule',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '10:00 AM - 12:00 PM',
      );

      final inspectDummy = BookingModel(
        id: 'MOP-INSPECT-528719',
        serviceId: 'clean_deep',
        serviceTitle: 'Deep Home Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 2499.0,
        customerName: 'Inspect',
        customerPhone: '9822100000',
        dhuleArea: 'Deopur',
        fullAddress: 'Test Street',
        bookingDate: DateTime.now(),
        timeSlot: '10:00 AM',
      );

      final seedDummy = BookingModel(
        id: 'MOP-DHU-5506',
        serviceId: 'clean_bathroom',
        serviceTitle: 'Bathroom Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 499.0,
        customerName: 'Rohan Patil',
        customerPhone: '+91 9822144556',
        dhuleArea: 'Sakri Road',
        fullAddress: 'Row House 14, Anand Nagar, Deopur, Dhule',
        bookingDate: DateTime.now(),
        timeSlot: '01:30 PM',
      );

      expect(BookingStorage.isDummyBooking(dummy1), isTrue);
      expect(BookingStorage.isDummyBooking(dummy2), isTrue);
      expect(BookingStorage.isDummyBooking(inspectDummy), isTrue);
      expect(BookingStorage.isDummyBooking(seedDummy), isTrue);
      expect(BookingStorage.isDummyBooking(genuine), isFalse);
    });

    test('BookingModel toSupabaseMap supports schema compatibility with and without customer_id', () {
      final genuine = BookingModel(
        id: 'MOP-DHU-102938',
        customerId: 'auth-user-123',
        serviceId: 'clean_kitchen',
        serviceTitle: 'Kitchen Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 899.0,
        customerName: 'Gaurav Sharma',
        customerPhone: '+91 98223 34455',
        dhuleArea: 'Deopur',
        fullAddress: 'Plot 10, Sharda Nagar, Deopur, Dhule',
        bookingDate: DateTime.utc(2026, 10, 25, 10, 0),
        timeSlot: '10:00 AM - 12:00 PM',
      );

      // Default preserves customerId when present
      final mapDefault = genuine.toSupabaseMap();
      expect(mapDefault['customer_id'], equals('auth-user-123'));
      expect(mapDefault['id'], equals('MOP-DHU-102938'));
      expect(mapDefault['service_id'], equals('clean_kitchen'));
      expect(mapDefault['service_title'], equals('Kitchen Cleaning'));
      expect(mapDefault['service_category'], equals('Home Cleaning'));
      expect(mapDefault['total_amount'], equals(899.0));
      expect(mapDefault['customer_name'], equals('Gaurav Sharma'));
      expect(mapDefault['customer_phone'], equals('+91 98223 34455'));
      expect(mapDefault['booking_status'], equals('Pending Approval'));

      // Schema compatibility mode excludes customer_id for tables without that column
      final mapWithoutCustId = genuine.toSupabaseMap(includeCustomerId: false);
      expect(mapWithoutCustId.containsKey('customer_id'), isFalse);
      expect(mapWithoutCustId['id'], equals('MOP-DHU-102938'));
    });
  });

  group('Requirement 3 & 4: Owner Approval Workflow & Booking Lifecycle', () {
    test('New booking starts as Pending Approval, never automatically Confirmed', () async {
      final booking = BookingModel(
        id: 'MOP-DHU-1234',
        serviceId: 'garden_lawn',
        serviceTitle: 'Lawn Maintenance & Mowing',
        serviceCategory: 'Gardening Services',
        totalAmount: 699.0,
        customerName: 'Vikas Patil',
        customerPhone: '+91 94227 88990',
        dhuleArea: 'Wadibhokar Road',
        fullAddress: 'Row House 12, Wadibhokar Road, Dhule',
        bookingDate: DateTime.now().add(const Duration(days: 3)),
        timeSlot: '08:00 AM - 10:00 AM',
      );

      // Default status must strictly be Pending Approval
      expect(booking.bookingStatus, equals('Pending Approval'));
      expect(booking.isPendingApproval, isTrue);
      expect(booking.isConfirmed, isFalse);
      expect(booking.isInProgress, isFalse);
      expect(booking.isCompleted, isFalse);
      expect(booking.isRejected, isFalse);
      expect(booking.isCancelled, isFalse);
      expect(booking.canCancel, isTrue);
    });

    test('Owner approves booking: status updates to Confirmed and progresses', () async {
      final storage = BookingStorage();
      await storage.init();

      final newBooking = BookingModel(
        id: 'MOP-DHU-7777',
        serviceId: 'clean_bath',
        serviceTitle: 'Bathroom Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 499.0,
        customerName: 'Priya Joshi',
        customerPhone: '+91 98220 55443',
        dhuleArea: 'Sakri Road',
        fullAddress: 'Flat 201, Sakri Road, Dhule',
        bookingDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '11:00 AM - 01:00 PM',
      );

      // 1. Submit request -> saved as Pending Approval
      await storage.addBooking(newBooking);
      expect(storage.upcomingBookings.any((b) => b.id == 'MOP-DHU-7777'), isTrue);

      // 2. Owner approves request -> status becomes Confirmed
      await storage.updateBookingStatus('MOP-DHU-7777', 'Confirmed');
      final approved = storage.bookings.firstWhere((b) => b.id == 'MOP-DHU-7777');
      expect(approved.isConfirmed, isTrue);
      expect(approved.isPendingApproval, isFalse);
      expect(approved.canCancel, isTrue);

      // 3. Owner dispatches specialist -> In Progress
      await storage.updateBookingStatus('MOP-DHU-7777', 'In Progress');
      final inProgress = storage.bookings.firstWhere((b) => b.id == 'MOP-DHU-7777');
      expect(inProgress.isInProgress, isTrue);
      expect(inProgress.canCancel, isFalse); // Customer cannot cancel once service starts
      expect(storage.inProgressBookings.any((b) => b.id == 'MOP-DHU-7777'), isTrue);

      // 4. Owner marks completed -> Completed (Past Bookings)
      await storage.updateBookingStatus('MOP-DHU-7777', 'Completed');
      final completed = storage.bookings.firstWhere((b) => b.id == 'MOP-DHU-7777');
      expect(completed.isCompleted, isTrue);
      expect(storage.pastBookings.any((b) => b.id == 'MOP-DHU-7777'), isTrue);
    });

    test('Owner rejects booking: status updates to Rejected in Past Bookings', () async {
      final storage = BookingStorage();
      await storage.init();

      final bookingToReject = BookingModel(
        id: 'MOP-DHU-8888',
        serviceId: 'garden_pruning',
        serviceTitle: 'Plant & Shrub Pruning',
        serviceCategory: 'Gardening Services',
        totalAmount: 599.0,
        customerName: 'Kishore Bhamare',
        customerPhone: '+91 94222 33445',
        dhuleArea: 'Deopur',
        fullAddress: 'Near Deopur Bus Stand, Dhule',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '04:00 PM - 06:00 PM',
      );

      await storage.addBooking(bookingToReject);

      // Owner rejects request
      await storage.updateBookingStatus('MOP-DHU-8888', 'Rejected');
      final rejected = storage.bookings.firstWhere((b) => b.id == 'MOP-DHU-8888');
      expect(rejected.isRejected, isTrue);
      expect(rejected.isUpcoming, isFalse);
      expect(rejected.canCancel, isFalse);
      expect(storage.pastBookings.any((b) => b.id == 'MOP-DHU-8888'), isTrue);
    });

    test('Customer cancels booking request', () async {
      final storage = BookingStorage();
      await storage.init();

      final bookingToCancel = BookingModel(
        id: 'MOP-DHU-6666',
        serviceId: 'clean_dusting',
        serviceTitle: 'Dusting & General Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 649.0,
        customerName: 'Sunil Shinde',
        customerPhone: '+91 98224 77889',
        dhuleArea: 'Agra Road',
        fullAddress: 'Agra Road, Dhule',
        bookingDate: DateTime.now().add(const Duration(days: 4)),
        timeSlot: '10:00 AM - 12:00 PM',
      );

      await storage.addBooking(bookingToCancel);
      final cancelled = await storage.cancelBooking('MOP-DHU-6666');
      expect(cancelled, isTrue);

      final cancelledBooking =
          storage.bookings.firstWhere((b) => b.id == 'MOP-DHU-6666');
      expect(cancelledBooking.isCancelled, isTrue);
      expect(storage.pastBookings.any((b) => b.id == 'MOP-DHU-6666'), isTrue);
    });
  });

  group('Profile Persistence Tests', () {
    test('Profile updates and persists correctly without hardcoded defaults', () async {
      final storage = BookingStorage();
      await storage.init();

      await storage.updateProfile(
        name: 'Neha Kulkarni',
        phone: '+91 98231 99999',
        address: 'Bungalow 7, Walwadi, Dhule - 424005',
      );

      expect(storage.customerName, equals('Neha Kulkarni'));
      expect(storage.customerPhone, equals('+91 98231 99999'));
      expect(
          storage.customerAddress, equals('Bungalow 7, Walwadi, Dhule - 424005'));
    });
  });

  group('Payment Method & Status Lifecycle Tests (Requirement 4)', () {
    test('Distinguishes payment method from payment status and updates properly',
        () async {
      final storage = BookingStorage();
      await storage.init();

      final upiBooking = BookingModel(
        id: 'MOP-PAY-1001',
        serviceId: 'clean_kitchen',
        serviceTitle: 'Kitchen Deep Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 1199.0,
        customerName: 'Aditi Joshi',
        customerPhone: '+91 98230 44556',
        dhuleArea: 'Deopur',
        fullAddress: 'Plot 12, Deopur, Dhule',
        bookingDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '10:00 AM - 12:00 PM',
        paymentMethod: 'Direct UPI to Business (Pay after service)',
        paymentStatus: 'Pending (Pay upon completion)',
      );

      await storage.addBooking(upiBooking);
      final stored = storage.bookings.firstWhere((b) => b.id == 'MOP-PAY-1001');

      // Payment method is Direct UPI, but status is strictly Pending (not automatically paid)
      expect(stored.paymentMethod, contains('Direct UPI'));
      expect(stored.paymentStatus, contains('Pending'));
      expect(stored.paymentStatus.toLowerCase().contains('paid'), isFalse);

      // Business Owner records payment received
      final updated = await storage.updatePaymentStatus(
          'MOP-PAY-1001', 'Paid via Direct UPI (23 Oct 2026, 11:30 AM)');
      expect(updated, isTrue);

      final paidBooking =
          storage.bookings.firstWhere((b) => b.id == 'MOP-PAY-1001');
      expect(paidBooking.paymentStatus, contains('Paid via Direct UPI'));
      expect(paidBooking.paymentStatus.toLowerCase().contains('paid'), isTrue);
    });
  });
}
