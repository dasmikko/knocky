// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: (json['id'] as num).toInt(),
  conversationId: (json['conversationId'] as num).toInt(),
  user: json['user'] == null
      ? null
      : ThreadUser.fromJson(json['user'] as Map<String, dynamic>),
  content: json['content'] as String,
  readAt: json['readAt'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'user': instance.user,
  'content': instance.content,
  'readAt': instance.readAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
