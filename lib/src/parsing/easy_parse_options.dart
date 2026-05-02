/// Parsing behavior modes for [EasyDateTime] string parsing.
enum EasyParseMode {
  /// Preserve the legacy parsing behavior.
  legacy,

  /// Preserve the current permissive parsing behavior.
  compatible,

  /// Apply strict ISO parsing rules.
  isoStrict,
}

/// How timezone offsets should be resolved during parsing.
enum OffsetResolution {
  /// Resolve offsets to a matching fixed IANA location when possible.
  fixed,

  /// Preserve or resolve offsets using region-based behavior.
  region,
}

/// Configures how [EasyDateTime] parsing should behave.
final class EasyParseOptions {
  /// Creates parsing options.
  const EasyParseOptions({
    this.mode = EasyParseMode.compatible,
    this.offsetResolution = OffsetResolution.fixed,
  });

  /// Parsing mode to use.
  final EasyParseMode mode;

  /// How timezone offsets should be resolved.
  final OffsetResolution offsetResolution;
}
