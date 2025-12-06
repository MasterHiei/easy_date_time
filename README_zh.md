# easy_date_time

**支持时区的 Dart DateTime 库**

基于 `timezone` 包构建的简洁时区处理方案。

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)

**[English](README.md)** | **[日本語](README_ja.md)**

---

## 核心特性

- 🌍 **任意时区支持**: 除 UTC/Local 外，支持所有 IANA 时区 (如 `Asia/Shanghai`)。
- 🕒 **直观易用**: 解析 `"10:00+08:00"` 得到的是 **10:00**，而不是转换后的 UTC 时间。
- 🛠️ **开发友好**: 提供直观的运算符 (`now + 1.days`) 和标准的 JSON 序列化支持。

## 快速开始

```yaml
dependencies:
  easy_date_time: ^0.1.0
```

```dart
import 'package:easy_date_time/easy_date_time.dart';

void main() {
  // 1. 初始化 (基础设施)
  initializeTimeZone();

  // 2. 配置默认值 (可选)
  // 如果不设置，默认从 System 获取本地时区
  setDefaultLocation(TimeZones.shanghai);

  final now = EasyDateTime.now();  // 使用默认配置 (上海时间)
  print(now);
}
```

---

## 指定时区

### 方式 1: 使用 `TimeZones` 快捷方式 (推荐)

```dart
// 常用时区可直接访问
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
final newYork = EasyDateTime.now(location: TimeZones.newYork);

// 可用: tokyo, shanghai, beijing, hongKong, singapore,
// newYork, losAngeles, chicago, london, paris, berlin,
// sydney, auckland, moscow, dubai, mumbai 等...
```

### 方式 2: 使用 `getLocation()` 获取任意 IANA 时区

```dart
// TimeZones 中没有的时区
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
final denver = EasyDateTime.now(location: getLocation('America/Denver'));

// 完整列表: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
```

### 方式 3: 设置全局默认时区

```dart
// 设置一次，后续操作自动使用
setDefaultLocation(TimeZones.shanghai);

final now = EasyDateTime.now();  // 上海时间
final dt = EasyDateTime(2025, 12, 25, 10, 30);  // 也是上海时间
```

---

## 解析时间字符串

**保留原始时间值** - 不做自动转换:

```dart
// 解析带时区偏移的 API 响应
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');
print(dt.hour);  // 10 (不是 2!)
print(dt.locationName);  // Asia/Shanghai

// 解析 UTC 时间
final utc = EasyDateTime.parse('2025-12-07T10:30:00Z');
print(utc.hour);  // 10
print(utc.locationName);  // UTC

// 显式转换 (仅当你主动请求时)
final inNY = EasyDateTime.parse(
  '2025-12-07T10:30:00Z',
  location: TimeZones.newYork,
);
print(inNY.hour);  // 5 (10 UTC → 5 纽约)
```

---

## 时区转换

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);

// 转换到另一个时区
final newYork = tokyo.inLocation(TimeZones.newYork);

// 转换到 UTC
final utc = tokyo.inUtc();

// 同一时刻，不同显示
print(tokyo.isAtSameMoment(newYork));  // true
```

---

## 日期运算

```dart
final now = EasyDateTime.now();

// 使用运算符加减
final tomorrow = now + 1.days;
final lastWeek = now - 1.weeks;
final later = now + 2.hours + 30.minutes;

// 比较
if (tomorrow > now) {
  print('未来');
}

// 计算差值
final duration = tomorrow.difference(now);
```

---

## JSON 序列化

兼容 json_serializable 和 freezed:

```dart
// 手动转换
final json = dt.toJson();  // "2025-12-25T10:30:00.000+0900"
final restored = EasyDateTime.fromJson(json);

// 配合 freezed/json_serializable - 定义自定义转换器:
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromJson(json);

  @override
  String toJson(EasyDateTime object) => object.toJson();
}

// 在模型中使用:
@freezed
class Event with _$Event {
  const factory Event({
    @EasyDateTimeConverter() required EasyDateTime startTime,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
```

完整示例见 [example/lib/integrations/](example/lib/integrations/)。



## API 参考

### 构造函数

| 构造函数 | 说明 |
|---------|------|
| `EasyDateTime(year, month, day, ...)` | 从各参数创建 |
| `EasyDateTime.now()` | 当前时间 |
| `EasyDateTime.utc(...)` | 创建 UTC 时间 |
| `EasyDateTime.parse(string)` | 解析 ISO 8601 |
| `EasyDateTime.fromJson(string)` | 从 JSON 解析 |

### 时区方法

| 方法 | 说明 |
|------|------|
| `inLocation(location)` | 转换到指定时区 |
| `inUtc()` | 转换到 UTC |
| `inLocalTime()` | 转换到系统本地时区 |

### 日期工具

| 属性/方法 | 说明 |
|----------|------|
| `isToday` | 是否今天 |
| `isTomorrow` | 是否明天 |
| `isYesterday` | 是否昨天 |
| `startOfDay` | 当天 00:00:00 |
| `endOfDay` | 当天 23:59:59 |
| `startOfMonth` | 月初第一天 |
| `endOfMonth` | 月末最后一天 |

---

## 许可证

BSD 2-Clause License
