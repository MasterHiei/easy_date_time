import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  group('TimeZones', () {
    group('Common timezone accessors', () {
      test('UTC is accessible', () {
        expect(TimeZones.utc.name, 'UTC');
      });

      test('Asian timezones are accessible', () {
        expect(TimeZones.tokyo.name, 'Asia/Tokyo');
        expect(TimeZones.shanghai.name, 'Asia/Shanghai');
        expect(TimeZones.beijing.name, 'Asia/Shanghai'); // Same as Shanghai
        expect(TimeZones.hongKong.name, 'Asia/Hong_Kong');
        expect(TimeZones.singapore.name, 'Asia/Singapore');
        expect(TimeZones.seoul.name, 'Asia/Seoul');
        expect(TimeZones.mumbai.name, 'Asia/Kolkata');
        expect(TimeZones.dubai.name, 'Asia/Dubai');
        expect(TimeZones.bangkok.name, 'Asia/Bangkok');
        expect(TimeZones.jakarta.name, 'Asia/Jakarta');
      });

      test('American timezones are accessible', () {
        expect(TimeZones.newYork.name, 'America/New_York');
        expect(TimeZones.losAngeles.name, 'America/Los_Angeles');
        expect(TimeZones.chicago.name, 'America/Chicago');
        expect(TimeZones.denver.name, 'America/Denver');
        expect(TimeZones.toronto.name, 'America/Toronto');
        expect(TimeZones.vancouver.name, 'America/Vancouver');
        expect(TimeZones.saoPaulo.name, 'America/Sao_Paulo');
        expect(TimeZones.mexicoCity.name, 'America/Mexico_City');
      });

      test('European timezones are accessible', () {
        expect(TimeZones.london.name, 'Europe/London');
        expect(TimeZones.paris.name, 'Europe/Paris');
        expect(TimeZones.berlin.name, 'Europe/Berlin');
        expect(TimeZones.moscow.name, 'Europe/Moscow');
        expect(TimeZones.amsterdam.name, 'Europe/Amsterdam');
        expect(TimeZones.zurich.name, 'Europe/Zurich');
        expect(TimeZones.madrid.name, 'Europe/Madrid');
        expect(TimeZones.rome.name, 'Europe/Rome');
      });

      test('Pacific timezones are accessible', () {
        expect(TimeZones.sydney.name, 'Australia/Sydney');
        expect(TimeZones.melbourne.name, 'Australia/Melbourne');
        expect(TimeZones.auckland.name, 'Pacific/Auckland');
        expect(TimeZones.honolulu.name, 'Pacific/Honolulu');
      });

      test('African and Middle Eastern timezones are accessible', () {
        expect(TimeZones.cairo.name, 'Africa/Cairo');
        expect(TimeZones.johannesburg.name, 'Africa/Johannesburg');
        expect(TimeZones.jerusalem.name, 'Asia/Jerusalem');
      });
    });

    group('Utility methods', () {
      test('availableTimezones returns non-empty list', () {
        final zones = TimeZones.availableTimezones;
        expect(zones, isNotEmpty);
        expect(zones, contains('UTC'));
        expect(zones, contains('Asia/Tokyo'));
      });

      test('isValid returns true for valid timezone', () {
        expect(TimeZones.isValid('Asia/Tokyo'), isTrue);
        expect(TimeZones.isValid('America/New_York'), isTrue);
        expect(TimeZones.isValid('UTC'), isTrue);
      });

      test('isValid returns false for invalid timezone', () {
        expect(TimeZones.isValid('Invalid/Zone'), isFalse);
        expect(TimeZones.isValid('NotATimezone'), isFalse);
        expect(TimeZones.isValid(''), isFalse);
      });

      test('tryGet returns Location for valid timezone', () {
        final location = TimeZones.tryGet('Asia/Tokyo');
        expect(location, isNotNull);
        expect(location!.name, 'Asia/Tokyo');
      });

      test('tryGet returns null for invalid timezone', () {
        expect(TimeZones.tryGet('Invalid/Zone'), isNull);
        expect(TimeZones.tryGet(''), isNull);
      });
    });

    group('Integration with EasyDateTime', () {
      test('TimeZones can be used with EasyDateTime.now()', () {
        final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
        expect(tokyo.locationName, 'Asia/Tokyo');
      });

      test('TimeZones can be used with EasyDateTime constructor', () {
        final dt = EasyDateTime(2025, 12, 1, 10, 0, 0, 0, 0, TimeZones.newYork);
        expect(dt.locationName, 'America/New_York');
      });

      test('TimeZones can be used with inLocation()', () {
        final utc = EasyDateTime.utc(2025, 12, 1, 10, 0);
        final london = utc.inLocation(TimeZones.london);
        expect(london.locationName, 'Europe/London');
      });

      test('TimeZones can be used with setDefaultLocation', () {
        EasyDateTime.setDefaultLocation(TimeZones.tokyo);
        final dt = EasyDateTime.now();
        expect(dt.locationName, 'Asia/Tokyo');
        EasyDateTime.clearDefaultLocation();
      });
    });
  });
}
