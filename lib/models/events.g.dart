// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KnockoutEvent _$KnockoutEventFromJson(Map<String, dynamic> json) {
  return KnockoutEvent(
    content: json['content'] as String,
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    id: json['id'] as int,
    executedBy: json['executed_by'] as int,
  );
}

Map<String, dynamic> _$KnockoutEventToJson(KnockoutEvent instance) =>
    <String, dynamic>{
      'content': instance.content,
      'created_at': instance.createdAt?.toIso8601String(),
      'executed_by': instance.executedBy,
      'id': instance.id,
    };
