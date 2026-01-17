import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart';

late Location localTimeZone;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
    localTimeZone = local;
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('Extensions', () {
    group('DurationExtension', () {
      test('weeks returns Duration of n weeks', () {
        expect(1.weeks, const Duration(days: 7));
        expect(2.weeks, const Duration(days: 14));
      });

      test('days returns Duration of n days', () {
        expect(1.days, const Duration(days: 1));
        expect(5.days, const Duration(days: 5));
      });

      test('hours returns Duration of n hours', () {
        expect(1.hours, const Duration(hours: 1));
        expect(24.hours, const Duration(hours: 24));
      });

      test('minutes returns Duration of n minutes', () {
        expect(1.minutes, const Duration(minutes: 1));
        expect(60.minutes, const Duration(minutes: 60));
      });

      test('seconds returns Duration of n seconds', () {
        expect(1.seconds, const Duration(seconds: 1));
        expect(60.seconds, const Duration(seconds: 60));
      });

      test('milliseconds returns Duration of n milliseconds', () {
        expect(1.milliseconds, const Duration(milliseconds: 1));
        expect(1000.milliseconds, const Duration(milliseconds: 1000));
      });

      test('microseconds returns Duration of n microseconds', () {
        expect(1.microseconds, const Duration(microseconds: 1));
        expect(1000.microseconds, const Duration(microseconds: 1000));
      });

      test('Duration getters allow summing for complex Durations', () {
        final combined = 1.days + 2.hours + 30.minutes;
        expect(
          combined,
          const Duration(days: 1, hours: 2, minutes: 30),
        );
      });
    });

    group('DateTimeExtension', () {
      test('toEasyDateTime() converts using global default location', () {
        final dt = DateTime.utc(2025, 12, 1, 10, 30);
        final easyDt = dt.toEasyDateTime();

        expect(easyDt.location, localTimeZone);
        expect(easyDt.millisecondsSinceEpoch, dt.millisecondsSinceEpoch);
      });

      test('toEasyDateTime(location: loc) converts using specified location',
          () {
        final dt = DateTime.utc(2025, 12, 1, 10, 30);
        final tokyo = getLocation('Asia/Tokyo');
        final easyDt = dt.toEasyDateTime(location: tokyo);

        expect(easyDt.locationName, 'Asia/Tokyo');
        expect(easyDt.millisecondsSinceEpoch, dt.millisecondsSinceEpoch);
      });

      test('toEasyDateTime() respects active global default location', () {
        EasyDateTime.setDefaultLocation(getLocation('Europe/London'));
        final dt = DateTime.utc(2025, 12, 1, 10, 30);
        final easyDt = dt.toEasyDateTime();

        expect(easyDt.locationName, 'Europe/London');
        EasyDateTime.clearDefaultLocation(); // Clean up
      });
    });
  });
}
