# EasyDateTime Examples

Runnable package examples. CI analyzes all examples and runs the default
`main.dart` entry point.

## Setup

~~~bash
cd example
dart pub get
~~~

Generated sources for the Freezed and Retrofit examples are committed. Regenerate
them only after changing their annotated models:
~~~bash
dart run build_runner build
~~~

## Directory Structure

```
lib/
├── core/           # Core usage (no code generation)
└── integrations/   # Third-party integrations
```

## Default Example

pub.dev displays [`main.dart`](main.dart) as the package's default example:

~~~bash
dart run main.dart
~~~

## Core Examples

No code generation needed. Run directly:

| File | Description |
|------|-------------|
| [basic_usage.dart](lib/core/basic_usage.dart) | Initialization, creation |
| [timezone_specify.dart](lib/core/timezone_specify.dart) | Three ways to specify timezone |
| [parsing.dart](lib/core/parsing.dart) | Parsing with value preservation |
| [timezone_convert.dart](lib/core/timezone_convert.dart) | Timezone conversion |
| [arithmetic.dart](lib/core/arithmetic.dart) | Date arithmetic |
| [date_utils.dart](lib/core/date_utils.dart) | isToday, startOfDay, startOf/endOf |
| [datetime_compatibility.dart](lib/core/datetime_compatibility.dart) | DateTime interface compatibility |
| [json_serialization.dart](lib/core/json_serialization.dart) | JSON serialization |
| [formatting.dart](lib/core/formatting.dart) | Output formats using format() and DateTimeFormats |
| [formatter_example.dart](lib/core/formatter_example.dart) | Pre-compiled formatter for performance |
| [copywith.dart](lib/core/copywith.dart) | Creating modified copies |
| [error_handling.dart](lib/core/error_handling.dart) | Safe parsing, validation |

~~~bash
dart run lib/core/basic_usage.dart
~~~

## Integration Examples

| File | Description |
|------|-------------|
| [intl_example.dart](lib/integrations/intl_example.dart) | Locale-aware formatting with intl |
| [freezed_example.dart](lib/integrations/freezed_example.dart) | Freezed + json_serializable |
| [dio_example.dart](lib/integrations/dio_example.dart) | Dio HTTP client |
| [retrofit_example.dart](lib/integrations/retrofit_example.dart) | Retrofit type-safe API |

~~~bash
dart run lib/integrations/freezed_example.dart
~~~

## Custom JsonConverter

EasyDateTime works with json_serializable via custom converters.
See [freezed_example.dart](lib/integrations/freezed_example.dart) for the converter template:

~~~dart
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}
~~~
