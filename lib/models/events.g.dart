// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KnockoutEvent _$KnockoutEventFromJson(Map<String, dynamic> json) {
  return KnockoutEvent(
    content: json['content'] as String,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    id: json['id'] as int,
    executedBy: json['executedBy'] as int,
  );
}

Map<String, dynamic> _$KnockoutEventToJson(KnockoutEvent instance) =>
    <String, dynamic>{
      'content': instance.content,
      'createdAt': instance.createdAt?.toIso8601String(),
      'executedBy': instance.executedBy,
      'id': instance.id,
    };
