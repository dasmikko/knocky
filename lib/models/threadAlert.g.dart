// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threadAlert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadAlert _$ThreadAlertFromJson(Map<String, dynamic> json) {
  return ThreadAlert(
    avatarUrl: json['avatar_url'] as String,
    backgroundUrl: json['background_url'] as String,
    email: json['email'] as String,
    firstUnreadId: json['firstUnreadId'] as int,
    iconId: json['icon_id'] as int,
    id: json['id'] as int,
    lastSeen: json['last_seen'] == null
        ? null
        : DateTime.parse(json['last_seen'] as String),
    locked: json['locked'] as int,
    pinned: json['pinned'] as int,
    subforumId: json['subforum_id'] as int,
    threadCreatedAt: json['threadCreatedAt'] == null
        ? null
        : DateTime.parse(json['threadCreatedAt'] as String),
    threadDeletedAt: json['threadDeletedAt'] == null
        ? null
        : DateTime.parse(json['threadDeletedAt'] as String),
    threadTitle: json['threadTitle'] as String,
    threadUpdateAt: json['threadUpdateAt'] == null
        ? null
        : DateTime.parse(json['threadUpdateAt'] as String),
    threadUser: json['threadUser'] as int,
    username: json['username'] as String,
    threadId: json['thread_id'] as int,
    threadUserAvatarUrl: json['threadUserAvatarUrl'] as String,
    threadUsername: json['threadUsername'] as String,
    threadUserUsergroup: json['threadUserUsergroup'] as int,
    title: json['title'] as String,
    unreadPosts: json['unreadPosts'] as int,
    updatedAt: json['updated_at'] == null
        ? null
        : DateTime.parse(json['updated_at'] as String),
    usergroup: json['usergroup'] as int,
    userId: json['user_id'] as int,
    lastPost: json['lastPost'] == null
        ? null
        : ThreadAlertLastPost.fromJson(
            json['lastPost'] as Map<String, dynamic>),
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    threadPostCount: json['threadPostCount'] as int,
  );
}

Map<String, dynamic> _$ThreadAlertToJson(ThreadAlert instance) =>
    <String, dynamic>{
      'avatar_url': instance.avatarUrl,
      'background_url': instance.backgroundUrl,
      'email': instance.email,
      'firstUnreadId': instance.firstUnreadId,
      'icon_id': instance.iconId,
      'id': instance.id,
      'last_seen': instance.lastSeen?.toIso8601String(),
      'locked': instance.locked,
      'pinned': instance.pinned,
      'subforum_id': instance.subforumId,
      'threadCreatedAt': instance.threadCreatedAt?.toIso8601String(),
      'threadDeletedAt': instance.threadDeletedAt?.toIso8601String(),
      'threadTitle': instance.threadTitle,
      'threadUpdateAt': instance.threadUpdateAt?.toIso8601String(),
      'threadUser': instance.threadUser,
      'threadPostCount': instance.threadPostCount,
      'threadUserAvatarUrl': instance.threadUserAvatarUrl,
      'threadUserUsergroup': instance.threadUserUsergroup,
      'threadUsername': instance.threadUsername,
      'thread_id': instance.threadId,
      'title': instance.title,
      'unreadPosts': instance.unreadPosts,
      'updated_at': instance.updatedAt?.toIso8601String(),
      'user_id': instance.userId,
      'usergroup': instance.usergroup,
      'username': instance.username,
      'lastPost': instance.lastPost,
      'created_at': instance.createdAt?.toIso8601String(),
    };

ThreadAlertLastPost _$ThreadAlertLastPostFromJson(Map<String, dynamic> json) {
  return ThreadAlertLastPost(
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    id: json['id'] as int,
    thread: json['thread'] == null
        ? null
        : ThreadAlertLastPostThread.fromJson(
            json['thread'] as Map<String, dynamic>),
    user: json['user'] == null
        ? null
        : ThreadAlertLastPostUser.fromJson(
            json['user'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ThreadAlertLastPostToJson(
        ThreadAlertLastPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'thread': instance.thread,
      'user': instance.user,
    };

ThreadAlertLastPostThread _$ThreadAlertLastPostThreadFromJson(
    Map<String, dynamic> json) {
  return ThreadAlertLastPostThread(
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    id: json['id'] as int,
    title: json['title'] as String,
    postCount: json['post_count'] as int,
  );
}

Map<String, dynamic> _$ThreadAlertLastPostThreadToJson(
        ThreadAlertLastPostThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'title': instance.title,
      'post_count': instance.postCount,
    };

ThreadAlertLastPostUser _$ThreadAlertLastPostUserFromJson(
    Map<String, dynamic> json) {
  return ThreadAlertLastPostUser(
    usergroup: json['usergroup'] as int,
    username: json['username'] as String,
    avatarUrl: json['avatar_url'] as String,
  );
}

Map<String, dynamic> _$ThreadAlertLastPostUserToJson(
        ThreadAlertLastPostUser instance) =>
    <String, dynamic>{
      'usergroup': instance.usergroup,
      'avatar_url': instance.avatarUrl,
      'username': instance.username,
    };
