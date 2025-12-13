import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

/// Initializes the IANA timezone database.
///
/// **Deprecated**: Use [EasyDateTime.initializeTimeZone] instead.
///
/// **Must be called before using [EasyDateTime].**
///
/// Call once at app startup:
/// ```dart
/// void main() {
///   EasyDateTime.initializeTimeZone();
///   runApp(MyApp());
/// }
/// ```
@Deprecated(
  'Use EasyDateTime.initializeTimeZone() instead. '
  'This function will be removed in v0.4.0.',
)
void initializeTimeZone() {
  tz.initializeTimeZones();
}

/// Checks if the IANA timezone database has been initialized.
///
/// **Deprecated**: Use [EasyDateTime.isTimeZoneInitialized] instead.
///
/// Returns `true` if [initializeTimeZone] has been called successfully.
@Deprecated(
  'Use EasyDateTime.isTimeZoneInitialized instead. '
  'This getter will be removed in v0.4.0.',
)
bool get isTimeZoneInitialized {
  try {
    getLocation('UTC');

    return true;
  } catch (_) {
    return false;
  }
}

// ============================================================
// Internal API for EasyDateTime static methods
// ============================================================
// These functions are used by EasyDateTime's static methods to avoid
// triggering deprecation warnings internally.

/// Internal: Initializes the IANA timezone database.
void internalInitializeTimeZone() {
  tz.initializeTimeZones();
}

/// Internal: Checks if the timezone database has been initialized.
bool get internalIsTimeZoneInitialized {
  try {
    getLocation('UTC');

    return true;
  } catch (_) {
    return false;
  }
}
