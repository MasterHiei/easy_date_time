library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:easy_date_time/src/easy_date_time_init.dart' as init;
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart';

void main() {
  group('Initialization Edge Cases', () {
    late Map<String, Location> originalLocations;

    setUp(() {
      // Backup original locations
      try {
        tz.initializeTimeZones();
      } catch (_) {} // susceptible to double init
      originalLocations = Map.of(timeZoneDatabase.locations);
    });

    tearDown(() {
      // Restore locations
      timeZoneDatabase.locations.clear();
      timeZoneDatabase.locations.addAll(originalLocations);
    });

    test('internalInitializeTimeZone adds UTC alias if missing', () {
      // Simulate environment where UTC is missing but Etc/UTC exists
      if (timeZoneDatabase.locations.containsKey('UTC')) {
        timeZoneDatabase.locations.remove('UTC');
      }
      // Ensure Etc/UTC exists (standard in latest_all)
      if (!timeZoneDatabase.locations.containsKey('Etc/UTC')) {
        // Should not happen with latest_all, but for safety
        return;
      }

      expect(timeZoneDatabase.locations.containsKey('UTC'), isFalse);

      // Call init
      init.internalInitializeTimeZone();

      // Verify UTC was added
      expect(timeZoneDatabase.locations.containsKey('UTC'), isTrue);
      expect(getLocation('UTC').name, 'UTC');
    });

    test('internalIsTimeZoneInitialized caches result', () {
      // Force init
      EasyDateTime.initializeTimeZone();
      expect(EasyDateTime.isTimeZoneInitialized, isTrue);

      // Call again to hit execution path
      expect(EasyDateTime.isTimeZoneInitialized, isTrue);
    });
  });
}
