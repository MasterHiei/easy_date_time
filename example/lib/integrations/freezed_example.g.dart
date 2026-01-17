// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freezed_example.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
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

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'startTime': const EasyDateTimeConverter().toJson(instance.startTime),
      'endTime': const EasyDateTimeNullableConverter().toJson(instance.endTime),
      'isAllDay': instance.isAllDay,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
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

Map<String, dynamic> _$$UserImplToJson(
  _$UserImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': const EasyDateTimeConverter().toJson(instance.createdAt),
  'lastLoginAt': const EasyDateTimeNullableConverter().toJson(
    instance.lastLoginAt,
  ),
  'deletedAt': const EasyDateTimeNullableConverter().toJson(instance.deletedAt),
};

_$ScheduleImpl _$$ScheduleImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleImpl(
      id: json['id'] as String,
      scheduledAt: const EasyDateTimeConverter().fromJson(
        json['scheduledAt'] as String,
      ),
      completedAt: const EasyDateTimeNullableConverter().fromJson(
        json['completedAt'] as String?,
      ),
      status: json['status'] as String,
    );

Map<String, dynamic> _$$ScheduleImplToJson(_$ScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scheduledAt': const EasyDateTimeConverter().toJson(instance.scheduledAt),
      'completedAt': const EasyDateTimeNullableConverter().toJson(
        instance.completedAt,
      ),
      'status': instance.status,
    };
