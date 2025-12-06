import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    initializeTimeZone();
  });

  tearDown(() {
    clearDefaultLocation();
  });

  group('Additional core functionality tests', () {
    group('fromMicrosecondsSinceEpoch', () {
      test('creates from microseconds timestamp', () {
        final timestamp = DateTime.utc(2025, 1, 1).microsecondsSinceEpoch;
        final dt = EasyDateTime.fromMicrosecondsSinceEpoch(timestamp);

        expect(dt.year, 2025);
        expect(dt.month, 1);
        expect(dt.day, 1);
      });

      test('creates with explicit location', () {
        final timestamp =
            DateTime.utc(2025, 6, 15, 12, 0).microsecondsSinceEpoch;
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime.fromMicrosecondsSinceEpoch(
          timestamp,
          location: tokyo,
        );

        expect(dt.locationName, 'Asia/Tokyo');
        expect(dt.hour, 21); // 12 UTC = 21 Tokyo
      });

      test('microsecondsSinceEpoch property returns correct value', () {
        final dt = EasyDateTime.utc(1970, 1, 1, 0, 0, 0, 0, 1);
        expect(dt.microsecondsSinceEpoch, 1);
      });
    });

    group('inLocalTime', () {
      test('converts to system local timezone', () {
        final utc = EasyDateTime.utc(2025, 12, 1, 12, 0);
        final local = utc.inLocalTime();

        // Same moment, but in local timezone
        expect(local.millisecondsSinceEpoch, utc.millisecondsSinceEpoch);
      });
    });

    group('hashCode', () {
      test('same datetime has same hashCode', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 30);

        expect(dt1.hashCode, dt2.hashCode);
      });

      test('different datetime has different hashCode', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 31);

        expect(dt1.hashCode, isNot(dt2.hashCode));
      });
    });

    group('isToday/isTomorrow/isYesterday', () {
      test('isToday returns true for today', () {
        final now = EasyDateTime.now();
        expect(now.isToday, isTrue);
      });

      test('isTomorrow returns false for today', () {
        final now = EasyDateTime.now();
        expect(now.isTomorrow, isFalse);
      });

      test('isYesterday returns false for today', () {
        final now = EasyDateTime.now();
        expect(now.isYesterday, isFalse);
      });

      test('tomorrow property creates next day', () {
        final dt = EasyDateTime.utc(2025, 12, 15, 10, 30);
        final tom = dt.tomorrow;

        expect(tom.day, 16);
        expect(tom.hour, 10);
        expect(tom.minute, 30);
      });

      test('yesterday property creates previous day', () {
        final dt = EasyDateTime.utc(2025, 12, 15, 10, 30);
        final yest = dt.yesterday;

        expect(yest.day, 14);
        expect(yest.hour, 10);
        expect(yest.minute, 30);
      });
    });

    group('TimeZones utility methods', () {
      test('availableTimezones returns list of zones', () {
        final zones = TimeZones.availableTimezones;

        expect(zones, isNotEmpty);
        expect(zones, contains('UTC'));
        expect(zones, contains('Asia/Tokyo'));
      });

      test('isValid returns true for valid timezone', () {
        expect(TimeZones.isValid('Asia/Tokyo'), isTrue);
        expect(TimeZones.isValid('America/New_York'), isTrue);
      });

      test('isValid returns false for invalid timezone', () {
        expect(TimeZones.isValid('Invalid/Zone'), isFalse);
        expect(TimeZones.isValid(''), isFalse);
      });

      test('tryGet returns location for valid timezone', () {
        final loc = TimeZones.tryGet('Asia/Tokyo');
        expect(loc, isNotNull);
        expect(loc!.name, 'Asia/Tokyo');
      });

      test('tryGet returns null for invalid timezone', () {
        final loc = TimeZones.tryGet('Invalid/Zone');
        expect(loc, isNull);
      });
    });

    group('parse() preserves original time values', () {
      test('parse with +08:00 preserves hour', () {
        final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');
        expect(dt.hour, 10);
      });

      test('parse with +09:00 preserves hour', () {
        final dt = EasyDateTime.parse('2025-12-07T15:00:00+09:00');
        expect(dt.hour, 15);
      });

      test('parse with -05:00 preserves hour', () {
        final dt = EasyDateTime.parse('2025-12-07T08:00:00-05:00');
        expect(dt.hour, 8);
      });

      test('same moment different offsets isAtSameMoment', () {
        final shanghai = EasyDateTime.parse('2025-12-07T10:30:00+08:00');
        final tokyo = EasyDateTime.parse('2025-12-07T11:30:00+09:00');

        expect(shanghai.isAtSameMoment(tokyo), isTrue);
      });
    });
  });
}
