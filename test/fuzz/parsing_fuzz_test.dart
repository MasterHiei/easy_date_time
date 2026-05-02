library;

import 'dart:math';

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
  });

  test('tryParse never throws for randomized ASCII payloads', () {
    final random = Random(42);

    for (var i = 0; i < 2000; i++) {
      final len = random.nextInt(40);
      final chars = List.generate(len, (_) => random.nextInt(95) + 32);
      final input = String.fromCharCodes(chars);

      expect(() => EasyDateTime.tryParse(input), returnsNormally);
    }
  });

  test('tryParse remains total for randomized UTF-16 payloads', () {
    final random = Random(7);

    for (var i = 0; i < 800; i++) {
      final len = random.nextInt(24);
      final chars = List.generate(len, (_) => random.nextInt(0x10000));
      final input = String.fromCharCodes(chars);

      expect(() => EasyDateTime.tryParse(input), returnsNormally);
    }
  });
}
