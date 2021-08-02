// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'syncData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncDataModel _$SyncDataModelFromJson(Map<String, dynamic> json) {
  return SyncDataModel(
      avatarUrl: json['avatarUrl'] as String,
      backgroundUrl: json['backgroundUrl'] as String,
      id: json['id'] as int,
      usergroup: Usergroup.values[json['usergroup'] as int],
      username: json['username'] as String,
      isBanned: json['isBanned'] as bool,
      mentions: (json['mentions'] as List)
          ?.map((e) => e == null
              ? null
              : SyncDataMentionModel.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      subscriptions: (json['subscriptions'] as List)
          ?.map((e) => e == null
              ? null
              : ThreadAlert.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$SyncDataModelToJson(SyncDataModel instance) =>
    <String, dynamic>{
      'avatarUrl': instance.avatarUrl,
      'backgroundUrl': instance.backgroundUrl,
      'id': instance.id,
      'isBanned': instance.isBanned,
      'mentions': instance.mentions,
      'usergroup': instance.usergroup,
      'username': instance.username,
    };

SyncDataMentionModel _$SyncDataMentionModelFromJson(Map<String, dynamic> json) {
  return SyncDataMentionModel(
    content: _contentFromJson(json['content'] as String),
    postId: json['postId'] as int,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    mentionId: json['mentionId'] as int,
    threadId: json['threadId'] as int,
    threadPage: json['threadPage'] as int,
  );
}

Map<String, dynamic> _$SyncDataMentionModelToJson(
        SyncDataMentionModel instance) =>
    <String, dynamic>{
      'content': instance.content,
      'createdAt': instance.createdAt?.toIso8601String(),
      'mentionId': instance.mentionId,
      'postId': instance.postId,
      'threadId': instance.threadId,
      'threadPage': instance.threadPage,
    };
