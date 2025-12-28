# easy_date_time - GitHub Copilot Custom Instructions

## Package Identity

**easy_date_time** is a timezone-aware DateTime package for Dart that serves as a **drop-in replacement** for `DateTime` with full IANA timezone support.

**Core Principles**: Consistency > Innovation | Minimal API Surface | Type Safety | Immutability

### Package Scope

> **Extensibility Note**: This scope can expand based on community needs. Propose new features with use cases and implementation impact analysis.

| In Scope ✅ | Out of Scope ❌ (Currently) |
|------------|-----------------------------|
| IANA timezone support (timezone package wrapper) | Localized month names, regional formats → recommend `intl` |
| Time value preservation (parsing without implicit conversion) | Relative time expressions ("5 years ago") → recommend `jiffy` |
| Fixed-format output (ISO dates, timestamps, simple display) | 60+ locale support |
| DST-aware time arithmetic | Mutable API design |

---

## Technical Background

### Environment Requirements

- **Dart SDK**: `>=3.0.0 <4.0.0`
- **Dependencies**: `timezone: >=0.9.4 <0.11.0`
- **Platforms**: VM, Web, AOT (all Dart platforms)

### Static Analysis Configuration

The project enforces strict analysis:
- `strict-casts: true`
- `strict-inference: true`
- `strict-raw-types: true`
- `missing_return: error`
- `avoid-dynamic` (DCM rule)

All code must pass: `dart analyze --fatal-infos`

### Architecture

```
lib/
├── easy_date_time.dart          # Public API exports only
└── src/                         # Internal implementation
    ├── easy_date_time.dart      # Core class
    ├── easy_date_time_config.dart
    ├── easy_date_time_init.dart
    ├── date_time_unit.dart
    ├── exceptions/
    ├── extensions/
    │   ├── date_time_extension.dart
    │   └── duration_extension.dart
    └── timezones.dart
```

**Module Guidelines**:
- Only `lib/easy_date_time.dart` exports public APIs
- Internal implementation uses `_` prefix or `part of`
- No circular dependencies

> **Architecture Evolution**: New modules can be added for distinct feature areas. Discuss structural changes before implementation.

---

## Package Relationship Guidelines

> **Note**: These guidelines reflect current design decisions. They can evolve through discussion—if you identify a compelling reason to deviate, propose the change with clear rationale.

### 1. DateTime (Official API) - Consistency Preferred

| Guideline | Description |
|------------|-------------|
| **Naming Match** | Method names must match DateTime: `toUtc()`, `toLocal()`, `isBefore()`, `isAtSameMomentAs()` |
| **Semantic Match** | Same-named methods must behave identically unless explicitly documented |
| **Version Compatibility** | Check `@Since` annotations before using new DateTime APIs (SDK ≥3.0.0) |
| **Property Alignment** | `year`, `month`, `day`, `weekday` use identical value ranges |

### 2. timezone (Underlying Dependency) - Compatibility Preferred

| Constraint | Description |
|------------|-------------|
| **Transparent Wrapper** | `Location` type is directly exposed |
| **API Re-export** | `getLocation()` and core APIs are re-exported |
| **Interoperability** | `EasyDateTime.fromDateTime()` accepts `TZDateTime` |
| **Init Alignment** | `initializeTimeZone()` internally calls `tz.initializeTimeZones()` |

### 3. time (Duration Extensions) - Consistency Preferred

| Constraint | Description |
|------------|-------------|
| **Syntax Match** | Same naming: `1.days`, `2.hours`, `30.minutes` |
| **Conflict Handling** | Document `hide DurationExtension` solution |
| **No Duplication** | Don't add features already in time package (`fromNow`, `ago`, `delay`) |

### 4. intl (Localization) - Clear Boundary Recommended

| Constraint | Description |
|------------|-------------|
| **No Replacement** | Localized formats → recommend intl |
| **Composable** | `EasyDateTime.toDateTime()` works with `DateFormat` |
| **Separation** | `EasyDateTimeFormatter` only handles fixed tokens, no locale |

### 5. jiffy (Competitor) - Differentiation Reference

> **Competitive Landscape**: This comparison reflects current positioning. Market analysis may reveal new opportunities.

| Feature | jiffy | easy_date_time | Note |
|---------|-------|----------------|------|
| Timezone Support | ❌ | ✅ IANA full support | **Core Differentiator** |
| Immutability | ❌ Mutable | ✅ Immutable | Better for state management |
| Localization | ✅ 60+ locales | ❌ | Not a current target |
| Relative Time | ✅ "5 years ago" | ❌ | Not a current target |

---

## Code Generation Guidelines

### Critical Behaviors

1. **Initialization Required**
   ```dart
   void main() {
     EasyDateTime.initializeTimeZone();  // MUST call before any usage
     runApp(MyApp());
   }
   ```

2. **Parsing Behavior - Preservation vs Normalization**
   ```dart
   // DateTime: normalizes to UTC (hour changes!)
   DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2

   // EasyDateTime: preserves original values
   EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10
   ```

3. **Timezone Handling**
   ```dart
   // ✅ Preferred: Use TimeZones constants
   EasyDateTime.now(location: TimeZones.tokyo);

   // ✅ Valid: Use getLocation for custom zones
   EasyDateTime.now(location: getLocation('Africa/Nairobi'));

   // ✅ Timezone conversion
   final tokyo = dt.inLocation(TimeZones.tokyo);
   final utc = dt.toUtc();
   ```

4. **Month Overflow Handling**
   ```dart
   final jan31 = EasyDateTime.utc(2025, 1, 31);

   // ⚠️ Standard overflow (may exceed month boundary)
   jan31.copyWith(month: 2);        // → Mar 3rd

   // ✅ Safe clamping (stays within month)
   jan31.copyWithClamped(month: 2); // → Feb 28
   ```

5. **Equality Semantics**
   ```dart
   final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
   final local = EasyDateTime.parse('2025-01-01T08:00:00+08:00');

   utc == local;                  // false (different timezone type)
   utc.isAtSameMomentAs(local);   // true (same absolute instant)
   ```

   | Method | Compares | Use Case |
   |--------|----------|----------|
   | `==` | Moment + timezone type (UTC/non-UTC) | Exact equality |
   | `isAtSameMomentAs()` | Absolute instant only | Cross-timezone comparison |
   | `isBefore()` / `isAfter()` | Chronological order | Sorting, range checks |

   ⚠️ **Warning**: Avoid mixing `EasyDateTime` and `DateTime` in the same `Set` or `Map` (different `hashCode` implementations).

### API Design Conventions

| Pattern | Example | Meaning |
|---------|---------|---------|
| `tryXxx()` | `tryParse()` | Returns nullable |
| `xxx()` | `parse()` | Throws exception |
| `toXxx()` | `toUtc()` | Conversion |
| `fromXxx()` | `fromDateTime()` | Factory constructor |
| `isXxx` / `hasXxx` | `isUtc` | Boolean property |

### Formatting

```dart
// Simple usage
dt.format('yyyy-MM-dd');           // '2025-12-01'
dt.format(DateTimeFormats.isoDate); // '2025-12-01'

// ✅ Performance: Pre-compile for hot paths
static final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');
formatter.format(date);

// For locale-aware formatting, recommend intl:
import 'package:intl/intl.dart';
DateFormat.yMMMMd('ja').format(dt);  // '2025年12月20日'
```

---

## Code Review & Audit Requirements

### Security & Safety Checks

1. **DST Boundary Testing Required**
   - Spring Forward (2:00→3:00 gap): Time in gap behavior
   - Fall Back (1:00-2:00 overlap): Ambiguous time handling

2. **Input Validation**
   - Use `tryParse()` for user input or untrusted sources
   - Only valid IANA timezone offsets are supported

3. **No Hidden Global State**
   - Default location is explicit (`setDefaultLocation()` / `clearDefaultLocation()`)
   - All instances are immutable

### Code Quality Baseline

> **Standards Evolution**: These thresholds represent current targets. They may be adjusted based on project maturity and community feedback.

| Requirement | Current Standard |
|-------------|------------------|
| Line Coverage | ≥ 95% |
| Static Analysis | Zero issues with `--fatal-infos` |
| Boundary Tests | Extreme years, DST, pre-epoch |
| Exception Tests | All error paths covered |

### Style Requirements

- Single quotes for strings
- Named parameters preferred
- `const` for compile-time constants
- Explicit types for public APIs (no `var`, no inferred types)
- Max 6 parameters; use Options object pattern if exceeded
- No boolean trap; use named parameters or enums

### Documentation Requirements

- 100% public APIs have `///` doc comments with code examples
- Exception behavior documented in method comments
- Use `{@template}` / `{@macro}` to reduce duplication
- Update CHANGELOG.md for user-facing changes
- Sync multilingual READMEs (README.md, README_zh.md, README_ja.md)

---

## Testing Structure

> **Test Organization**: This structure supports current needs. New test categories can be added for emerging requirements (e.g., performance benchmarks, integration tests).

| File Pattern | Purpose |
|--------------|---------|
| `<feature>_test.dart` | Feature unit tests |
| `boundary_tests.dart` | DST/boundary value tests |
| `negative_tests.dart` | Exception path tests |
| `user_scenarios_test.dart` | End-to-end scenarios |

### Verification Commands

```bash
dart format .                    # Format code
dart analyze --fatal-infos       # Static analysis
dart test                        # Run all tests
dart pub publish --dry-run       # Pre-publish validation
```

---

## Documentation Standards

### Anti-Patterns (Avoid)

- ❌ Marketing fluff: "Ultra-fast", "Revolutionary", "Best-in-class"
- ❌ Vague adjectives: "Amazing", "Incredible", "Easy to use"
- ❌ Translation artifacts: overly literal translations
- ❌ Restating the obvious

### Best Practices

- ✅ **Show, don't tell**: Use code examples instead of descriptions
- ✅ **Active voice**: "Parses input..." not "Input is parsed..."
- ✅ **Precise terminology**: Instants, Offsets, Zones
- ✅ **Fact-based**: No claims without supporting data

### Benchmark References

| Project | Learn From |
|---------|------------|
| [Luxon](https://moment.github.io/luxon/) | Clear "Why" explanation, DateTime comparison |
| [Flutter Docs](https://docs.flutter.dev/) | Code snippet completeness, copy-paste runnable |
| [date-fns](https://date-fns.org/) | Modularity, lightweight feel |
| [Noda Time](https://nodatime.org/) | Rigor on DST, edge case warnings |
| [Stripe API Docs](https://stripe.com/docs/api) | Concept + Code one-liner format |

---

## Commit Convention

```
<type>(<scope>): <subject>
```

| Type | Usage |
|------|-------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation change |
| `test` | Test change |
| `refactor` | Refactoring |
| `perf` | Performance optimization |

---

## Change Control Policy

> **Purpose**: Ensure stability and consistency while remaining open to evolution.

The following changes require explicit discussion and approval:
- Adding/modifying/removing any public API
- Adding new dependencies or modifying config files
- Any backward-incompatible changes

**Proposed Approach**: "I noticed X might be needed because [reason]. Should I add it?"

> **Note**: This policy aims to protect users from breaking changes, not to prevent innovation. Well-reasoned proposals with clear benefits are welcome.
