// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadPost _$ThreadPostFromJson(Map<String, dynamic> json) => ThreadPost(
  id: (json['id'] as num).toInt(),
  threadId: (json['threadId'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  content: json['content'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  userId: (json['userId'] as num).toInt(),
  ratings: json['ratings'] as List<dynamic>,
  bans: (json['bans'] as List<dynamic>)
      .map((e) => Ban.fromJson(e as Map<String, dynamic>))
      .toList(),
  threadPostNumber: (json['threadPostNumber'] as num).toInt(),
  countryName: json['countryName'] as String?,
  countryCode: json['countryCode'] as String?,
  appName: json['appName'] as String?,
  distinguished: json['distinguished'],
  user: ThreadUser.fromJson(json['user'] as Map<String, dynamic>),
  responses: json['responses'] as List<dynamic>,
  mentionUsers: json['mentionUsers'] as List<dynamic>,
  lastEditedUser: json['lastEditedUser'] == null
      ? null
      : ThreadUser.fromJson(json['lastEditedUser'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ThreadPostToJson(ThreadPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'threadId': instance.threadId,
      'page': instance.page,
      'content': instance.content,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'userId': instance.userId,
      'ratings': instance.ratings,
      'bans': instance.bans,
      'threadPostNumber': instance.threadPostNumber,
      'countryName': instance.countryName,
      'countryCode': instance.countryCode,
      'appName': instance.appName,
      'distinguished': instance.distinguished,
      'user': instance.user,
      'responses': instance.responses,
      'mentionUsers': instance.mentionUsers,
      'lastEditedUser': instance.lastEditedUser,
    };
