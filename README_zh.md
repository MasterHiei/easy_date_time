# easy_date_time

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md) | [日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)

支持 IANA 时区的 `DateTime` 替代方案。
在解析带时区的字符串时，保留原始的时间值与时区信息，并且实现了 `DateTime` 接口。

~~~dart
// DateTime 会自动转换为 UTC，导致小时值发生改变
DateTime.parse('2026-01-18T10:30:00+08:00').hour // 2

// EasyDateTime 保留原始的小时与时区
EasyDateTime.parse('2026-01-18T10:30:00+08:00').hour // 10
~~~

## 开始使用

### 安装依赖

将以下内容添加到你的 `pubspec.yaml` 文件中：

~~~yaml
dependencies:
  easy_date_time: ^0.11.0
~~~

### 初始化

**注意**：在使用前，必须初始化时区数据库：

~~~dart
void main() {
  // 必须在使用任何功能前调用一次
  EasyDateTime.initializeTimeZone();
  runApp(MyApp());
}
~~~

## 使用指南

创建实例并解析带时区的时间：

~~~dart
// 使用预定义的时区常量
final now = EasyDateTime.now(location: TimeZones.tokyo);

// 解析字符串，同时保留其时区上下文
final parsed = EasyDateTime.parse('2026-01-18T10:30:00+08:00');

print(parsed.hour);         // 10
print(parsed.locationName); // Asia/Shanghai
~~~

使用 `Duration` 扩展进行日期运算：

~~~dart
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
~~~

使用模式字符串进行格式化：

~~~dart
const pattern = 'yyyy-MM-dd HH:mm';
print(dt.format(pattern)); // 2026-01-18 10:30
~~~

## 功能特性

### 时区支持

支持三种方式指定时区：

~~~dart
// 1. 使用 TimeZones 常量（推荐）
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);

// 2. 使用标准 IANA 时区名称
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));

// 3. 设置全局默认时区
EasyDateTime.setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now(); // 默认使用 Asia/Shanghai
~~~

无缝进行时区转换：

~~~dart
final newYork = tokyo.inLocation(TimeZones.newYork);
// 检查物理时间是否为同一时刻
print(tokyo.isAtSameMomentAs(newYork)); // true
~~~

### 日期运算

借助 `Duration` 扩展，代码更简洁：

~~~dart
now + 1.days
now - 2.hours
now + 30.minutes + 15.seconds
~~~

**DST (夏令时) 安全计算**

在涉及夏令时切换的日期进行加减运算时，`addCalendarDays` 会保留"墙上时间"（Wall Time，即钟表时间），而普通加法则遵循物理时间。

~~~dart
// 纽约夏令时切换日（2025年3月9日，当天时钟会拨快一小时）
final dt = EasyDateTime(2025, 3, 9, 0, 0, location: newYork);

dt.addCalendarDays(1);     // 2025-03-10 00:00 (保留钟表指向)
dt.add(Duration(days: 1)); // 2025-03-10 01:00 (物理时间增加24小时)
~~~

便捷属性：

~~~dart
dt.tomorrow    // 下一个日历日
dt.yesterday   // 上一个日历日
dt.dateOnly    // 除去时间部分，保留日期 (00:00:00)
~~~

**月份溢出处理**

当月份变化导致日期无效时（如 1 月 31 日变成 2 月），提供两种处理策略：

~~~dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // 3月3日 (标准的自动溢出)
jan31.copyWithClamped(month: 2); // 2月28日 (智能截断到当月最后一天)
~~~

**时间单位边界计算**

快速获取时间周期的起始与结束点：

~~~dart
dt.startOf(DateTimeUnit.day);   // 当天 00:00:00
dt.startOf(DateTimeUnit.week);  // 本周一 00:00:00 (遵循 ISO 8601 标准)
dt.startOf(DateTimeUnit.month); // 当月 1 日 00:00:00
dt.endOf(DateTimeUnit.month);   // 当月最后一天 23:59:59.999
~~~

### 日期属性

常用计算属性：

- `dayOfYear` — 一年中的第几天 (1-366)
- `weekOfYear` — ISO 8601 周数 (1-53)
- `quarter` — 季度 (1-4)
- `daysInMonth` — 当月总天数 (28-31)
- `isLeapYear` — 是否为闰年

状态判断：

- `isToday`, `isTomorrow`, `isYesterday`
- `isThisWeek`, `isThisMonth`, `isThisYear`
- `isWeekend` (周六日), `isWeekday` (周一至周五)
- `isPast` (过去), `isFuture` (未来)
- `isDst` — 当前是否处于夏令时

### 日期格式化

使用 `format()` 配合占位符进行格式化：

~~~dart
dt.format('yyyy-MM-dd');    // 2026-01-18
dt.format('HH:mm:ss');      // 14:30:45
dt.format('hh:mm a');       // 02:30 PM (12小时制)
~~~

或使用预定义常量：

~~~dart
dt.format(DateTimeFormats.isoDate);      // 2026-01-18
dt.format(DateTimeFormats.isoDateTime);  // 2026-01-18T14:30:45
dt.format(DateTimeFormats.rfc2822);      // Sun, 18 Jan 2026 14:30:45 +0800
~~~

> **性能提示**：在循环或高频场景中使用时，建议预编译 `EasyDateTimeFormatter` 以复用实例，提升性能。

~~~dart
static final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');
String result = formatter.format(dt);
~~~

| 符号 | 说明 | 示例 |
|------|------|------|
| `yyyy` | 4位年份 | 2025 |
| `MM` / `M` | 月份 | 01 / 1 |
| `dd` / `d` | 日期 | 07 / 7 |
| `HH` / `H` | 24小时 | 09 / 9 |
| `hh` / `h` | 12小时 | 02 / 2 |
| `mm` / `m` | 分钟 | 05 / 5 |
| `ss` / `s` | 秒 | 05 / 5 |
| `SSS` | 毫秒 | 123 |
| `a` | 上下午 | AM / PM |
| `EEE` | 星期缩写 | Mon |
| `MMM` | 月份缩写 | Dec |
| `xxxxx` | 时区偏移 | +08:00 |
| `X` | ISO时区 | Z / +0800 |

### 国际化 (intl)

`EasyDateTime` 实现了 `DateTime` 接口，可以直接与官方 `intl` 包配合使用：

~~~dart
import 'package:intl/intl.dart';

// 输出：2025年12月7日
DateFormat.yMMMMd('zh_CN').format(dt);
// 输出：December 7, 2025
DateFormat.yMMMMd('en_US').format(dt);
~~~

### JSON 序列化

提供适配 `json_serializable` 和 `freezed` 的自定义 `JsonConverter`：

~~~dart
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}
~~~

在 freezed 中使用示例：

~~~dart
@freezed
class Event with _$Event {
  const factory Event({
    @EasyDateTimeConverter() required EasyDateTime startTime,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
~~~

## 注意事项

**判等逻辑 (`==`)**
我们遵循 Dart `DateTime` 的语义。
- `==` 比较绝对时间值 **和** 时区信息 (Location)。
- `isAtSameMomentAs` 仅比较绝对时间值（是否为同一瞬间）。

~~~dart
final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
final local = EasyDateTime.parse('2026-01-18T08:00:00+08:00'); // UTC+8

// false — 因为时区类型不同 (UTC vs Local)
print(utc == local);

// true — 因为处于同一时刻（只是所处时区不同）
print(utc.isAtSameMomentAs(local));
~~~

> **重要**：请勿将 `EasyDateTime` 和 `DateTime` 放入同一个 `Set` 或作为 `Map` 的 key，因为它们的 `hashCode` 实现存在区别。

**自动修正与严格模式**
默认情况下，无效的日历日期会自动溢出（顺延修正）：

~~~dart
// 2月30日不存在，自动顺延推算为3月2日
EasyDateTime(2025, 2, 30); // -> 2025-03-02
~~~

如需强制进行严格验证并拒绝无效日期，请使用 `strict` 参数：

~~~dart
// 对无效日期抛出 FormatException
EasyDateTime.parse('2025-02-30', strict: true);

// 对无效日期返回 null
EasyDateTime.tryParse('2025-02-30', strict: true);
~~~


**安全解析**
处理用户输入时，强烈建议使用 `tryParse` 以提升应用的健壮性：

~~~dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  // 处理格式错误
}
~~~

**解决扩展名冲突**
如 `1.days` 等便捷扩展与其他库（如 `time`）冲突，请隐藏对应的扩展方法：

~~~dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
~~~

## 贡献

欢迎提交 Issue 和 PR。详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

BSD 2-Clause
