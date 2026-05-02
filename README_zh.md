# easy_date_time

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md) | [日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)

一个兼容 `DateTime` API 的时区增强库，支持 IANA 时区与可控解析策略。

## 为什么使用 easy_date_time

`DateTime.parse()` 会把带偏移输入归一化为 UTC，常导致小时值变化。
`EasyDateTime.parse()` 会保留原始本地时间语义。

```dart
DateTime.parse('2026-01-18T10:30:00+08:00').hour;   // 2
EasyDateTime.parse('2026-01-18T10:30:00+08:00').hour; // 10
```

## 快速开始

### 1) 添加依赖

```yaml
dependencies:
  easy_date_time: ^0.12.0
```

### 2) 初始化时区数据库（只需一次）

```dart
import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();
}
```

### 3) 解析与转换

```dart
final source = EasyDateTime.parse('2026-01-18T10:30:00+08:00');
final ny = source.inLocation(TimeZones.newYork);

print(source.hour);         // 10
print(source.locationName); // UTC+08:00（fixed 模式默认）
print(ny.locationName);     // America/New_York
```

## 核心概念

- `EasyDateTime` 实现了 `DateTime` 接口。
- 解析策略通过 `EasyParseOptions` 显式控制。
- 显式传入 options 时，默认是 `compatible + fixed`。
- 为平滑迁移保留了 legacy 无 options 路径。

```dart
final dt = EasyDateTime.parse(
  '2026-01-18T10:30:00+08:00',
  options: const EasyParseOptions(
    mode: EasyParseMode.compatible,
    offsetResolution: OffsetResolution.fixed,
  ),
);
```

## 常见任务

### 构造带时区时间

```dart
final nowInTokyo = EasyDateTime.now(location: TimeZones.tokyo);
final meeting = EasyDateTime(2026, 5, 3, 9, 30, location: TimeZones.london);
```

### DST 安全的日历运算

```dart
final ny = TimeZones.newYork;
final beforeDst = EasyDateTime(2025, 3, 9, 0, 0, location: ny);

final wallClock = beforeDst.addCalendarDays(1); // 2025-03-10 00:00
final physical = beforeDst.add(const Duration(days: 1)); // 2025-03-10 01:00
```

### 格式化

```dart
final formatted = EasyDateTime.now(location: TimeZones.tokyo)
    .format('yyyy-MM-dd HH:mm:ss xxxxx');
```

## 迁移指南（v0.12）

完整文档见：[docs/migration/v0_12_migration_guide.md](docs/migration/v0_12_migration_guide.md)

### `strict` 迁移到 `options`

- `strict: false` -> `EasyParseOptions(mode: EasyParseMode.compatible)`
- `strict: true` -> `EasyParseOptions(mode: EasyParseMode.isoStrict)`

### Offset 解析行为

- 兼容/legacy 路径：按偏移推断区域时区（`OffsetResolution.region`）
- 显式新路径：固定偏移位置（`OffsetResolution.fixed`，例如 `UTC+08:00`）

## DateTime / timezone API 对照

| 现有 API | easy_date_time |
|---|---|
| `DateTime.now()` | `EasyDateTime.now()` |
| `DateTime.utc(...)` | `EasyDateTime.utc(...)` |
| `DateTime.parse(String)` | `EasyDateTime.parse(String, options: ...)` |
| `DateTime.tryParse(String)` | `EasyDateTime.tryParse(String, options: ...)` |
| `DateTime.fromMillisecondsSinceEpoch(ms)` | `EasyDateTime.fromMillisecondsSinceEpoch(ms)` |
| `DateTime.toUtc()` | `EasyDateTime.toUtc()` |
| `DateTime.toLocal()` | `EasyDateTime.toLocal()` |
| `DateTime` 无 IANA Location 模型 | `inLocation(TimeZones.xxx)` |
| 无 | `setDefaultLocation(...)` / `clearDefaultLocation()` |

## FAQ

### 能与 `intl` 一起使用吗？

可以。`EasyDateTime` 实现了 `DateTime`，可直接传给现有 `intl` 格式化器。

### 默认是否严格校验？

不是。需要严格校验时请使用 `EasyParseMode.isoStrict`。

### 是否必须初始化时区数据？

是。使用时区相关能力前必须先调用 `EasyDateTime.initializeTimeZone()`。
