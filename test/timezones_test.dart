import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('TimeZones', () {
    group('Constants Availability', () {
      test('should define UTC', () {
        expect(TimeZones.utc.name, 'UTC');
      });

      test('should define major Asian timezones', () {
        expect(TimeZones.tokyo.name, 'Asia/Tokyo');
        expect(TimeZones.shanghai.name, 'Asia/Shanghai');
        expect(TimeZones.beijing.name, 'Asia/Shanghai');
        expect(TimeZones.hongKong.name, 'Asia/Hong_Kong');
        expect(TimeZones.singapore.name, 'Asia/Singapore');
        expect(TimeZones.seoul.name, 'Asia/Seoul');
        expect(TimeZones.mumbai.name, 'Asia/Kolkata');
        expect(TimeZones.dubai.name, 'Asia/Dubai');
        expect(TimeZones.bangkok.name, 'Asia/Bangkok');
        expect(TimeZones.jakarta.name, 'Asia/Jakarta');
      });

      test('should define major American timezones', () {
        expect(TimeZones.newYork.name, 'America/New_York');
        expect(TimeZones.losAngeles.name, 'America/Los_Angeles');
        expect(TimeZones.chicago.name, 'America/Chicago');
        expect(TimeZones.denver.name, 'America/Denver');
        expect(TimeZones.toronto.name, 'America/Toronto');
        expect(TimeZones.vancouver.name, 'America/Vancouver');
        expect(TimeZones.saoPaulo.name, 'America/Sao_Paulo');
        expect(TimeZones.mexicoCity.name, 'America/Mexico_City');
      });

      test('should define major European timezones', () {
        expect(TimeZones.london.name, 'Europe/London');
        expect(TimeZones.paris.name, 'Europe/Paris');
        expect(TimeZones.berlin.name, 'Europe/Berlin');
        expect(TimeZones.moscow.name, 'Europe/Moscow');
        expect(TimeZones.amsterdam.name, 'Europe/Amsterdam');
        expect(TimeZones.zurich.name, 'Europe/Zurich');
        expect(TimeZones.madrid.name, 'Europe/Madrid');
        expect(TimeZones.rome.name, 'Europe/Rome');
      });

      test('should define major Pacific timezones', () {
        expect(TimeZones.sydney.name, 'Australia/Sydney');
        expect(TimeZones.melbourne.name, 'Australia/Melbourne');
        expect(TimeZones.auckland.name, 'Pacific/Auckland');
        expect(TimeZones.honolulu.name, 'Pacific/Honolulu');
      });

      test('should define major African and Middle Eastern timezones', () {
        expect(TimeZones.cairo.name, 'Africa/Cairo');
        expect(TimeZones.johannesburg.name, 'Africa/Johannesburg');
        expect(TimeZones.jerusalem.name, 'Asia/Jerusalem');
      });
    });

    group('Utilities', () {
      test(
        'availableTimezones should return non-empty list of identifiers',
        () {
          final zones = TimeZones.availableTimezones;
          expect(zones, isNotEmpty);
          expect(zones, contains('UTC'));
          expect(zones, contains('Asia/Tokyo'));
        },
      );

      test('isValid should return true for valid identifiers', () {
        expect(TimeZones.isValid('Asia/Tokyo'), isTrue);
        expect(TimeZones.isValid('America/New_York'), isTrue);
        expect(TimeZones.isValid('UTC'), isTrue);
      });

      test('isValid should return false for invalid identifiers', () {
        expect(TimeZones.isValid('Invalid/Zone'), isFalse);
        expect(TimeZones.isValid('NotATimezone'), isFalse);
        expect(TimeZones.isValid(''), isFalse);
      });

      test('tryGet should return Location for valid identifier', () {
        final location = TimeZones.tryGet('Asia/Tokyo');
        expect(location, isNotNull);
        expect(location!.name, 'Asia/Tokyo');
      });

      test('tryGet should return null for invalid identifier', () {
        expect(TimeZones.tryGet('Invalid/Zone'), isNull);
        expect(TimeZones.tryGet(''), isNull);
      });
    });

    group('EasyDateTime Integration', () {
      test('should work with EasyDateTime.now()', () {
        final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
        expect(tokyo.locationName, 'Asia/Tokyo');
      });

      test('should work with EasyDateTime explicit constructor', () {
        final dt = EasyDateTime(2025, 12, 1, 10, 0, 0, 0, 0, TimeZones.newYork);
        expect(dt.locationName, 'America/New_York');
      });

      test('should work with inLocation() conversion', () {
        final utc = EasyDateTime.utc(2025, 12, 1, 10, 0);
        final london = utc.inLocation(TimeZones.london);
        expect(london.locationName, 'Europe/London');
      });

      test('should work with setDefaultLocation', () {
        EasyDateTime.setDefaultLocation(TimeZones.tokyo);
        final dt = EasyDateTime.now();
        expect(dt.locationName, 'Asia/Tokyo');
        EasyDateTime.clearDefaultLocation();
      });
    });

    group('Error Handling', () {
      test('getLocation should throw on invalid identifier', () {
        expect(() => getLocation('Invalid/Timezone'), throwsException);
      });

      test('getLocation should throw on empty string', () {
        expect(() => getLocation(''), throwsException);
      });

      test('getLocation should throw on partial match', () {
        expect(() => getLocation('Asia'), throwsException);
      });
    });
  });
}
