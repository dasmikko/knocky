// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alert _$AlertFromJson(Map<String, dynamic> json) => Alert(
  id: (json['id'] as num).toInt(),
  thread: Thread.fromJson(json['thread'] as Map<String, dynamic>),
  unreadPosts: (json['unreadPosts'] as num).toInt(),
  firstUnreadId: (json['firstUnreadId'] as num).toInt(),
);

Map<String, dynamic> _$AlertToJson(Alert instance) => <String, dynamic>{
  'id': instance.id,
  'thread': instance.thread,
  'unreadPosts': instance.unreadPosts,
  'firstUnreadId': instance.firstUnreadId,
};
