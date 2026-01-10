# easy_date_time

**Dart 时区感知日期时间库：全面支持 IANA 时区，提供直观的日期时间运算与灵活的格式化能力**

基于 IANA 时区数据库，提供精准的全球时区支持。**不可变（Immutable）**、日期时间运算直观且格式化灵活。解决原生 `DateTime` 隐式转换 UTC/本地时间导致的语义丢失问题，让跨时区开发精准可控。

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)


**[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md)** | **[日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)**

---

## 为什么选择 easy_date_time？

Dart 的 `DateTime` 仅支持 UTC 和本地时区。本库添加完整的 IANA 时区支持，可作为 `DateTime` 的直接替代方案。

### 与其他日期时间包对比

| 功能 | `DateTime` | `timezone` | `easy_date_time` |
|------|:----------:|:----------:|:----------------:|
| **IANA 时区** | ❌ | ✅ | ✅ |
| **不可变性（Immutable）** | ✅ | ✅ | ✅ |
| **API 接口** | 原生 | `extends DateTime` | `implements DateTime` |
| **时区查找** | N/A | 手动 (`getLocation`) | 常量 / 自动缓存 |

### API 设计对比

**`timezone` 包:**
```dart
import 'package:timezone/timezone.dart' as tz;
// 需要手动查找时区对象
final detroit = tz.getLocation('America/Detroit');
final now = tz.TZDateTime.now(detroit);
```

**`easy_date_time`:**
```dart
// 使用静态常量或缓存查找
final now = EasyDateTime.now(location: TimeZones.detroit);
```

### DateTime vs EasyDateTime

```dart
// DateTime: 偏移 → UTC (小时改变)
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2

// EasyDateTime: 保留小时
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10
```

| 特性 | DateTime | EasyDateTime |
|---|----------|--------------|
| **时区支持** | UTC / 系统本地 | IANA 数据库 |
| **解析行为** | **归一化** (转为 UTC) | **保持** (保留偏移/小时) |
| **类型关系** | 基类 | `implements DateTime` |
| **混合使用** | N/A | ⚠️ `hashCode` 不同，避免混用 |

---

## 主要特性

### 🌍 完整的 IANA 时区支持
支持所有标准 IANA 时区常量或自定义字符串。
```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
```

### 🕒 无损解析
拒绝隐式转换，完整保留解析时的日期时间值与时区信息。
```dart
EasyDateTime.parse('2025-12-07T10:00+08:00').hour // -> 10
```

### ➕ 直观的日期时间运算
符合直觉的时间计算语法。
```dart
final later = now + 2.hours + 30.minutes;
```

### 🧱 安全的日期计算
自动处理月份溢出等边界情况。
```dart
jan31.copyWithClamped(month: 2); // -> 2月28日
```

### 📝 灵活的日期时间格式化
支持自定义模式与预编译优化。
```dart
dt.format('yyyy-MM-dd'); // -> 2025-12-07
```

---

## 安装与初始化

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  easy_date_time: ^0.8.0
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

## 时区处理

解析时，EasyDateTime 完整保留原始时间值与时区信息：

```dart
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(dt.hour);          // 10 (保留原值，不转换为 UTC)
print(dt.locationName);  // Asia/Shanghai
```

### 时区转换

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final newYork = tokyo.inLocation(TimeZones.newYork);
final utc = tokyo.toUtc();

tokyo.isAtSameMomentAs(newYork);  // true：表示相同的绝对时刻
```

---

## 日期时间运算

```dart
final now = EasyDateTime.now();
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
```

### 日历天运算（夏令时安全）

对于需要保持时间不变的日期操作（在夏令时切换时尤为重要）：

```dart
final dt = EasyDateTime(2025, 3, 9, 0, 0, location: newYork); // 夏令时切换日

dt.addCalendarDays(1);       // 2025-03-10 00:00 ✓ (时间不变)
dt.add(Duration(days: 1));   // 2025-03-10 01:00   (24小时后，时间偏移)
```

`tomorrow` 和 `yesterday` 同样使用日历天语义：

```dart
dt.tomorrow;   // 等价于 addCalendarDays(1)
dt.yesterday;  // 等价于 subtractCalendarDays(1)
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

### 日期属性

常用的日期判断与计算属性：

~~~dart
final dt = EasyDateTime(2024, 6, 15);

// 年度相关
dt.dayOfYear;    // 167（一年中的第几天）
dt.weekOfYear;   // 24（一年中的第几周，遵循 ISO 8601）
dt.quarter;      // 2（第几季度）
dt.isLeapYear;   // true（是否为闰年）

// 月份相关
dt.daysInMonth;  // 30（当月共有多少天）

// 周末判断
final saturday = EasyDateTime(2025, 1, 4);
saturday.isWeekend;  // true（是否为周末）
saturday.isWeekday;  // false（是否为工作日）

// 时间查询
final past = EasyDateTime(2020, 1, 1);
past.isPast;       // true（是否已过去）
past.isFuture;     // false（是否在未来）

final now = EasyDateTime.now();
now.isThisWeek;    // true（是否在本周）
now.isThisMonth;   // true（是否在本月）
now.isThisYear;    // true（是否在今年）

// 夏令时检测
final nyJuly = EasyDateTime(2025, 7, 15, location: TimeZones.newYork);
nyJuly.isDst;      // true（夏令时生效）
~~~

| 属性 | 说明 | 取值范围 |
|------|------|----------|
| `dayOfYear` | 一年中的第几天 | 1-366 |
| `weekOfYear` | 一年中的第几周（ISO 8601） | 1-53 |
| `quarter` | 第几季度 | 1-4 |
| `daysInMonth` | 当月天数 | 28/29/30/31 |
| `isLeapYear` | 是否为闰年 | true/false |
| `isWeekend` | 是否为周末（周六、周日） | true/false |
| `isWeekday` | 是否为工作日（周一至周五） | true/false |
| `isPast` | 是否已过去 | true/false |
| `isFuture` | 是否在未来 | true/false |
| `isThisWeek` | 是否在本周 | true/false |
| `isThisMonth` | 是否在本月 | true/false |
| `isThisYear` | 是否在今年 | true/false |
| `isDst` | 夏令时是否生效 | true/false |

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
| `a` | 上午/下午 | AM, PM |
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

> [!WARNING]
> **避免在同一 `Set` 或 `Map` 中混用 `EasyDateTime` 和 `DateTime`**。
> 虽然 `==` 可跨类型工作，但 `hashCode` 实现不同。

### 其他说明

* 只有有效的 IANA 时区偏移才能被正确解析，非标准偏移将抛出异常。
* 请务必调用 `EasyDateTime.initializeTimeZone()` 进行初始化。

### DateTime 行为

EasyDateTime 继承了 Dart `DateTime` 的某些行为：

**无效日期自动进位**：构造无效日期时会自动进位到下一个有效日期：
```dart
EasyDateTime(2025, 2, 30);  // → 2025-03-02 (2月没有30日)
EasyDateTime(2025, 2, 29);  // → 2025-03-01 (2025年非闰年)
```

> 关于夏令时感知的日期运算，请参阅[日历天运算](#日历天运算夏令时安全)。

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
