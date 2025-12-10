part of 'easy_date_time.dart';

// ============================================================
// Date/Time Formatting Extension
// ============================================================

/// Predefined date/time format patterns.
///
/// Use these constants with [EasyDateTime.format] for common formats:
///
/// ```dart
/// final dt = EasyDateTime.now();
/// print(dt.format(DateTimeFormats.isoDate));  // '2025-12-01'
/// print(dt.format(DateTimeFormats.usDate));   // '12/01/2025'
/// ```
abstract final class DateTimeFormats {
  /// ISO 8601 date format: `yyyy-MM-dd`
  ///
  /// Example: `2025-12-01`
  static const String isoDate = 'yyyy-MM-dd';

  /// ISO 8601 time format: `HH:mm:ss`
  ///
  /// Example: `14:30:45`
  static const String isoTime = 'HH:mm:ss';

  /// ISO 8601 date and time format: `yyyy-MM-dd'T'HH:mm:ss`
  ///
  /// Example: `2025-12-01T14:30:45`
  static const String isoDateTime = "yyyy-MM-dd'T'HH:mm:ss";

  /// US date format: `MM/dd/yyyy`
  ///
  /// Example: `12/01/2025`
  static const String usDate = 'MM/dd/yyyy';

  /// European date format: `dd/MM/yyyy`
  ///
  /// Example: `01/12/2025`
  static const String euDate = 'dd/MM/yyyy';

  /// Chinese/Japanese date format: `yyyy/MM/dd`
  ///
  /// Example: `2025/12/01`
  static const String asianDate = 'yyyy/MM/dd';

  /// Time with 12-hour clock and AM/PM: `hh:mm a`
  ///
  /// Example: `02:30 PM`
  static const String time12Hour = 'hh:mm a';

  /// Time with 24-hour clock: `HH:mm`
  ///
  /// Example: `14:30`
  static const String time24Hour = 'HH:mm';

  /// Full date and time with 24-hour clock: `yyyy-MM-dd HH:mm:ss`
  ///
  /// Example: `2025-12-01 14:30:45`
  static const String fullDateTime = 'yyyy-MM-dd HH:mm:ss';

  /// Full date and time with 12-hour clock: `yyyy-MM-dd hh:mm:ss a`
  ///
  /// Example: `2025-12-01 02:30:45 PM`
  static const String fullDateTime12Hour = 'yyyy-MM-dd hh:mm:ss a';

  /// HTTP/RFC 2822 compatible date format: `dd MM yyyy HH:mm:ss`
  ///
  /// Useful for HTTP headers and email Date fields.
  /// Note: Does not include day-of-week or timezone abbreviation.
  ///
  /// Example: `01 12 2025 14:30:45`
  static const String rfc2822 = 'dd MM yyyy HH:mm:ss';
}

/// Extension providing date/time formatting methods for [EasyDateTime].
extension EasyDateTimeFormatting on EasyDateTime {
  /// Formats this datetime using the specified [pattern].
  ///
  /// ## Supported Tokens
  ///
  /// | Token | Description | Example |
  /// |-------|-------------|---------|
  /// | `yyyy` | 4-digit year | 2025 |
  /// | `yy` | 2-digit year | 25 |
  /// | `MM` | 2-digit month (01-12) | 01, 12 |
  /// | `M` | Month without padding (1-12) | 1, 12 |
  /// | `dd` | 2-digit day (01-31) | 01, 31 |
  /// | `d` | Day without padding (1-31) | 1, 31 |
  /// | `HH` | 24-hour format, padded (00-23) | 00, 14, 23 |
  /// | `H` | 24-hour format (0-23) | 0, 14, 23 |
  /// | `hh` | 12-hour format, padded (01-12) | 01, 12 |
  /// | `h` | 12-hour format (1-12) | 1, 12 |
  /// | `mm` | Minutes, padded (00-59) | 00, 30, 59 |
  /// | `m` | Minutes (0-59) | 0, 30, 59 |
  /// | `ss` | Seconds, padded (00-59) | 00, 45, 59 |
  /// | `s` | Seconds (0-59) | 0, 45, 59 |
  /// | `SSS` | Milliseconds (000-999) | 000, 123, 999 |
  /// | `S` | Milliseconds without padding | 0, 123, 999 |
  /// | `a` | AM/PM marker (uppercase) | AM, PM |
  ///
  /// ## Escaping Literal Text
  ///
  /// Use single quotes to include literal text in the pattern:
  ///
  /// ```dart
  /// dt.format("yyyy-MM-dd'T'HH:mm:ss");  // '2025-12-01T14:30:45'
  /// dt.format("'Date:' yyyy-MM-dd");     // 'Date: 2025-12-01'
  /// ```
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final dt = EasyDateTime(2025, 12, 1, 14, 30, 45, 123);
  ///
  /// dt.format('yyyy-MM-dd');           // '2025-12-01'
  /// dt.format('yyyy/MM/dd HH:mm:ss');  // '2025/12/01 14:30:45'
  /// dt.format('MM/dd/yyyy');           // '12/01/2025'
  /// dt.format('hh:mm a');              // '02:30 PM'
  /// dt.format('HH:mm:ss.SSS');         // '14:30:45.123'
  ///
  /// // Using predefined formats
  /// dt.format(DateTimeFormats.isoDate);      // '2025-12-01'
  /// dt.format(DateTimeFormats.fullDateTime); // '2025-12-01 14:30:45'
  /// ```
  ///
  /// See also:
  /// - [DateTimeFormats] for predefined format patterns
  /// - [toIso8601String] for ISO 8601 format with timezone offset
  String format(String pattern) {
    final buffer = StringBuffer();
    final length = pattern.length;
    var i = 0;

    while (i < length) {
      final char = pattern[i];

      // Handle escaped text in single quotes
      // If quote is not closed, treat remaining content as literal (WYSIWYG)
      if (char == "'") {
        i++;
        while (i < length && pattern[i] != "'") {
          buffer.write(pattern[i]);
          i++;
        }
        if (i < length) {
          i++; // Skip closing quote only if found
        }
        continue;
      }

      // Try to match tokens (longest match first, zero-allocation)
      final token = _matchToken(pattern, i);

      if (token != null) {
        buffer.write(_formatToken(token));
        i += token.length;
      } else {
        // No token matched, write character as-is
        buffer.write(char);
        i++;
      }
    }

    return buffer.toString();
  }

  /// Matches the longest token at position [index] in [pattern].
  ///
  /// Uses [String.startsWith] with index parameter for zero-allocation matching.
  String? _matchToken(String pattern, int index) {
    // Order matters: check longer tokens first
    const tokens = [
      'yyyy',
      'yy',
      'MM',
      'M',
      'dd',
      'd',
      'HH',
      'H',
      'hh',
      'h',
      'mm',
      'm',
      'ss',
      's',
      'SSS',
      'S',
      'a',
    ];

    for (final token in tokens) {
      if (pattern.startsWith(token, index)) {
        return token;
      }
    }

    return null;
  }

  /// Formats a single token to its string value.
  String _formatToken(String token) {
    return switch (token) {
      'yyyy' => year.toString().padLeft(4, '0'),
      'yy' => (year % 100).toString().padLeft(2, '0'),
      'MM' => month.toString().padLeft(2, '0'),
      'M' => month.toString(),
      'dd' => day.toString().padLeft(2, '0'),
      'd' => day.toString(),
      'HH' => hour.toString().padLeft(2, '0'),
      'H' => hour.toString(),
      'hh' => _hour12.toString().padLeft(2, '0'),
      'h' => _hour12.toString(),
      'mm' => minute.toString().padLeft(2, '0'),
      'm' => minute.toString(),
      'ss' => second.toString().padLeft(2, '0'),
      's' => second.toString(),
      'SSS' => millisecond.toString().padLeft(3, '0'),
      'S' => millisecond.toString(),
      'a' => hour < 12 ? 'AM' : 'PM',
      _ => token,
    };
  }

  /// Converts 24-hour to 12-hour format.
  int get _hour12 {
    final h = hour % 12;

    return h == 0 ? 12 : h;
  }
}
