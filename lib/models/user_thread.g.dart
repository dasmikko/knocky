// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserThread _$UserThreadFromJson(Map<String, dynamic> json) => UserThread(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  iconId: (json['iconId'] as num).toInt(),
  subforumId: (json['subforumId'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  deletedAt: json['deletedAt'] as String?,
  deleted: json['deleted'] as bool,
  locked: json['locked'] as bool,
  pinned: json['pinned'] as bool,
  lastPost: _postFromJson(json['lastPost']),
  backgroundUrl: json['backgroundUrl'] as String?,
  backgroundType: json['backgroundType'] as String?,
  user: (json['user'] as num).toInt(),
  postCount: (json['postCount'] as num).toInt(),
  recentPostCount: (json['recentPostCount'] as num).toInt(),
  readThread: json['readThread'] == null
      ? null
      : ReadThread.fromJson(json['readThread'] as Map<String, dynamic>),
  subforum: json['subforum'],
  tags: json['tags'] as List<dynamic>,
);

Map<String, dynamic> _$UserThreadToJson(UserThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'iconId': instance.iconId,
      'subforumId': instance.subforumId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'deletedAt': instance.deletedAt,
      'deleted': instance.deleted,
      'locked': instance.locked,
      'pinned': instance.pinned,
      'lastPost': instance.lastPost,
      'backgroundUrl': instance.backgroundUrl,
      'backgroundType': instance.backgroundType,
      'user': instance.user,
      'postCount': instance.postCount,
      'recentPostCount': instance.recentPostCount,
      'readThread': instance.readThread,
      'subforum': instance.subforum,
      'tags': instance.tags,
    };
