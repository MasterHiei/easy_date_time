import 'package:meta/meta.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart';

// Helper functions for internal use.

/// Cached initialization status to avoid repeated checks.
bool? _timeZoneInitialized;

/// Initializes the IANA timezone database.
@internal
void internalInitializeTimeZone() {
  tz.initializeTimeZones();
  _timeZoneInitialized = true;
}

/// Checks if the timezone database has been initialized.
///
/// Uses caching to avoid repeated `getLocation` calls after first check.
@internal
bool get internalIsTimeZoneInitialized {
  if (_timeZoneInitialized == true) return true;
  try {
    getLocation('UTC');
    _timeZoneInitialized = true;

    return true;
  } catch (_) {
    return false;
  }
}
