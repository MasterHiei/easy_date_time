import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

/// Initializes the IANA timezone database.
///
/// **Must be called before using [EasyDateTime].**
///
/// Call once at app startup:
/// ```dart
/// void main() {
///   initializeTimeZone();
///   runApp(MyApp());
/// }
/// ```
void initializeTimeZone() {
  tz.initializeTimeZones();
}

/// Checks if the IANA timezone database has been initialized.
///
/// Returns `true` if [initializeTimeZone] has been called successfully.
bool get isTimeZoneInitialized {
  try {
    getLocation('UTC');

    return true;
  } catch (_) {
    return false;
  }
}
