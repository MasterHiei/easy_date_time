# easy_date_time

**Dart 时间处理工具：支持任意时区、保持原始时间、解析和运算更直观**

基于成熟的 `timezone` 包，提供简单、可控的时间和时区处理方式，让你不用再为 UTC 转换和跨时区显示头疼。

[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)

---

## 为什么选择 easy_date_time？

Dart 内置 `DateTime` 和其他方案在实际开发中都存在一些痛点：

| Package                 | 优点             | 限制                                     | easy_date_time 优势                            |
| ----------------------- | ---------------- | ---------------------------------------- | ---------------------------------------------- |
| DateTime（Dart 内置）   | 简单、零依赖     | 只支持本地或 UTC，解析带时区字符串会自动转换 | 保留原始时间，可自由指定时区，解析和显示更直观 |
| timezone                | 精准 IANA 时区支持 | API 较复杂.                      | 封装简单，常用时区直接可用，调用更方便         |
| intl                    | 国际化和格式化功能强 | 时区处理能力有限                         | 时间和时区分开管理，操作更清晰                 |
| flutter_native_timezone | 获取设备时区方便   | 不提供时间解析和运算功能                 | 提供完整解析、加减和时区转换能力               |

> 简单说：**EasyDateTime 让 Dart 的时间处理更可靠、易用，也更适合跨时区场景。**

**与标准 DateTime 的对比：**

```dart
// DateTime：偏移量解析成功，但时间被转成了 UTC
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2 😕

// EasyDateTime：解析什么就是什么
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10 ✓
```

---

## EasyDateTime 的主要特点

* 🌍 **支持完整时区**
  所有 IANA 时区均可使用（如 Asia/Shanghai、America/New_York），API 简单易用

* 🕒 **解析时间保持原样**
  输入的时间不会被自动转换

* ➕ **直观的时间加减**
  支持 `now + 1.days`、`2.hours` 等自然写法

* 🔄 **显式的时区转换**
  只有调用 `.inLocation()` 或 `.toUtc()` 时才会转换

* 🧱 **安全的日期修改**
  `copyWithClamped()` 可防止月份溢出

---

## 安装与初始化

在 `pubspec.yaml` 添加依赖：

```yaml
dependencies:
  easy_date_time: ^0.2.0
```

应用启动时初始化一次时区数据库：

```dart
void main() {
  initializeTimeZone();  // 必须初始化一次

  // 可选：设置默认时区
  setDefaultLocation(TimeZones.shanghai);

  runApp(MyApp());
}
```

---

## 快速示例

```dart
final now = EasyDateTime.now();  // 全局默认时区 or 本地时区
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final parsed = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(parsed.hour);  // 10
```

---

## 使用时区

### 1）常用时区（推荐）

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
```

### 2）任意 IANA 时区

```dart
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
```

### 3）全局默认时区

```dart
setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now(); // 默认使用上海时间
```

---

## 保留原始时间

```dart
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(dt.hour);          // 10
print(dt.locationName);  // Asia/Shanghai
```

显式转换：

```dart
final ny = dt.inLocation(TimeZones.newYork);
final utc = dt.toUtc();
```

---

## 时区转换示例

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final newYork = tokyo.inLocation(TimeZones.newYork);

print(tokyo.isAtSameMomentAs(newYork)); // true：同一时刻
```

---

## 日期运算

```dart
final now = EasyDateTime.now();
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
```

### 防止月份溢出

```dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // 3月3日（超出范围）
jan31.copyWithClamped(month: 2); // 2月28日
```

```

---

## 扩展冲突处理

为了保证开发体验，本包内置了 `int` 扩展（如 `1.days`）。如果与其他包发生冲突，请考虑隐藏该扩展：

```dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
```

---

## JSON 与序列化

`json_serializable` / `freezed` 可直接使用自定义转换器：

```dart
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}
```

---

## 注意事项

* `==` 判断的是时间是否代表 **同一瞬间**
* 非 IANA 的时区偏移会报错
* 必须先调用 `initializeTimeZone()`

### 安全解析用户输入

```dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  print('日期格式不正确');
}
```

---

## 贡献

欢迎提交 Issue 或 PR。
请参考 `CONTRIBUTING.md` 了解贡献流程。

---

## License

BSD 2-Clause
