// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KnockyNotification _$KnockyNotificationFromJson(Map<String, dynamic> json) =>
    KnockyNotification(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      userId: (json['userId'] as num).toInt(),
      read: json['read'] as bool,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$KnockyNotificationToJson(KnockyNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'userId': instance.userId,
      'read': instance.read,
      'createdAt': instance.createdAt,
    };
