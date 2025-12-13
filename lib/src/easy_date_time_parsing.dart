part of 'easy_date_time.dart';

// ============================================================
// Parsing Helper Methods
// ============================================================

/// Pattern for timezone offset: +HH:MM, -HH:MM, +HHMM, -HHMM at end of string.
final _timezoneOffsetPattern = RegExp(r'([+-])(\d{2}):?(\d{2})$');

/// Pattern to strip timezone suffix from ISO 8601 strings.
final _timezoneSuffixPattern = RegExp(r'[+-]\d{2}:?\d{2}$');

/// Pattern for ISO 8601 datetime: YYYY-MM-DDTHH:MM:SS.sss or YYYY-MM-DD HH:MM:SS.sss.
final _iso8601Pattern = RegExp(
  r'^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?',
);

/// Extracts timezone offset from an ISO 8601 string.
/// Returns the offset as Duration, or null if no offset found.
Duration? _extractTimezoneOffset(String input) {
  final match = _timezoneOffsetPattern.firstMatch(input);
  if (match == null) return null;

  final sign = match.group(1) == '+' ? 1 : -1;
  final hours = int.parse(match.group(2)!);
  final minutes = int.parse(match.group(3)!);

  return Duration(hours: sign * hours, minutes: sign * minutes);
}

/// Formats a Duration offset as a timezone offset string (e.g., +05:17).
String _formatOffset(Duration offset) {
  final totalMinutes = offset.inMinutes;
  final sign = totalMinutes >= 0 ? '+' : '-';
  final absMinutes = totalMinutes.abs();
  final hours = absMinutes ~/ 60;
  final minutes = absMinutes % 60;

  return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}

/// Extracts original time components from an ISO 8601 string,
/// before any timezone conversion.
({
  int year,
  int month,
  int day,
  int hour,
  int minute,
  int second,
  int millisecond,
  int microsecond
})? _extractOriginalTimeComponents(String input) {
  // Remove timezone suffix for parsing
  final withoutTz = input.replaceAll(_timezoneSuffixPattern, '');

  // Match ISO 8601 datetime components
  final match = _iso8601Pattern.firstMatch(withoutTz);

  if (match == null) {
    return null;
  }

  // Parse fractional seconds
  final fractionStr = match.group(7) ?? '0';
  final fraction = fractionStr.padRight(6, '0');
  final millisecond = int.parse(fraction.substring(0, 3));
  final microsecond = int.parse(fraction.substring(3, 6));

  return (
    year: int.parse(match.group(1)!),
    month: int.parse(match.group(2)!),
    day: int.parse(match.group(3)!),
    hour: int.parse(match.group(4)!),
    minute: int.parse(match.group(5)!),
    second: int.parse(match.group(6)!),
    millisecond: millisecond,
    microsecond: microsecond,
  );
}

/// Common timezone mappings for efficiency (most used offsets).
///
/// When multiple regions share an offset, we pick a representative one.
/// The fallback search will find others if this one doesn't match.
///
/// **Maintenance Note:** This map is an optimization to avoid iterating through
/// the entire timezone database for common offsets. It should be periodically
/// reviewed to ensure the representative locations are still valid and relevant.
const _commonOffsetMappings = <int, String>{
  // UTC
  0: 'UTC',
  // Europe (Standard + DST)
  60: 'Europe/Paris', // CET (Central European winter)
  120: 'Europe/Paris', // CEST (Central European summer)
  180: 'Europe/Moscow', // MSK
  // Middle East / South Asia
  240: 'Asia/Dubai', // GST (+4)
  270: 'Asia/Kabul', // +4:30
  300: 'Asia/Karachi', // PKT (+5)
  330: 'Asia/Kolkata', // IST (+5:30)
  345: 'Asia/Kathmandu', // +5:45
  360: 'Asia/Dhaka', // BST (+6)
  390: 'Asia/Yangon', // +6:30
  420: 'Asia/Bangkok', // ICT (+7)
  // East Asia
  480: 'Asia/Shanghai', // CST (+8)
  540: 'Asia/Tokyo', // JST (+9)
  570: 'Australia/Adelaide', // ACST (+9:30)
  // Oceania (Standard + DST)
  600: 'Australia/Sydney', // AEST (+10)
  630: 'Australia/Lord_Howe', // +10:30
  660: 'Pacific/Noumea', // +11
  720: 'Pacific/Auckland', // NZST (+12)
  780: 'Pacific/Apia', // +13
  // Americas (Standard + DST)
  -180: 'America/Sao_Paulo', // BRT (-3)
  -240: 'America/New_York', // EDT (summer, -4)
  -300: 'America/New_York', // EST (winter, -5)
  -360: 'America/Chicago', // CST (winter, -6)
  -420: 'America/Denver', // MST (winter, -7)
  -480: 'America/Los_Angeles', // PST (winter, -8)
  -540: 'America/Anchorage', // AKST (-9)
  -600: 'Pacific/Honolulu', // HST (-10)
};

/// Cache for offset to location lookups to improve performance of parsing.
/// Maps offset in minutes -> Location.
final _offsetLocationCache = <int, Location?>{};

/// Finds an IANA timezone that matches the given UTC offset.
///
/// Returns null if no matching timezone is found or if timezone
/// database is not initialized.
Location? _findLocationForOffset(Duration offset) {
  if (!init.internalIsTimeZoneInitialized) {
    return null;
  }

  final offsetMinutes = offset.inMinutes;
  // Check cache first
  if (_offsetLocationCache.containsKey(offsetMinutes)) {
    return _offsetLocationCache[offsetMinutes];
  }

  final mappedName = _commonOffsetMappings[offsetMinutes];
  if (mappedName != null) {
    try {
      final loc = getLocation(mappedName);
      _offsetLocationCache[offsetMinutes] = loc;

      return loc;
    } catch (_) {
      // Continue to fallback
    }
  }

  // Fallback: search all locations (more expensive)
  try {
    for (final name in timeZoneDatabase.locations.keys) {
      final loc = getLocation(name);
      if (loc.currentTimeZone.offset == offset.inMilliseconds) {
        _offsetLocationCache[offsetMinutes] = loc;

        return loc;
      }
    }
  } catch (_) {
    // Database not available
  }

  return null;
}

/// Regex pattern for YYYY/MM/DD format.
/// Allows loose matching for separator options but enforces strict
/// year/month/day structure.
final _slashYMDPattern = RegExp(r'^(\d{4})[./-](\d{1,2})[./-](\d{1,2})(.*)$');

/// Attempts to normalize common date formats to ISO 8601.
///
/// Returns null if normalization is not possible or input is too complex.
String? _tryNormalizeFormat(String input) {
  // Limit input length to prevent ReDoS attacks and processing of
  // unreasonably large strings
  if (input.length > 50) {
    return null;
  }

  // Pattern: YYYY/MM/DD or YYYY/MM/DD HH:MM:SS
  // Adjusts to allow dot and dash separators in this fallback logic too
  // for consistency
  final slashMatch = _slashYMDPattern.firstMatch(input);
  if (slashMatch != null) {
    final year = slashMatch.group(1)!;
    final month = slashMatch.group(2)!.padLeft(2, '0');
    final day = slashMatch.group(3)!.padLeft(2, '0');
    final time = slashMatch.group(4)?.trim() ?? '';

    // Validate logical ranges to fail early on obvious nonsense
    if (int.parse(month) > 12 || int.parse(day) > 31) {
      return null;
    }

    if (time.isEmpty) {
      return '$year-$month-$day';
    }

    // Handle time part: " 10:30:00" -> "T10:30:00"
    // If it already has T, leave it. If it has space, replace with T.
    final timeNormalized = time.startsWith('T') ? time : 'T${time.trim()}';

    return '$year-$month-$day$timeNormalized';
  }

  return null;
}
