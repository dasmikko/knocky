// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subforumDetails.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubforumDetails _$SubforumDetailsFromJson(Map<String, dynamic> json) {
  return SubforumDetails(
      id: json['id'] as int,
      currentPage: json['currentPage'] as int,
      iconId: json['iconId'] as int,
      name: json['name'] as String,
      totalThreads: json['totalThreads'] as int,
      threads: (json['threads'] as List)
          ?.map((e) => e == null
              ? null
              : SubforumThread.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$SubforumDetailsToJson(SubforumDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentPage': instance.currentPage,
      'iconId': instance.iconId,
      'name': instance.name,
      'totalThreads': instance.totalThreads,
      'threads': instance.threads
    };

SubforumThread _$SubforumThreadFromJson(Map<String, dynamic> json) {
  return SubforumThread(
      firstUnreadId: json['firstUnreadId'] as int,
      iconId: json['icon_id'] as int,
      id: json['id'] as int,
      locked: json['locked'] as int,
      pinned: json['pinned'] as int,
      postCount: json['postCount'] as int,
      readThreadUnreadPosts: json['readThreadUnreadPosts'] as int,
      title: json['title'] as String,
      unreadType: json['unreadType'] as int);
}

Map<String, dynamic> _$SubforumThreadToJson(SubforumThread instance) =>
    <String, dynamic>{
      'firstUnreadId': instance.firstUnreadId,
      'icon_id': instance.iconId,
      'id': instance.id,
      'locked': instance.locked,
      'pinned': instance.pinned,
      'postCount': instance.postCount,
      'readThreadUnreadPosts': instance.readThreadUnreadPosts,
      'title': instance.title,
      'unreadType': instance.unreadType
    };
