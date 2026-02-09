// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadUser _$ThreadUserFromJson(Map<String, dynamic> json) => ThreadUser(
  id: (json['id'] as num).toInt(),
  role: Role.fromJson(json['role'] as Map<String, dynamic>),
  username: json['username'] as String,
  avatarUrl: json['avatarUrl'] as String? ?? '',
  backgroundUrl: json['backgroundUrl'] as String? ?? '',
  posts: (json['posts'] as num).toInt(),
  threads: (json['threads'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  banned: json['banned'] as bool,
  isBanned: json['isBanned'] as bool,
  title: json['title'] as String?,
  pronouns: json['pronouns'] as String?,
  useBioForTitle: (json['useBioForTitle'] as num?)?.toInt(),
  lastOnlineAt: json['lastOnlineAt'] as String?,
  showOnlineStatus: (json['showOnlineStatus'] as num?)?.toInt(),
  disableIncomingMessages: (json['disableIncomingMessages'] as num?)?.toInt(),
  online: json['online'] as bool?,
);

Map<String, dynamic> _$ThreadUserToJson(ThreadUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'backgroundUrl': instance.backgroundUrl,
      'posts': instance.posts,
      'threads': instance.threads,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'banned': instance.banned,
      'isBanned': instance.isBanned,
      'title': instance.title,
      'pronouns': instance.pronouns,
      'useBioForTitle': instance.useBioForTitle,
      'lastOnlineAt': instance.lastOnlineAt,
      'showOnlineStatus': instance.showOnlineStatus,
      'disableIncomingMessages': instance.disableIncomingMessages,
      'online': instance.online,
    };
