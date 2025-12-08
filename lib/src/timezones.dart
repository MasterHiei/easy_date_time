import 'package:timezone/timezone.dart';

import 'easy_date_time_init.dart';
import 'exceptions/exceptions.dart';

/// Convenient access to common timezone locations.
///
/// This class provides easy access to frequently used timezones without
/// needing to remember IANA timezone names. All properties are lazy-loaded,
/// meaning the timezone database must be initialized before use.
///
/// **Maintenance Note:** This class contains a curated list of the most common
/// timezones. It is NOT exhaustive. If a timezone is missing, users should use
/// `getLocation('Area/Location')`. Adding new static getters here should be
/// reserved for widely used zones to avoid bloating the API.
///
/// ## Usage
///
/// ```dart
/// // Initialize timezone database first
/// initializeTimeZone();
///
/// // Access common timezones easily
/// final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
/// final newYork = EasyDateTime.now(location: TimeZones.newYork);
///
/// // Convert between timezones
/// final nyTime = shanghai.inLocation(TimeZones.newYork);
/// // Shanghai 20:00 (UTC+8) = New York 07:00 (UTC-5)
/// ```
///
/// ## Organization
///
/// Timezones are organized by UTC offset from west (UTC-10) to east (UTC+13):
/// - Americas: [honolulu] (UTC-10), [losAngeles] (UTC-8), [newYork] (UTC-5)
/// - Europe: [london] (UTC+0), [paris] (UTC+1), [moscow] (UTC+3)
/// - Asia: [dubai] (UTC+4), [mumbai] (UTC+5:30), [shanghai] (UTC+8), [tokyo] (UTC+9)
/// - Pacific: [sydney] (UTC+10), [auckland] (UTC+12)
///
/// ## Extensibility
///
/// For timezones not listed here, use [getLocation] directly:
///
/// ```dart
/// final nairobi = getLocation('Africa/Nairobi');
/// ```
abstract final class TimeZones {
  // Prevent instantiation
  TimeZones._();

  // ============================================================
  // UTC (Reference Point)
  // ============================================================

  /// Universal Coordinated Time (UTC±0).
  ///
  /// The reference point for all timezones. No daylight saving time.
  static Location get utc => _getSafeLocation('UTC');

  // ============================================================
  // UTC-10 to UTC-8 (Pacific / West Coast)
  // ============================================================

  /// Honolulu, Hawaii, USA (UTC-10).
  ///
  /// Hawaii-Aleutian Standard Time (HST). No daylight saving time.
  static Location get honolulu => _getSafeLocation('Pacific/Honolulu');

  /// Los Angeles, California, USA (UTC-8 / UTC-7 DST).
  ///
  /// Pacific Time (PT). Observes daylight saving time.
  static Location get losAngeles => _getSafeLocation('America/Los_Angeles');

  /// Vancouver, Canada (UTC-8 / UTC-7 DST).
  ///
  /// Pacific Time (PT). Observes daylight saving time.
  static Location get vancouver => _getSafeLocation('America/Vancouver');

  // ============================================================
  // UTC-7 to UTC-6 (Mountain / Central)
  // ============================================================

  /// Denver, Colorado, USA (UTC-7 / UTC-6 DST).
  ///
  /// Mountain Time (MT). Observes daylight saving time.
  static Location get denver => _getSafeLocation('America/Denver');

  /// Chicago, Illinois, USA (UTC-6 / UTC-5 DST).
  ///
  /// Central Time (CT). Observes daylight saving time.
  static Location get chicago => _getSafeLocation('America/Chicago');

  /// Mexico City, Mexico (UTC-6).
  ///
  /// Central Time (CT). No daylight saving time (abolished in 2022).
  static Location get mexicoCity => _getSafeLocation('America/Mexico_City');

  // ============================================================
  // UTC-5 to UTC-3 (Eastern Americas)
  // ============================================================

  /// New York, USA (UTC-5 / UTC-4 DST).
  ///
  /// Eastern Time (ET). Observes daylight saving time.
  static Location get newYork => _getSafeLocation('America/New_York');

  /// Toronto, Canada (UTC-5 / UTC-4 DST).
  ///
  /// Eastern Time (ET). Observes daylight saving time.
  static Location get toronto => _getSafeLocation('America/Toronto');

  /// São Paulo, Brazil (UTC-3).
  ///
  /// Brasília Time (BRT). No longer observes DST since 2019.
  static Location get saoPaulo => _getSafeLocation('America/Sao_Paulo');

  // ============================================================
  // UTC±0 (Western Europe / Africa)
  // ============================================================

  /// London, United Kingdom (UTC+0 / UTC+1 DST).
  ///
  /// Greenwich Mean Time (GMT) / British Summer Time (BST).
  /// Observes daylight saving time.
  static Location get london => _getSafeLocation('Europe/London');

  // ============================================================
  // UTC+1 (Central Europe)
  // ============================================================

  /// Paris, France (UTC+1 / UTC+2 DST).
  ///
  /// Central European Time (CET). Observes daylight saving time.
  static Location get paris => _getSafeLocation('Europe/Paris');

  /// Berlin, Germany (UTC+1 / UTC+2 DST).
  ///
  /// Central European Time (CET). Observes daylight saving time.
  static Location get berlin => _getSafeLocation('Europe/Berlin');

  /// Amsterdam, Netherlands (UTC+1 / UTC+2 DST).
  ///
  /// Central European Time (CET). Observes daylight saving time.
  static Location get amsterdam => _getSafeLocation('Europe/Amsterdam');

  /// Zurich, Switzerland (UTC+1 / UTC+2 DST).
  ///
  /// Central European Time (CET). Observes daylight saving time.
  static Location get zurich => _getSafeLocation('Europe/Zurich');

  /// Madrid, Spain (UTC+1 / UTC+2 DST).
  ///
  /// Central European Time (CET). Observes daylight saving time.
  static Location get madrid => _getSafeLocation('Europe/Madrid');

  /// Rome, Italy (UTC+1 / UTC+2 DST).
  ///
  /// Central European Time (CET). Observes daylight saving time.
  static Location get rome => _getSafeLocation('Europe/Rome');

  // ============================================================
  // UTC+2 to UTC+3 (Eastern Europe / Middle East / Africa)
  // ============================================================

  /// Cairo, Egypt (UTC+2).
  ///
  /// Eastern European Time (EET). No daylight saving time since 2014.
  static Location get cairo => _getSafeLocation('Africa/Cairo');

  /// Johannesburg, South Africa (UTC+2).
  ///
  /// South Africa Standard Time (SAST). No daylight saving time.
  static Location get johannesburg => _getSafeLocation('Africa/Johannesburg');

  /// Jerusalem, Israel (UTC+2 / UTC+3 DST).
  ///
  /// Israel Standard Time (IST). Observes daylight saving time.
  static Location get jerusalem => _getSafeLocation('Asia/Jerusalem');

  /// Moscow, Russia (UTC+3).
  ///
  /// Moscow Standard Time (MSK). No daylight saving time.
  static Location get moscow => _getSafeLocation('Europe/Moscow');

  // ============================================================
  // UTC+4 to UTC+5:30 (Middle East / South Asia)
  // ============================================================

  /// Dubai, UAE (UTC+4).
  ///
  /// Gulf Standard Time (GST). No daylight saving time.
  static Location get dubai => _getSafeLocation('Asia/Dubai');

  /// Mumbai, India (UTC+5:30).
  ///
  /// Indian Standard Time (IST). No daylight saving time.
  /// Note: India uses a half-hour offset.
  static Location get mumbai => _getSafeLocation('Asia/Kolkata');

  // ============================================================
  // UTC+7 (Southeast Asia)
  // ============================================================

  /// Bangkok, Thailand (UTC+7).
  ///
  /// Indochina Time (ICT). No daylight saving time.
  static Location get bangkok => _getSafeLocation('Asia/Bangkok');

  /// Jakarta, Indonesia (UTC+7).
  ///
  /// Western Indonesia Time (WIB). No daylight saving time.
  static Location get jakarta => _getSafeLocation('Asia/Jakarta');

  // ============================================================
  // UTC+8 (East Asia)
  // ============================================================

  /// Singapore (UTC+8).
  ///
  /// Singapore Standard Time (SST). No daylight saving time.
  static Location get singapore => _getSafeLocation('Asia/Singapore');

  /// Hong Kong (UTC+8).
  ///
  /// Hong Kong Time (HKT). No daylight saving time.
  static Location get hongKong => _getSafeLocation('Asia/Hong_Kong');

  /// Shanghai, China (UTC+8).
  ///
  /// China Standard Time (CST). No daylight saving time.
  static Location get shanghai => _getSafeLocation('Asia/Shanghai');

  /// Beijing, China (UTC+8).
  ///
  /// Same as [shanghai] - China uses a single timezone nationwide.
  static Location get beijing => _getSafeLocation('Asia/Shanghai');

  // ============================================================
  // UTC+9 (East Asia)
  // ============================================================

  /// Tokyo, Japan (UTC+9).
  ///
  /// Japan Standard Time (JST). No daylight saving time.
  static Location get tokyo => _getSafeLocation('Asia/Tokyo');

  /// Seoul, South Korea (UTC+9).
  ///
  /// Korea Standard Time (KST). No daylight saving time.
  static Location get seoul => _getSafeLocation('Asia/Seoul');

  // ============================================================
  // UTC+10 to UTC+13 (Oceania)
  // ============================================================

  /// Sydney, Australia (UTC+10 / UTC+11 DST).
  ///
  /// Australian Eastern Standard Time (AEST).
  /// Observes daylight saving time (October to April).
  static Location get sydney => _getSafeLocation('Australia/Sydney');

  /// Melbourne, Australia (UTC+10 / UTC+11 DST).
  ///
  /// Australian Eastern Standard Time (AEST).
  /// Observes daylight saving time (October to April).
  static Location get melbourne => _getSafeLocation('Australia/Melbourne');

  /// Auckland, New Zealand (UTC+12 / UTC+13 DST).
  ///
  /// New Zealand Standard Time (NZST).
  /// Observes daylight saving time (September to April).
  static Location get auckland => _getSafeLocation('Pacific/Auckland');

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Gets all available timezone names from the database.
  ///
  /// Returns a list of all IANA timezone identifiers.
  /// Requires [initializeTimeZone] to be called first.
  ///
  /// ```dart
  /// final allZones = TimeZones.availableTimezones;
  /// print('Available: ${allZones.length} timezones');
  /// ```
  static List<String> get availableTimezones =>
      timeZoneDatabase.locations.keys.toList();

  /// Checks if a timezone name is valid.
  ///
  /// ```dart
  /// TimeZones.isValid('Asia/Tokyo'); // true
  /// TimeZones.isValid('Invalid/Zone'); // false
  /// ```
  static bool isValid(String timezoneName) {
    if (!isTimeZoneInitialized) {
      throw TimeZoneNotInitializedException(
        'Timezone database not initialized. '
        'Call initializeTimeZone() before calling TimeZones.isValid().',
      );
    }

    try {
      getLocation(timezoneName);

      return true;
    } on LocationNotFoundException {
      return false;
    }
  }

  /// Gets a timezone by name, returning null if not found.
  ///
  /// This is a null-safe alternative to [getLocation].
  ///
  /// ```dart
  /// final location = TimeZones.tryGet('Asia/Tokyo');
  /// if (location != null) {
  ///   // Use location
  /// }
  /// ```
  static Location? tryGet(String timezoneName) {
    if (!isTimeZoneInitialized) {
      throw TimeZoneNotInitializedException(
        'Timezone database not initialized. '
        'Call initializeTimeZone() before calling TimeZones.tryGet().',
      );
    }

    try {
      return getLocation(timezoneName);
    } on LocationNotFoundException {
      return null;
    }
  }

  /// Safe wrapper for [getLocation] that provides clear error messages.
  ///
  /// Throws [TimeZoneNotInitializedException] if database not initialized.
  /// Throws [InvalidTimeZoneException] if location name is invalid.
  static Location _getSafeLocation(String locationName) {
    // Check initialization first for clear error message
    if (!isTimeZoneInitialized) {
      throw TimeZoneNotInitializedException(
        'Timezone database not initialized. '
        'Call initializeTimeZone() before accessing TimeZones.$locationName.',
      );
    }

    try {
      return getLocation(locationName);
    } on LocationNotFoundException {
      throw InvalidTimeZoneException(
        timeZoneId: locationName,
        message: 'Timezone "$locationName" not found in IANA database.',
      );
    }
  }
}
