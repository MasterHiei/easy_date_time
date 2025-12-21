# easy_date_time

**Dart 时区感知日期库：精准支持 IANA 时区，提供直观的日期运算与灵活的格式化能力**

基于 IANA 数据库，提供精准的全球时区支持。**不可变**、算术直观且格式化灵活。解决原生 `DateTime` 隐式转换 UTC/本地时间导致的语义丢失问题，让跨时区开发精准可控。

[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)

**[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md)** | **[日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)**

---

## 为什么选择 easy_date_time？

在处理复杂时区业务时，Dart 内置的 `DateTime` 及现有第三方库通常面临以下挑战：

| 方案 | 特点 | 本库处理方式 |
|------|------|-------------|
| **DateTime** | 解析偏移后隐式转换为 UTC | 保留原始时间值 |
| **timezone** | 需手动调用 `getLocation()` | 提供 `TimeZones.tokyo` 等常量 |
| **intl** | 专注格式化输出 | 可配合使用 |
| **jiffy** | 可变对象设计 | 不可变，实现 DateTime 接口 |

**对比示例：**

```dart
// ❌ Native DateTime: 隐式转换 UTC/本地时间，丢失时区信息
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2

// ✅ EasyDateTime: 完整保留解析时的小时与偏移量
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10
```

---

## 主要特性

### 🌍 全量 IANA 时区支持
支持所有标准 IANA 时区常量或自定义字符串。
```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
```

### 🕒 精准无损解析
拒绝隐式转换。完整保留解析时的数值与时区。
```dart
EasyDateTime.parse('2025-12-07T10:00+08:00').hour // -> 10
```

### ➕ 自然语言运算
符合直觉的时间计算语法。
```dart
final later = now + 2.hours + 30.minutes;
```

### 🧱 智能安全计算
自动处理月份溢出等边界情况。
```dart
jan31.copyWithClamped(month: 2); // -> 2月28日
```

### 📝 高性能灵活格式化
支持自定义模式与预编译优化。
```dart
dt.format('yyyy-MM-dd'); // -> 2025-12-07
```

---

## 安装与初始化

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  easy_date_time: ^0.4.1
```

**注意**：为了确保时区计算准确，**必须**在应用启动前初始化时区数据库：

```dart
void main() {
  EasyDateTime.initializeTimeZone();  // 必须调用

  // 可选：设置全局默认时区
  EasyDateTime.setDefaultLocation(TimeZones.shanghai);

  runApp(MyApp());
}
```

> [!NOTE]
> 全局函数 `initializeTimeZone()` 和 `setDefaultLocation()` 已**废弃**。
> 请改用 `EasyDateTime.initializeTimeZone()` 和 `EasyDateTime.setDefaultLocation()`。

---

## 快速开始

```dart
final now = EasyDateTime.now();  // 使用默认或本地时区
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final parsed = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(parsed.hour);  // 10
```

---

## 时区使用指南

### 1. 常用时区（推荐）
直接使用内置的常用时区常量：

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
```

### 2. 指定 IANA 时区
通过标准字符串获取时区：

```dart
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
```

### 3. 设置全局默认时区
设置全局默认值后，`EasyDateTime.now()` 将自动适配该时区：

```dart
EasyDateTime.setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now(); // 此时为 Asia/Shanghai 时间
```

---

## 保持原始时间语义

即使解析带偏移量的字符串，EasyDateTime 也会完整保留原始数值与时区信息：

```dart
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(dt.hour);          // 10
print(dt.locationName);  // Asia/Shanghai
```

如需转换，请显式调用转换方法：

```dart
final ny = dt.inLocation(TimeZones.newYork); // 转换为纽约时间
final utc = dt.toUtc(); // 转换为 UTC
```

---

## 时区转换示例

比较不同时区的同一瞬间：

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final newYork = tokyo.inLocation(TimeZones.newYork);

print(tokyo.isAtSameMomentAs(newYork)); // true：表示绝对时间（Instant）相同
```

---

## 日期时间运算

```dart
final now = EasyDateTime.now();
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
```

### 月份溢出处理
自动处理月份大小时的日期截断逻辑：

```dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // ⚠️ 3月3日 (常规溢出)
jan31.copyWithClamped(month: 2); // ✅ 2月28日 (自动修正为当月最后一天)
```

### 时间单位边界

截取或扩展到时间单位的边界：

```dart
final dt = EasyDateTime(2025, 6, 18, 14, 30, 45); // 周三

dt.startOf(DateTimeUnit.day);   // 2025-06-18 00:00:00
dt.startOf(DateTimeUnit.week);  // 2025-06-16 00:00:00 (周一)
dt.startOf(DateTimeUnit.month); // 2025-06-01 00:00:00

dt.endOf(DateTimeUnit.day);     // 2025-06-18 23:59:59.999999
dt.endOf(DateTimeUnit.week);    // 2025-06-22 23:59:59.999999 (周日)
dt.endOf(DateTimeUnit.month);   // 2025-06-30 23:59:59.999999
```

> 周边界遵循 ISO 8601 标准（周一为每周第一天）。

---

## 与 intl 集成

如需本地化格式（如 "January" → "一月"），可配合 `intl` 使用：

```dart
import 'package:intl/intl.dart';
import 'package:easy_date_time/easy_date_time.dart';

final dt = EasyDateTime.now(location: TimeZones.tokyo);

// 通过 intl 进行本地化格式化
DateFormat.yMMMMd('zh').format(dt);  // '2025年12月20日'
DateFormat.yMMMMd('en').format(dt);  // 'December 20, 2025'
```

> **说明**: `EasyDateTime` 实现了 `DateTime` 接口，可直接用于 `DateFormat.format()`。

---

## 日期格式化

使用 `format()` 方法进行灵活的日期时间格式化：

```dart
final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);

dt.format('yyyy-MM-dd');           // '2025-12-01'
dt.format('yyyy/MM/dd HH:mm:ss');  // '2025/12/01 14:30:45'
dt.format('MM/dd/yyyy');           // '12/01/2025'
dt.format('hh:mm a');              // '02:30 PM'
```

> [!TIP]
> **性能优化**: 在循环等被频繁执行的代码中，考虑预编译 `EasyDateTimeFormatter` 以提高性能：
> ```dart
> // 编译一次即可多次复用
> static final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');
> String result = formatter.format(date);
> ```

### 预设格式常量

使用 `DateTimeFormats` 获取常用格式：

```dart
dt.format(DateTimeFormats.isoDate);      // '2025-12-01'
dt.format(DateTimeFormats.isoTime);      // '14:30:45'
dt.format(DateTimeFormats.isoDateTime);  // '2025-12-01T14:30:45'
dt.format(DateTimeFormats.time12Hour);   // '02:30 PM'
dt.format(DateTimeFormats.time24Hour);   // '14:30'
dt.format(DateTimeFormats.rfc2822);      // 'Mon, 01 Dec 2025 14:30:45 +0800'
```

### 格式符号表

| 符号 | 说明 | 示例 |
|------|------|------|
| `yyyy` | 4位年份 | 2025 |
| `MM`/`M` | 月份（补零/不补零） | 01, 1 |
| `MMM` | 月份缩写 | Jan, Dec |
| `dd`/`d` | 日期（补零/不补零） | 01, 1 |
| `EEE` | 星期缩写 | Mon, Sun |
| `HH`/`H` | 24小时制（补零/不补零） | 09, 9 |
| `hh`/`h` | 12小时制（补零/不补零） | 02, 2 |
| `mm`/`m` | 分钟（补零/不补零） | 05, 5 |
| `ss`/`s` | 秒（补零/不补零） | 05, 5 |
| `SSS` | 毫秒 | 123 |
| `a` | 上午/下午标识 | AM, PM |
| `xxxxx` | 带冒号的时区偏移 | +08:00, -05:00 |
| `xxxx` | 时区偏移 | +0800, -0500 |
| `xx` | 短时区偏移 | +08, -05 |
| `X` | UTC为Z，否则偏移 | Z, +0800 |

---

## 扩展方法冲突处理

本库为 `int` 类型提供了语义化扩展（如 `1.days`）。若与其他库（如 GetX）冲突，可使用 `hide` 隐藏：

```dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
```

---

## JSON 序列化支持

通过注册自定义转换器，无缝适配 `json_serializable` 或 `freezed`：

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

### 相等性比较

`EasyDateTime` 遵循 Dart `DateTime` 的相等性语义：

```dart
final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
final local = EasyDateTime.parse('2025-01-01T08:00:00+08:00');

// 同一时刻，不同时区类型（UTC vs 非 UTC）
utc == local;                  // false
utc.isAtSameMomentAs(local);   // true
```

| 方法 | 比较内容 | 使用场景 |
|------|----------|----------|
| `==` | 时刻 + 时区类型（UTC/非 UTC） | 完全相等 |
| `isAtSameMomentAs()` | 仅绝对时刻 | 跨时区比较 |
| `isBefore()` / `isAfter()` | 时间顺序 | 排序、范围检查 |

### 其他说明

* 只有有效的 IANA 时区偏移才能被正确解析，非标准偏移将抛出异常。
* 请务必调用 `EasyDateTime.initializeTimeZone()` 进行初始化。

### 安全解析

对于不确定的用户输入，建议使用 `tryParse`：

```dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  print('日期格式无效');
}
```

---

## 贡献

欢迎提交 Issue 或 Pull Request。
贡献指南请参阅 [CONTRIBUTING.md](CONTRIBUTING.md)。

---

## 许可

BSD 2-Clause
