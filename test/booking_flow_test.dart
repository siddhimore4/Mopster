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

  group('Booking Lifecycle & Persistence Tests', () {
    test('Add booking, check upcoming list, then cancel booking', () async {
      final storage = BookingStorage();
      await storage.init();

      final initialUpcomingCount = storage.upcomingBookings.length;

      // 1. Create a new test booking in Dhule
      final testBooking = BookingModel(
        id: 'MOP-TEST-9999',
        serviceId: 'clean_kitchen',
        serviceTitle: 'Kitchen Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 899.0,
        customerName: 'Aarav Deshmukh',
        customerPhone: '+91 94220 12345',
        dhuleArea: 'Agra Road',
        fullAddress: 'Flat 401, Pushpak Apartments, Agra Road, Dhule',
        bookingDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '01:30 PM - 03:30 PM (Afternoon)',
        specialInstructions: 'Please wipe exhaust fan.',
      );

      final added = await storage.addBooking(testBooking);
      expect(added, isTrue);
      expect(storage.upcomingBookings.length, equals(initialUpcomingCount + 1));

      // 2. Cancel the booking
      final cancelled = await storage.cancelBooking('MOP-TEST-9999');
      expect(cancelled, isTrue);

      final cancelledBooking =
          storage.bookings.firstWhere((b) => b.id == 'MOP-TEST-9999');
      expect(cancelledBooking.bookingStatus, equals('Cancelled'));
      expect(cancelledBooking.isUpcoming, isFalse);
    });

    test('Profile details update correctly', () async {
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
}
