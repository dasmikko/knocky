// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEventThread _$CalendarEventThreadFromJson(Map<String, dynamic> json) =>
    CalendarEventThread(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      iconId: (json['iconId'] as num).toInt(),
      subforumId: (json['subforumId'] as num).toInt(),
      backgroundUrl: json['backgroundUrl'] as String?,
      backgroundType: json['backgroundType'] as String?,
    );

Map<String, dynamic> _$CalendarEventThreadToJson(
  CalendarEventThread instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'iconId': instance.iconId,
  'subforumId': instance.subforumId,
  'backgroundUrl': instance.backgroundUrl,
  'backgroundType': instance.backgroundType,
};

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    CalendarEvent(
      id: (json['id'] as num).toInt(),
      createdBy: ThreadUser.fromJson(json['createdBy'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String,
      thread: _threadFromJson(json['thread']),
      startsAt: json['startsAt'] as String,
      endsAt: json['endsAt'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$CalendarEventToJson(CalendarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdBy': instance.createdBy,
      'title': instance.title,
      'description': instance.description,
      'thread': instance.thread,
      'startsAt': instance.startsAt,
      'endsAt': instance.endsAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
