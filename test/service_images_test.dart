import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mopster/data/sample_services.dart';

void main() {
  group('Mopster Service Images Verification', () {
    test('Every service has a designated image asset in assets/images/services/', () {
      final services = SampleServices.allServices;
      expect(services.length, 10, reason: 'Should have exactly 10 official services');

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

    test('Both Cleaning and Gardening categories have all service images present', () {
      final cleaning = SampleServices.cleaningServices;
      final gardening = SampleServices.gardeningServices;

      expect(cleaning.length, 5);
      expect(gardening.length, 5);

      for (final c in cleaning) {
        expect(File(c.imagePath).existsSync(), isTrue);
      }

      for (final g in gardening) {
        expect(File(g.imagePath).existsSync(), isTrue);
      }
    });
  });
}
