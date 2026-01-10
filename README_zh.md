# easy_date_time

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md) | [日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)

支持 IANA 时区的 `DateTime` 替代方案。解析带时区字符串时保留原始时间值，实现 `DateTime` 接口，易于迁移。

~~~dart
// DateTime 自动转换为 UTC，改变小时值
DateTime.parse('2025-12-07T10:30:00+08:00').hour // 2

// EasyDateTime 保留原值
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour // 10
~~~

## 开始使用

### 添加依赖

将以下内容添加到你的 `pubspec.yaml`：

~~~yaml
dependencies:
  easy_date_time: ^0.9.0
~~~

### 初始化

在使用前，你必须初始化时区数据库：

~~~dart
void main() {
  // 必须在使用前调用一次
  EasyDateTime.initializeTimeZone();
  runApp(MyApp());
}
~~~

## 使用

创建实例并解析带时区的时间：

~~~dart
// 使用预定义的时区常量
final now = EasyDateTime.now(location: TimeZones.tokyo);

// 解析字符串，保留时区信息
final parsed = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(parsed.hour);         // 10
print(parsed.locationName); // Asia/Shanghai
~~~

使用 `Duration` 扩展进行自然的日期运算：

~~~dart
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
~~~

使用模式字符串进行格式化：

~~~dart
const pattern = 'yyyy-MM-dd HH:mm';
print(dt.format(pattern)); // 2025-12-07 10:30
~~~

## 功能特性

### 时区支持

你可以通过三种方式指定时区：

~~~dart
// 1. 使用 TimeZones 常量
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);

// 2. 使用标准 IANA 时区名称
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));

// 3. 设置全局默认时区
EasyDateTime.setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now(); // 默认使用 Asia/Shanghai
~~~

在不同时区之间转换：

~~~dart
final newYork = tokyo.inLocation(TimeZones.newYork);
// 检查是否为同一时刻
print(tokyo.isAtSameMomentAs(newYork)); // true
~~~

### 日期运算

借助 `Duration` 扩展，代码更具可读性：

~~~dart
now + 1.days
now - 2.hours
now + 30.minutes + 15.seconds
~~~

**夏令时（DST）安全计算**：
在对涉及夏令时切换的日期进行加、减等算术运算时，`addCalendarDays` 会保留"实际时间"（Wall Time）。

~~~dart
// 纽约夏令时切换日（2025年3月9日，当天只有 23 小时）
final dt = EasyDateTime(2025, 3, 9, 0, 0, location: newYork);

dt.addCalendarDays(1);     // 2025-03-10 00:00 (保留时刻)
dt.add(Duration(days: 1)); // 2025-03-10 01:00 (物理时间增加 24 小时)
~~~

便捷 Getter：

~~~dart
dt.tomorrow    // 下一个日历日
dt.yesterday   // 上一个日历日
dt.dateOnly    // 仅保留日期部分 (00:00:00)
~~~

**安全处理月份溢出**：
月份变化导致日期无效时（如 2 月 30 日），可选两种策略：

~~~dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // 3月3日 (自动溢出)
jan31.copyWithClamped(month: 2); // 2月28日 (截断到当月最后一天)
~~~

**快速计算边界时间**：

~~~dart
dt.startOf(DateTimeUnit.day);   // 当天 00:00:00
dt.startOf(DateTimeUnit.week);  // 本周一 00:00:00 (遵循 ISO 8601 标准)
dt.startOf(DateTimeUnit.month); // 当月 1 日 00:00:00
dt.endOf(DateTimeUnit.month);   // 当月最后一天 23:59:59.999999
~~~

### 日期属性

常用计算属性：

- `dayOfYear` — 一年中的第几天 (1-366)
- `weekOfYear` — ISO 8601 周数 (1-53)
- `quarter` — 季度 (1-4)
- `daysInMonth` — 当月总天数 (28-31)
- `isLeapYear` — 是否为闰年

状态判断：

- `isToday`、`isTomorrow`、`isYesterday`
- `isThisWeek`、`isThisMonth`、`isThisYear`
- `isWeekend` (周六日)、`isWeekday` (周一至周五)
- `isPast`、`isFuture`
- `isDst` — 当前是否处于夏令时

### 日期格式化

使用 `format()` 配合占位符进行格式化。

~~~dart
dt.format('yyyy-MM-dd');    // 2025-12-07
dt.format('HH:mm:ss');      // 14:30:45
dt.format('hh:mm a');       // 02:30 PM (12小时制)
~~~

或使用预定义常量：

~~~dart
dt.format(DateTimeFormats.isoDate);      // 2025-12-07
dt.format(DateTimeFormats.isoDateTime);  // 2025-12-07T14:30:45
dt.format(DateTimeFormats.rfc2822);      // Mon, 07 Dec 2025 14:30:45 +0800
~~~

> **性能提示**：在循环中使用时，建议预编译 `EasyDateTimeFormatter` 以节约消耗，提升性能。

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

`EasyDateTime` 实现了 `DateTime` 接口，可以直接与 `intl` 包配合使用：

~~~dart
import 'package:intl/intl.dart';

// 输出：2025年12月7日
DateFormat.yMMMMd('zh_CN').format(dt);
// 输出：December 7, 2025
DateFormat.yMMMMd('en_US').format(dt);
~~~

### JSON 序列化

支持 `json_serializable` 和 `freezed` 的自定义 `JsonConverter`：

~~~dart
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}
~~~

在 freezed 中使用：

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

**相等性 (`==`)**：
遵循 Dart `DateTime` 语义。

~~~dart
final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
final local = EasyDateTime.parse('2025-01-01T08:00:00+08:00'); // UTC+8

// false — 因为时区类型不同 (UTC vs Local)
print(utc == local);

// true — 因为处于同一时刻（只是所处时区不同）
print(utc.isAtSameMomentAs(local));
~~~

> **重要**：请勿将 `EasyDateTime` 和 `DateTime` 放入同一个 `Set` 或作为 `Map` 的 key，因为它们的 `hashCode` 实现存在区别。

**无效日期自动推算**：
构造函数会自动处理日期溢出。

~~~dart
EasyDateTime(2025, 2, 30); // 自动变为 2025-03-02
~~~

**用户输入解析**：
建议处理输入时使用 `tryParse` 以提升运行时的安全性。

~~~dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  // 处理格式错误
}
~~~

**解决扩展名冲突**：
例如 `1.days` 等便捷扩展与其他库（如 `time`）冲突，请隐藏对应的扩展方法：

~~~dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
~~~

## 贡献

欢迎提交 Issue 和 PR。详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

BSD 2-Clause
