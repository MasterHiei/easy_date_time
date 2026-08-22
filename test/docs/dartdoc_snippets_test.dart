library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
  });

  test('DartDoc calendar arithmetic samples define their timezone', () {
    final ny = TimeZones.newYork;
    final spring = EasyDateTime(2025, 3, 9, 0, 0, 0, 0, 0, ny);
    final autumn = EasyDateTime(2025, 11, 3, 0, 0, 0, 0, 0, ny);

    expect(spring.addCalendarDays(1).hour, 0);
    expect(autumn.subtractCalendarDays(1).hour, 0);
  });

  test('DartDoc epoch factory sample uses one declared value', () {
    const milliseconds = 1735689600000;

    final local = EasyDateTime.fromMillisecondsSinceEpoch(milliseconds);
    final utc = EasyDateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    );
    final tokyo = EasyDateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      location: TimeZones.tokyo,
    );

    expect(local.millisecondsSinceEpoch, milliseconds);
    expect(utc.locationName, 'UTC');
    expect(tokyo.locationName, 'Asia/Tokyo');
  });
}
