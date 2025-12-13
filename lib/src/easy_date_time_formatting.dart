part of 'easy_date_time.dart';

// ============================================================
// Date/Time Formatting Extension
// ============================================================

/// Tokens for pattern matching.
/// Order matters: check longer tokens first.
const _tokens = [
  'yyyy',
  'yy',
  'MMM',
  'MM',
  'M',
  'EEE',
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
  'xxxxx',
  'xxxx',
  'xx',
  'X',
];

/// Day-of-week abbreviations (ISO 8601: Monday = 1)
const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Month abbreviations (1-indexed, index 0 is empty)
const _monthNames = [
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

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
  // ============================================================
  // ISO 8601 Standard Formats
  // See: https://en.wikipedia.org/wiki/ISO_8601
  // ============================================================

  /// ISO 8601 date format: `yyyy-MM-dd`
  ///
  /// International standard for date representation.
  ///
  /// Example: `2025-12-01`
  static const String isoDate = 'yyyy-MM-dd';

  /// ISO 8601 time format: `HH:mm:ss`
  ///
  /// International standard for time representation (24-hour clock).
  ///
  /// Example: `14:30:45`
  static const String isoTime = 'HH:mm:ss';

  /// ISO 8601 combined date and time format: `yyyy-MM-dd'T'HH:mm:ss`
  ///
  /// International standard using 'T' as separator.
  ///
  /// Example: `2025-12-01T14:30:45`
  static const String isoDateTime = "yyyy-MM-dd'T'HH:mm:ss";

  // ============================================================
  // RFC 2822 Standard Format
  // See: https://datatracker.ietf.org/doc/html/rfc2822#section-3.3
  // ============================================================

  /// RFC 2822 date-time format: `EEE, dd MMM yyyy HH:mm:ss xxxx`
  ///
  /// Standard format for email Date headers and HTTP headers.
  ///
  /// Example: `Thu, 12 Dec 2025 14:30:45 +0800`
  static const String rfc2822 = 'EEE, dd MMM yyyy HH:mm:ss xxxx';

  // ============================================================
  // Common Time Formats
  // ============================================================

  /// 12-hour time format with AM/PM: `hh:mm a`
  ///
  /// Example: `02:30 PM`
  static const String time12Hour = 'hh:mm a';

  /// 24-hour time format: `HH:mm`
  ///
  /// Example: `14:30`
  static const String time24Hour = 'HH:mm';
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
  /// | `EEE` | Day-of-week abbreviation | Mon, Tue, Sun |
  /// | `MMM` | Month abbreviation | Jan, Feb, Dec |
  /// | `a` | AM/PM marker (uppercase) | AM, PM |
  /// | `xxxx` | Timezone offset (iso8601) | +0800, -0500 |
  /// | `xx` | Short timezone offset | +08, -05 |
  /// | `X` | Timezone (Z for UTC, else offset) | Z, +0800 |
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
  /// - [EasyDateTimeFormatter] for pre-compiled patterns (better performance in loops)
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
    for (final token in _tokens) {
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
      'MMM' => _monthNames[month],
      'MM' => month.toString().padLeft(2, '0'),
      'M' => month.toString(),
      'EEE' => _dayNames[weekday - 1],
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
      'xxxxx' => _formatTimezoneOffset(withColon: true),
      'xxxx' => _formatTimezoneOffset(withColon: false),
      'xx' => _formatTimezoneOffsetShort(),
      'X' => _formatTimezoneOffsetOrZ(),
      _ => token,
    };
  }

  /// Formats timezone offset as +HHMM or -HHMM
  String _formatTimezoneOffset({required bool withColon}) {
    final offset = timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    if (withColon) {
      return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }

    return '$sign${hours.toString().padLeft(2, '0')}${minutes.toString().padLeft(2, '0')}';
  }

  /// Formats timezone offset as +HH or -HH (no minutes if zero)
  String _formatTimezoneOffsetShort() {
    final offset = timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    if (minutes == 0) {
      return '$sign${hours.toString().padLeft(2, '0')}';
    }

    return '$sign${hours.toString().padLeft(2, '0')}${minutes.toString().padLeft(2, '0')}';
  }

  /// Formats timezone as Z for UTC or +HHMM/-HHMM otherwise
  String _formatTimezoneOffsetOrZ() {
    if (isUtc) return 'Z';

    return _formatTimezoneOffset(withColon: false);
  }

  /// Converts 24-hour to 12-hour format.
  int get _hour12 {
    final h = hour % 12;

    return h == 0 ? 12 : h;
  }
}

/// A pre-compiled date formatter for high-performance scenarios.
///
/// Unlike [EasyDateTime.format] which parses the pattern on every call,
/// [EasyDateTimeFormatter] parses the pattern once during initialization.
/// This provides significant performance benefits in loops or hot paths.
///
/// ```dart
/// final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');
/// for (final date in dates) {
///   print(formatter.format(date));
/// }
/// ```
class EasyDateTimeFormatter {
  /// The pattern string used by this formatter.
  final String pattern;

  /// The pre-compiled tokens.
  final List<_FormatterToken> _compiledTokens;

  /// Creates a [EasyDateTimeFormatter] with the given [pattern].
  ///
  /// The pattern is parsed immediately.
  EasyDateTimeFormatter(this.pattern) : _compiledTokens = _compile(pattern);

  /// Formats the [date] using the pre-compiled pattern.
  String format(EasyDateTime date) {
    if (_compiledTokens.isEmpty) return '';

    final buffer = StringBuffer();
    for (final token in _compiledTokens) {
      buffer.write(token.format(date));
    }

    return buffer.toString();
  }

  /// Compiles the pattern into a list of executable tokens.
  static List<_FormatterToken> _compile(String pattern) {
    final tokens = <_FormatterToken>[];
    final length = pattern.length;
    var i = 0;

    while (i < length) {
      final char = pattern[i];

      // Handle escaped text in single quotes
      if (char == "'") {
        i++;
        final start = i;
        while (i < length && pattern[i] != "'") {
          i++;
        }
        tokens.add(_LiteralToken(pattern.substring(start, i)));
        if (i < length) {
          i++; // Skip closing quote
        }
        continue;
      }

      // Try to match tokens
      final tokenStr = _matchToken(pattern, i);
      if (tokenStr != null) {
        tokens.add(_PatternToken(tokenStr));
        i += tokenStr.length;
      } else {
        // Literal character
        tokens.add(_LiteralToken(char));
        i++;
      }
    }

    return tokens;
  }

  /// Matches the longest token at position [index].
  static String? _matchToken(String pattern, int index) {
    for (final token in _tokens) {
      if (pattern.startsWith(token, index)) {
        return token;
      }
    }

    return null;
  }
}

/// Base class for compiled formatter tokens.
abstract class _FormatterToken {
  String format(EasyDateTime date);
}

/// A token representing a literal string.
class _LiteralToken implements _FormatterToken {
  final String value;
  _LiteralToken(this.value);

  @override
  String format(EasyDateTime date) => value;
}

/// A token representing a variable date/time part.
class _PatternToken implements _FormatterToken {
  final String token;
  _PatternToken(this.token);

  @override
  String format(EasyDateTime date) {
    return switch (token) {
      'yyyy' => date.year.toString().padLeft(4, '0'),
      'yy' => (date.year % 100).toString().padLeft(2, '0'),
      'MMM' => _monthNames[date.month],
      'MM' => date.month.toString().padLeft(2, '0'),
      'M' => date.month.toString(),
      'EEE' => _dayNames[date.weekday - 1],
      'dd' => date.day.toString().padLeft(2, '0'),
      'd' => date.day.toString(),
      'HH' => date.hour.toString().padLeft(2, '0'),
      'H' => date.hour.toString(),
      'hh' => _hour12(date).toString().padLeft(2, '0'),
      'h' => _hour12(date).toString(),
      'mm' => date.minute.toString().padLeft(2, '0'),
      'm' => date.minute.toString(),
      'ss' => date.second.toString().padLeft(2, '0'),
      's' => date.second.toString(),
      'SSS' => date.millisecond.toString().padLeft(3, '0'),
      'S' => date.millisecond.toString(),
      'a' => date.hour < 12 ? 'AM' : 'PM',
      'xxxxx' => _formatTimezoneOffset(date, withColon: true),
      'xxxx' => _formatTimezoneOffset(date, withColon: false),
      'xx' => _formatTimezoneOffsetShort(date),
      'X' => _formatTimezoneOffsetOrZ(date),
      _ => token,
    };
  }

  int _hour12(EasyDateTime date) {
    final h = date.hour % 12;

    return h == 0 ? 12 : h;
  }

  String _formatTimezoneOffset(EasyDateTime date, {required bool withColon}) {
    final offset = date.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    if (withColon) {
      return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }

    return '$sign${hours.toString().padLeft(2, '0')}${minutes.toString().padLeft(2, '0')}';
  }

  String _formatTimezoneOffsetShort(EasyDateTime date) {
    final offset = date.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    if (minutes == 0) {
      return '$sign${hours.toString().padLeft(2, '0')}';
    }

    return '$sign${hours.toString().padLeft(2, '0')}${minutes.toString().padLeft(2, '0')}';
  }

  String _formatTimezoneOffsetOrZ(EasyDateTime date) {
    if (date.isUtc) return 'Z';

    return _formatTimezoneOffset(date, withColon: false);
  }
}
