// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadResponse _$ThreadResponseFromJson(Map<String, dynamic> json) =>
    ThreadResponse(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      locked: json['locked'] as bool,
      pinned: json['pinned'] as bool,
      deleted: json['deleted'] as bool? ?? false,
      iconId: (json['iconId'] as num?)?.toInt() ?? 0,
      subforumId: (json['subforumId'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      deletedAt: json['deletedAt'] as String?,
      threadBackgroundUrl: json['threadBackgroundUrl'] as String?,
      threadBackgroundType: json['threadBackgroundType'] as String?,
      totalPosts: (json['totalPosts'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      posts: (json['posts'] as List<dynamic>)
          .map((e) => ThreadPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: json['user'] == null
          ? null
          : ThreadUser.fromJson(json['user'] as Map<String, dynamic>),
      readThread: json['readThread'] == null
          ? null
          : ReadThread.fromJson(json['readThread'] as Map<String, dynamic>),
      subforum: json['subforum'] == null
          ? null
          : Subforum.fromJson(json['subforum'] as Map<String, dynamic>),
      viewers: json['viewers'] == null
          ? null
          : Viewers.fromJson(json['viewers'] as Map<String, dynamic>),
      tags: json['tags'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$ThreadResponseToJson(ThreadResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'locked': instance.locked,
      'pinned': instance.pinned,
      'deleted': instance.deleted,
      'iconId': instance.iconId,
      'subforumId': instance.subforumId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'deletedAt': instance.deletedAt,
      'threadBackgroundUrl': instance.threadBackgroundUrl,
      'threadBackgroundType': instance.threadBackgroundType,
      'totalPosts': instance.totalPosts,
      'currentPage': instance.currentPage,
      'posts': instance.posts,
      'user': instance.user,
      'readThread': instance.readThread,
      'subforum': instance.subforum,
      'viewers': instance.viewers,
      'tags': instance.tags,
    };
