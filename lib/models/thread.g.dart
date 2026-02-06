// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Thread _$ThreadFromJson(Map<String, dynamic> json) => Thread(
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
  user: ThreadUser.fromJson(json['user'] as Map<String, dynamic>),
  postCount: (json['postCount'] as num).toInt(),
  recentPostCount: (json['recentPostCount'] as num).toInt(),
  readThread: json['readThread'] == null
      ? null
      : ReadThread.fromJson(json['readThread'] as Map<String, dynamic>),
  firstPostTopRating: json['firstPostTopRating'] == null
      ? null
      : Rating.fromJson(json['firstPostTopRating'] as Map<String, dynamic>),
  subforum: json['subforum'],
  tags: json['tags'] as List<dynamic>,
  viewers: json['viewers'] == null
      ? null
      : Viewers.fromJson(json['viewers'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ThreadToJson(Thread instance) => <String, dynamic>{
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
  'firstPostTopRating': instance.firstPostTopRating,
  'subforum': instance.subforum,
  'tags': instance.tags,
  'viewers': instance.viewers,
};
