library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('EasyDateTime Parsing', () {
    group('tryParse', () {
      test('should return instance for valid ISO 8601 strings', () {
        expect(EasyDateTime.tryParse('2025-12-01T10:30:00Z'), isNotNull);
        expect(EasyDateTime.tryParse('2025-12-01T10:30:00+09:00'), isNotNull);
        expect(EasyDateTime.tryParse('2025-12-01'), isNotNull);
      });

      test(
        'should return instance for fallback formats (Slash, Dash, Dot)',
        () {
          expect(EasyDateTime.tryParse('2025/12/01'), isNotNull);
          expect(EasyDateTime.tryParse('2025/12/01 10:30:00'), isNotNull);
          expect(EasyDateTime.tryParse('2025-12-01 10:30:00'), isNotNull);
          expect(EasyDateTime.tryParse('2025.12.01'), isNotNull);
          expect(EasyDateTime.tryParse('2025.12.01 10:30:00'), isNotNull);
        },
      );

      test('should return null for excessively long inputs', () {
        final longString = '2025-12-01${' ' * 1000}10:00';
        final veryLongInvalid = 'a' * 200;

        expect(EasyDateTime.tryParse(longString), isNull);
        expect(EasyDateTime.tryParse(veryLongInvalid), isNull);
      });

      test('should return null for invalid date components', () {
        expect(EasyDateTime.tryParse('2025/13/01'), isNull); // Month is 13.
        expect(EasyDateTime.tryParse('2025/12/32'), isNull); // Day is 32.
        expect(
          EasyDateTime.tryParse('202A/12/01'),
          isNull,
        ); // Invalid year format.
      });

      test('should handle T prefix in time part within fallback formats', () {
        expect(EasyDateTime.tryParse('2025/12/01T10:30:00'), isNotNull);
      });

      test('should ignore leading and trailing whitespace', () {
        expect(EasyDateTime.tryParse('  2025-12-01T10:00:00Z  '), isNotNull);
        expect(EasyDateTime.tryParse('  2025/12/01  '), isNotNull);
      });

      test('should return null for completely invalid inputs', () {
        expect(EasyDateTime.tryParse(''), isNull);
        expect(EasyDateTime.tryParse('   '), isNull);
        expect(EasyDateTime.tryParse('not-a-date'), isNull);
        expect(EasyDateTime.tryParse('🎄'), isNull);
        expect(EasyDateTime.tryParse('null'), isNull);
      });
    });

    group('parse', () {
      test('should handle uncommon timezone offsets', () {
        const input = '2025-12-01T10:00:00+05:45'; // Nepal time (+05:45).

        final result = EasyDateTime.parse(input);

        expect(result.hour, 10);
        expect(result.locationName, 'Asia/Kathmandu');
      });

      test(
        'should throw InvalidTimeZoneException for non-standard offsets',
        () {
          const input = '2025-12-01T10:00:00+05:17';

          expect(
            () => EasyDateTime.parse(input),
            throwsA(isA<InvalidTimeZoneException>()),
          );
        },
      );

      test('tryParse returns null for non-standard offsets', () {
        const input = '2025-12-01T10:00:00+05:17';

        final result = EasyDateTime.tryParse(input);

        expect(result, isNull);
      });

      test('should handle DST offsets correctly', () {
        const input = '2025-07-01T10:00:00-04:00'; // Timezone is EDT.

        final result = EasyDateTime.parse(input);

        expect(result.hour, 10);
        expect(result.locationName, 'America/New_York');
      });

      group('Offset Variations', () {
        test('should parse +00:00 as UTC', () {
          expect(
            EasyDateTime.parse('2025-12-01T10:00:00+00:00').locationName,
            'UTC',
          );
        });

        test('should parse +01:00', () {
          expect(EasyDateTime.parse('2025-12-01T10:00:00+01:00').hour, 10);
        });

        test('should parse +05:00', () {
          expect(EasyDateTime.parse('2025-12-01T10:00:00+05:00').hour, 10);
        });

        test('should parse +09:00 as Tokyo', () {
          expect(
            EasyDateTime.parse('2025-12-01T10:00:00+09:00').locationName,
            'Asia/Tokyo',
          );
        });

        test('should parse +09:30 as Adelaide', () {
          expect(EasyDateTime.parse('2025-12-01T10:00:00+09:30').hour, 10);
        });

        test(
          'should fallback lookup for offsets not in common mapping (-03:30)',
          () {
            final dt = EasyDateTime.parse('2025-12-01T10:00:00-03:30');
            expect(dt.hour, 10);
            expect(dt.locationName, 'America/St_Johns');
          },
        );
      });

      group('Input Variations', () {
        test('should parse date with time and offset', () {
          final dt = EasyDateTime.parse('2025-12-01T00:00:00+08:00');
          expect(dt.year, 2025);
          expect(dt.month, 12);
          expect(dt.day, 1);
          expect(dt.hour, 0);
        });

        test('should parse date with negative timezone offset', () {
          final dt = EasyDateTime.parse('2025-12-01T10:00:00-05:00');
          expect(dt.hour, 10);
          expect(dt.locationName, 'America/New_York');
        });

        test('should parse with fractional seconds', () {
          final dt = EasyDateTime.parse('2025-12-01T10:30:45.123456Z');
          expect(dt.millisecond, 123);
          expect(dt.microsecond, 456);
        });

        test('should convert to explicitly provided location', () {
          final dt = EasyDateTime.parse(
            '2025-12-01T10:00:00Z',
            location: TimeZones.tokyo,
          );
          // 10:00 UTC = 19:00 Tokyo
          expect(dt.hour, 19);
          expect(dt.locationName, 'Asia/Tokyo');
        });

        test(
          'should convert offset string to explicitly provided location',
          () {
            final dt = EasyDateTime.parse(
              '2025-12-01T10:00:00+08:00',
              location: TimeZones.newYork,
            );
            // 10:00+08:00 = 02:00 UTC = 21:00 previous day in NY
            expect(dt.locationName, 'America/New_York');
          },
        );

        test('should handle date-only strings', () {
          final dt = EasyDateTime.parse('2025-12-01');
          expect(dt.year, 2025);
          expect(dt.month, 12);
          expect(dt.day, 1);
          expect(dt.hour, 0);
        });

        test('should accept ISO 8601 variants', () {
          expect(EasyDateTime.parse('2025-12-01').year, 2025);
          expect(EasyDateTime.parse('2025-12-01T10:30:00').hour, 10);
          expect(
            EasyDateTime.parse('2025-12-01T10:30:00Z').locationName,
            'UTC',
          );
          expect(EasyDateTime.parse('2025-12-01T10:30:00+09:00'), isNotNull);
        });

        test(
          'should overflow invalid dates consistent with DateTime behavior',
          () {
            // 2025-02-30 -> 2025-03-02
            final dt = EasyDateTime.parse('2025-02-30');
            expect(dt.month, 3);
            expect(dt.day, 2);
          },
        );
      });

      group('Validation', () {
        test('should throw FormatException on invalid inputs', () {
          expect(
            () => EasyDateTime.parse('not-a-valid-date-at-all'),
            throwsFormatException,
          );
          expect(() => EasyDateTime.parse(''), throwsFormatException);
          expect(() => EasyDateTime.parse('   '), throwsFormatException);
          expect(() => EasyDateTime.parse('🎄🎅🎁'), throwsFormatException);
        });
      });
    });

    group('DST Transition Handling', () {
      test('should match DateTime.parse result for Spring Forward gap', () {
        // 2023-03-12 02:30 is invalid in local time but valid with offset
        const input = '2023-03-12T02:30:00-04:00';

        final standard = DateTime.parse(input);
        final easy = EasyDateTime.parse(input);

        expect(
          easy.microsecondsSinceEpoch,
          equals(standard.microsecondsSinceEpoch),
        );
      });

      test('should convert gap time to correct UTC equivalent', () {
        // 02:30 at UTC-4 = 06:30 UTC
        final parsed = EasyDateTime.parse('2023-03-12T02:30:00-04:00');

        expect(parsed.toUtc().hour, equals(6));
        expect(parsed.toUtc().minute, equals(30));
      });

      test(
        'should distinguish Fall Back overlap - First Occurrence (Pre-Switch)',
        () {
          const input = '2023-11-05T01:30:00-04:00'; // EDT

          final standard = DateTime.parse(input);
          final easy = EasyDateTime.parse(input);

          expect(
            easy.microsecondsSinceEpoch,
            equals(standard.microsecondsSinceEpoch),
          );
          expect(easy.toUtc().hour, equals(5)); // 01:30-04:00 = 05:30 UTC
        },
      );

      test(
        'should distinguish Fall Back overlap - Second Occurrence (Post-Switch)',
        () {
          const input = '2023-11-05T01:30:00-05:00'; // EST

          final standard = DateTime.parse(input);
          final easy = EasyDateTime.parse(input);

          expect(
            easy.microsecondsSinceEpoch,
            equals(standard.microsecondsSinceEpoch),
          );
          expect(easy.toUtc().hour, equals(6)); // 01:30-05:00 = 06:30 UTC
        },
      );

      test(
        'should correctly calculate duration between repeated overlap hours',
        () {
          final firstOccurrence = EasyDateTime.parse(
            '2023-11-05T01:30:00-04:00',
          );
          final secondOccurrence = EasyDateTime.parse(
            '2023-11-05T01:30:00-05:00',
          );

          final difference = secondOccurrence.difference(firstOccurrence);

          expect(difference, equals(const Duration(hours: 1)));
        },
      );

      test(
        'should parse correctly crossing seasons (Summer offset in Winter)',
        () {
          const summerInput = '2025-07-01T10:00:00-04:00';

          final standard = DateTime.parse(summerInput);
          final easy = EasyDateTime.parse(summerInput);

          expect(
            easy.microsecondsSinceEpoch,
            equals(standard.microsecondsSinceEpoch),
          );
        },
      );

      test(
        'should parse correctly crossing seasons (Winter offset in Summer)',
        () {
          const winterInput = '2025-01-15T10:00:00-05:00';

          final standard = DateTime.parse(winterInput);
          final easy = EasyDateTime.parse(winterInput);

          expect(
            easy.microsecondsSinceEpoch,
            equals(standard.microsecondsSinceEpoch),
          );
        },
      );
    });

    group('Performance Metrics', () {
      test(
        'should parse ISO 8601 strings efficiently (<500ms for 1000 iter)',
        () {
          final stopwatch = Stopwatch()..start();

          for (int i = 0; i < 1000; i++) {
            EasyDateTime.parse('2025-12-01T10:30:00Z');
          }
          stopwatch.stop();

          expect(stopwatch.elapsedMilliseconds, lessThan(500));
        },
      );

      test(
        'tryParse should parse very long strings with whitespace efficiently (<100ms)',
        () {
          final input = '2025-01-01${' ' * 10000}';
          final start = DateTime.now();

          final result = EasyDateTime.tryParse(input);
          final elapsed = DateTime.now().difference(start);

          expect(result, isNotNull);
          expect(elapsed.inMilliseconds, lessThan(100));
        },
      );
    });

    group('Strict Parsing', () {
      test('should accept valid dates in strict mode', () {
        expect(EasyDateTime.parse('2025-02-28', strict: true).day, 28);
        expect(
          EasyDateTime.parse('2024-02-29', strict: true).day,
          29, // Leap year.
        );
      });

      test('should reject invalid days in strict mode', () {
        expect(
          () => EasyDateTime.parse('2025-02-30', strict: true),
          throwsFormatException,
        );
        expect(
          () => EasyDateTime.parse('2025-02-29', strict: true),
          throwsFormatException, // Not a leap year.
        );
        expect(
          () => EasyDateTime.parse('2025-04-31', strict: true),
          throwsFormatException, // April has 30 days.
        );
      });

      test('should reject invalid months in strict mode', () {
        expect(
          () => EasyDateTime.parse('2025-13-01', strict: true),
          throwsFormatException,
        );
        expect(
          () => EasyDateTime.parse('2025-00-01', strict: true),
          throwsFormatException,
        );
      });

      test('tryParse strict should return null for invalid dates', () {
        expect(EasyDateTime.tryParse('2025-02-30', strict: true), isNull);
        expect(EasyDateTime.tryParse('2025-13-01', strict: true), isNull);
      });

      test(
        'should maintain overflow behavior when strict is false (default)',
        () {
          // 2025-02-30 -> 2025-03-02
          final dt = EasyDateTime.parse('2025-02-30');
          expect(dt.month, 3);
          expect(dt.day, 2);

          final dtExplicit = EasyDateTime.parse('2025-02-30', strict: false);
          expect(dtExplicit.month, 3);
          expect(dtExplicit.day, 2);
        },
      );
    });
  });
}
