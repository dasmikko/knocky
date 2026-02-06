// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'read_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadThread _$ReadThreadFromJson(Map<String, dynamic> json) => ReadThread(
  lastPostNumber: (json['lastPostNumber'] as num).toInt(),
  lastSeen: json['lastSeen'] as String,
  isSubscription: json['isSubscription'] as bool?,
  firstUnreadId: (json['firstUnreadId'] as num).toInt(),
  unreadPostCount: (json['unreadPostCount'] as num).toInt(),
);

Map<String, dynamic> _$ReadThreadToJson(ReadThread instance) =>
    <String, dynamic>{
      'lastPostNumber': instance.lastPostNumber,
      'lastSeen': instance.lastSeen,
      'isSubscription': instance.isSubscription,
      'firstUnreadId': instance.firstUnreadId,
      'unreadPostCount': instance.unreadPostCount,
    };
