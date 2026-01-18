// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freezed_example.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  title: json['title'] as String,
  startTime: const EasyDateTimeConverter().fromJson(
    json['startTime'] as String,
  ),
  endTime: const EasyDateTimeNullableConverter().fromJson(
    json['endTime'] as String?,
  ),
  isAllDay: json['isAllDay'] as bool? ?? false,
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'startTime': const EasyDateTimeConverter().toJson(instance.startTime),
  'endTime': const EasyDateTimeNullableConverter().toJson(instance.endTime),
  'isAllDay': instance.isAllDay,
};

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['name'] as String,
  createdAt: const EasyDateTimeConverter().fromJson(
    json['createdAt'] as String,
  ),
  lastLoginAt: const EasyDateTimeNullableConverter().fromJson(
    json['lastLoginAt'] as String?,
  ),
  deletedAt: const EasyDateTimeNullableConverter().fromJson(
    json['deletedAt'] as String?,
  ),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': const EasyDateTimeConverter().toJson(instance.createdAt),
  'lastLoginAt': const EasyDateTimeNullableConverter().toJson(
    instance.lastLoginAt,
  ),
  'deletedAt': const EasyDateTimeNullableConverter().toJson(instance.deletedAt),
};

_Schedule _$ScheduleFromJson(Map<String, dynamic> json) => _Schedule(
  id: json['id'] as String,
  scheduledAt: const EasyDateTimeConverter().fromJson(
    json['scheduledAt'] as String,
  ),
  completedAt: const EasyDateTimeNullableConverter().fromJson(
    json['completedAt'] as String?,
  ),
  status: json['status'] as String,
);

Map<String, dynamic> _$ScheduleToJson(_Schedule instance) => <String, dynamic>{
  'id': instance.id,
  'scheduledAt': const EasyDateTimeConverter().toJson(instance.scheduledAt),
  'completedAt': const EasyDateTimeNullableConverter().toJson(
    instance.completedAt,
  ),
  'status': instance.status,
};
