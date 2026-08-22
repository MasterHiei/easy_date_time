library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  test('README quick-start parse sample remains valid', () {
    final dt = EasyDateTime.parse(
      '2026-01-18T10:30:00+08:00',
      options: const EasyParseOptions(),
    );

    expect(dt.hour, 10);
    expect(dt.locationName, 'UTC+08:00');
  });

  test('README parse options sample keeps fixed offset location', () {
    final dt = EasyDateTime.parse(
      '2026-01-18T10:30:00+08:00',
      options: const EasyParseOptions(
        mode: EasyParseMode.compatible,
        offsetResolution: OffsetResolution.fixed,
      ),
    );

    expect(dt.locationName, 'UTC+08:00');
  });

  test('README explicit location constructor sample remains valid', () {
    final meeting = EasyDateTime(2026, 5, 3, 9, 30, 0, 0, 0, TimeZones.london);

    expect(meeting.locationName, 'Europe/London');
    expect(meeting.hour, 9);
  });

  test(
    'README calendar arithmetic sample distinguishes calendar and duration',
    () {
      final beforeDst = EasyDateTime(
        2025,
        3,
        9,
        0,
        0,
        0,
        0,
        0,
        TimeZones.newYork,
      );

      expect(beforeDst.addCalendarDays(1).hour, 0);
      expect(beforeDst.add(const Duration(days: 1)).hour, 1);
    },
  );

  test('README compatibility boundary preserves Dart extension behavior', () {
    DateTime dateTime = EasyDateTime.utc(2026, 1, 18, 10, 30);

    final copied = dateTime.copyWith(isUtc: false);

    expect(copied, isA<DateTime>());
    expect(copied, isNot(isA<EasyDateTime>()));
  });

  test('README migration mapping strict true equals isoStrict mode', () {
    final legacyStrict = EasyDateTime.tryParse('2026-02-30', strict: true);
    final optionsStrict = EasyDateTime.tryParse(
      '2026-02-30',
      options: const EasyParseOptions(mode: EasyParseMode.isoStrict),
    );

    expect(legacyStrict, isNull);
    expect(optionsStrict, isNull);
  });
}
