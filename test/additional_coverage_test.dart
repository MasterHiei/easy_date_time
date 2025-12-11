import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
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

    group('toLocal', () {
      test('converts to system local timezone', () {
        final utc = EasyDateTime.utc(2025, 12, 1, 12, 0);
        final local = utc.toLocal();

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

      test('same moment in different timezones has same hashCode', () {
        // 10:30 Shanghai (+8) = 11:30 Tokyo (+9) = 02:30 UTC
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final tokyo = EasyDateTime.parse('2025-12-01T11:30:00+09:00');

        expect(shanghai.hashCode, tokyo.hashCode);
      });
    });

    group('equality (==)', () {
      test('same moment in same timezone are equal', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 30);

        expect(dt1 == dt2, isTrue);
      });

      test('same moment in different timezones are equal', () {
        // 10:30 Shanghai (+8) = 11:30 Tokyo (+9) = 02:30 UTC
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final tokyo = EasyDateTime.parse('2025-12-01T11:30:00+09:00');

        expect(shanghai == tokyo, isTrue);
        expect(shanghai.isAtSameMomentAs(tokyo), isTrue);
      });

      test('different moments are not equal', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 31);

        expect(dt1 == dt2, isFalse);
      });

      test('equality is consistent with Set behavior', () {
        // Same moment in different timezones should be treated as same in Set
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final tokyo = EasyDateTime.parse('2025-12-01T11:30:00+09:00');

        final set = <EasyDateTime>{shanghai, tokyo};
        expect(set.length, 1); // Should only have one element
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

        expect(shanghai.isAtSameMomentAs(tokyo), isTrue);
      });
    });

    group('copyWithClamped', () {
      test('clamps day to February end (non-leap year)', () {
        final jan31 = EasyDateTime.utc(2025, 1, 31);
        final feb = jan31.copyWithClamped(month: 2);

        expect(feb.year, 2025);
        expect(feb.month, 2);
        expect(feb.day, 28); // Clamped to Feb 28
      });

      test('clamps day to February end (leap year)', () {
        final jan31 = EasyDateTime.utc(2024, 1, 31);
        final feb = jan31.copyWithClamped(month: 2);

        expect(feb.year, 2024);
        expect(feb.month, 2);
        expect(feb.day, 29); // Clamped to Feb 29 (leap year)
      });

      test('clamps day to 30-day month', () {
        final jan31 = EasyDateTime.utc(2025, 1, 31);
        final apr = jan31.copyWithClamped(month: 4);

        expect(apr.year, 2025);
        expect(apr.month, 4);
        expect(apr.day, 30); // Clamped to Apr 30
      });

      test('does not clamp when day is valid', () {
        final jan15 = EasyDateTime.utc(2025, 1, 15);
        final feb = jan15.copyWithClamped(month: 2);

        expect(feb.day, 15); // No clamping needed
      });

      test('handles year change with clamping', () {
        final jan31 = EasyDateTime.utc(2025, 1, 31);
        final feb2024 = jan31.copyWithClamped(year: 2024, month: 2);

        expect(feb2024.year, 2024);
        expect(feb2024.month, 2);
        expect(feb2024.day, 29); // 2024 is leap year
      });

      test('preserves time components', () {
        final dt = EasyDateTime.utc(2025, 1, 31, 14, 30, 45, 123, 456);
        final clamped = dt.copyWithClamped(month: 2);

        expect(clamped.hour, 14);
        expect(clamped.minute, 30);
        expect(clamped.second, 45);
        expect(clamped.millisecond, 123);
        expect(clamped.microsecond, 456);
      });

      test('preserves location', () {
        final tokyo = EasyDateTime(
          2025,
          1,
          31,
          10,
          0,
          0,
          0,
          0,
          TimeZones.tokyo,
        );
        final feb = tokyo.copyWithClamped(month: 2);

        expect(feb.locationName, 'Asia/Tokyo');
      });
    });
  });
}
