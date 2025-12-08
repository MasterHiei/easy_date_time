# easy_date_time

**Dart 原生风格时间库：支持 IANA 时区、保留原始时间值、直观的解析与运算**

基于 IANA 数据库实现的精准时区支持，旨在解决原生 `DateTime` 强制转换 UTC/本地时间的问题，使跨时区开发更加准确、可控。

[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)

**[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md)** | **[日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)**

---

## 为什么选择 easy_date_time？

在处理复杂时区业务时，Dart 内置的 `DateTime` 及现有第三方库通常面临以下挑战：

| 方案 | 优势 | 局限性 | easy_date_time 的改进 |
| --- | --- | --- | --- |
| **DateTime** (原生) | 官方库，零依赖 | 强制转换为 UTC 或本地时间，**丢失时区信息** | **保留语义**：解析时保留完整的时区偏移，不进行隐式转换 |
| **timezone** | 完整的 IANA 实现 | API 较为复杂，需手动查找时区代码 | **易用性**：提供常用时区常量，简化调用 |
| **intl** | 强大的格式化功能 | 侧重展示，缺乏时间计算能力 | **职责分离**：专注于时间的计算与表达，展示层可配合 intl 使用 |
| **flutter_native_timezone** | 获取系统时区 | 仅具备获取功能，无法计算 | **功能闭环**：提供解析、计算、转换的一站式解决方案 |

**对比示例：**

```dart
// Native DateTime: 解析偏移量后会强制转换为 UTC，导致小时数改变
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2 (语义丢失)

// EasyDateTime: 保持解析时的原始数值
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10 (符合预期)
```

---

## 主要特性

* 🌍 **完整的时区支持**
  内置所有 IANA 时区数据（如 Asia/Shanghai, America/New_York），调用简便。

* 🕒 **所见即所得的解析**
  保留时间字符串的原始数值，不进行隐式 UTC 转换。

* ➕ **直观的时间运算**
  支持 `now + 1.days`、`2.hours` 等自然语言风格的计算扩展。

* 🔄 **显式的时区转换**
  仅在调用 `.inLocation()` 或 `.toUtc()` 时进行时区转换，避免意外变更。

* 🧱 **安全的日期推演**
  自动处理月末日期的边界情况（例如：1月31日 + 1个月 -> 2月28日），无需手动处理溢出。

---

## 安装与初始化

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  easy_date_time: ^0.2.0
```

**注意**：为了确保时区计算准确，**必须**在应用启动前初始化时区数据库：

```dart
void main() {
  initializeTimeZone();  // 必须调用

  // 可选：设置全局默认时区
  setDefaultLocation(TimeZones.shanghai);

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

### 1）常用时区（推荐）
库中内置了常见时区常量，可以直接使用：

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
```

### 2）指定 IANA 时区
支持通过标准字符串获取时区：

```dart
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
```

### 3）设置全局默认时区
设置后，`EasyDateTime.now()` 将默认使用该时区：

```dart
setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now(); // 此时为 Asia/Shanghai 时间
```

---

## 保持原始时间语义

即便输入带有偏移量的时间字符串，EasyDateTime 也会同时记录其字面量时间与时区位置：

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

jan31.copyWith(month: 2);        // 3月3日 (常规逻辑溢出)
jan31.copyWithClamped(month: 2); // 2月28日 (自动修正为当月最后一天)
```

---

## 扩展方法冲突处理

本库为 `int` 类型提供了语义化扩展（如 `1.days`）。若与其他库（如 GetX）的扩展名冲突，可使用 `hide` 隐藏本库扩展：

```dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
```

---

## JSON 序列化支持

支持配合 `json_serializable` 或 `freezed` 使用，只需注册自定义转换器：

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

* `==` 运算符比较的是**绝对时间戳**是否相等，而非字面量。
* 只有有效的 IANA 时区偏移才能被正确解析，非标准偏移将抛出异常。
* 请务必调用 `initializeTimeZone()` 进行初始化。

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
