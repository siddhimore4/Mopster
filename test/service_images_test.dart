import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mopster/data/sample_services.dart';
import 'package:mopster/models/booking_model.dart';
import 'package:mopster/models/service_item.dart';
import 'package:mopster/services/ratings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Mopster Service Images & Car Washing Category Verification', () {
    test('Every service has a designated image asset in assets/images/services/', () {
      final services = SampleServices.allServices;
      expect(services.length, 11, reason: 'Should have 11 official services (5 cleaning + 5 gardening + 1 car washing)');

      for (final service in services) {
        expect(service.imagePath, isNotEmpty,
            reason: '${service.title} should have an imagePath');
        expect(service.imagePath, startsWith('assets/images/services/'));
        expect(service.imagePath, endsWith('.jpg'));

        final file = File(service.imagePath);
        expect(file.existsSync(), isTrue,
            reason: 'File ${service.imagePath} must exist on disk for service ${service.title} (${service.id})');
        expect(file.lengthSync(), greaterThan(10000),
            reason: 'Image file ${service.imagePath} should be a realistic image of substantial size');
      }
    });

    test('All categories (Cleaning, Gardening, Car Washing) have all service images present', () {
      final cleaning = SampleServices.cleaningServices;
      final gardening = SampleServices.gardeningServices;
      final carWashing = SampleServices.carWashingServices;

      expect(cleaning.length, 5);
      expect(gardening.length, 5);
      expect(carWashing.length, 1);

      for (final c in cleaning) {
        expect(File(c.imagePath).existsSync(), isTrue);
      }

      for (final g in gardening) {
        expect(File(g.imagePath).existsSync(), isTrue);
      }

      for (final cw in carWashing) {
        expect(File(cw.imagePath).existsSync(), isTrue);
        expect(cw.category, ServiceCategory.carWashing);
        expect(cw.id, 'car_wash_doorstep');
        expect(cw.imagePath, 'assets/images/services/car_wash.jpg');
      }
    });

    test('Services start with NO hardcoded ratings or fake review counts', () {
      for (final service in SampleServices.allServices) {
        expect(service.rating, isNull,
            reason: 'Service ${service.title} must not have hardcoded ratings');
        expect(service.reviewCount, equals(0),
            reason: 'Service ${service.title} must have 0 initial reviews');
        expect(service.hasRatings, isFalse);
      }
    });

    test('Dynamic Ratings Engine enforces completion and prevents duplicates', () async {
      SharedPreferences.setMockInitialValues({});
      final ratingsService = RatingsService();
      await ratingsService.init();

      // Check initial state
      final initialSummary = ratingsService.getSummaryForService('clean_kitchen');
      expect(initialSummary.hasRatings, isFalse);
      expect(initialSummary.averageRating, isNull);
      expect(initialSummary.totalReviews, 0);

      // Incomplete booking cannot be rated
      final pendingBooking = BookingModel(
        id: 'MOP-TEST-PENDING-1',
        serviceId: 'clean_kitchen',
        serviceTitle: 'Kitchen Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 899.0,
        customerName: 'Dhule Resident',
        customerPhone: '9822100000',
        dhuleArea: 'Deopur',
        fullAddress: 'Plot 10, Deopur',
        bookingDate: DateTime.now(),
        timeSlot: '10:00 AM',
        bookingStatus: 'Pending Approval',
      );

      final pendingResult = await ratingsService.submitReview(
        booking: pendingBooking,
        rating: 5.0,
        comment: 'Premature review',
      );
      expect(pendingResult, isFalse, reason: 'Incomplete booking should not be rateable');

      // Completed booking can be rated
      final completedBooking = BookingModel(
        id: 'MOP-TEST-COMPLETED-1',
        serviceId: 'clean_kitchen',
        serviceTitle: 'Kitchen Cleaning',
        serviceCategory: 'Home Cleaning',
        totalAmount: 899.0,
        customerName: 'Dhule Resident',
        customerPhone: '9822100000',
        dhuleArea: 'Deopur',
        fullAddress: 'Plot 10, Deopur',
        bookingDate: DateTime.now(),
        timeSlot: '10:00 AM',
        bookingStatus: 'Completed',
      );

      final success = await ratingsService.submitReview(
        booking: completedBooking,
        rating: 5.0,
        comment: 'Super sparkling clean kitchen!',
      );
      expect(success, isTrue);
      expect(ratingsService.hasReviewedBooking('MOP-TEST-COMPLETED-1'), isTrue);

      // Verify updated dynamic rating
      final updatedSummary = ratingsService.getSummaryForService('clean_kitchen');
      expect(updatedSummary.hasRatings, isTrue);
      expect(updatedSummary.averageRating, 5.0);
      expect(updatedSummary.totalReviews, 1);

      // Duplicate rating on same booking is rejected
      final duplicateResult = await ratingsService.submitReview(
        booking: completedBooking,
        rating: 4.0,
        comment: 'Trying to review again',
      );
      expect(duplicateResult, isFalse, reason: 'Duplicate rating on same booking must be rejected');
      expect(ratingsService.getSummaryForService('clean_kitchen').totalReviews, 1);
    });
  });
}
