// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threadAlert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadAlert _$ThreadAlertFromJson(Map<String, dynamic> json) {
  return ThreadAlert(
    firstUnreadId: json['firstUnreadId'] as int,
    threadBackgroundUrl: json['threadBackgroundUrl'] as String,
    threadTitle: json['threadTitle'] as String,
    threadUser: json['threadUser'] as int,
    threadId: json['threadId'] as int,
    threadUserAvatarUrl: json['threadUserAvatarUrl'] as String,
    threadUsername: json['threadUsername'] as String,
    threadUserUsergroup: json['threadUserUsergroup'] as int,
    threadLocked: json['threadLocked'] as bool,
    threadIcon: json['threadIcon'] as int,
    title: json['title'] as String,
    unreadPosts: json['unreadPosts'] as int,
    lastPost: json['lastPost'] == null
        ? null
        : ThreadAlertLastPost.fromJson(
            json['lastPost'] as Map<String, dynamic>),
    threadPostCount: json['threadPostCount'] as int,
  );
}

Map<String, dynamic> _$ThreadAlertToJson(ThreadAlert instance) =>
    <String, dynamic>{
      'firstUnreadId': instance.firstUnreadId,
      'threadBackgroundUrl': instance.threadBackgroundUrl,
      'threadTitle': instance.threadTitle,
      'threadUser': instance.threadUser,
      'threadLocked': instance.threadLocked,
      'threadPostCount': instance.threadPostCount,
      'threadUserAvatarUrl': instance.threadUserAvatarUrl,
      'threadUserUsergroup': instance.threadUserUsergroup,
      'threadIcon': instance.threadIcon,
      'threadUsername': instance.threadUsername,
      'threadId': instance.threadId,
      'title': instance.title,
      'unreadPosts': instance.unreadPosts,
      'lastPost': instance.lastPost,
    };

ThreadAlertLastPost _$ThreadAlertLastPostFromJson(Map<String, dynamic> json) {
  return ThreadAlertLastPost(
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    id: json['id'] as int,
    thread: json['thread'] as int,
    threadPostNumber: json['threadPostNumber'] as int,
    page: json['page'] as int,
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
      'createdAt': instance.createdAt?.toIso8601String(),
      'thread': instance.thread,
      'threadPostNumber': instance.threadPostNumber,
      'page': instance.page,
      'user': instance.user,
    };

ThreadAlertLastPostThread _$ThreadAlertLastPostThreadFromJson(
    Map<String, dynamic> json) {
  return ThreadAlertLastPostThread(
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    id: json['id'] as int,
    title: json['title'] as String,
    postCount: json['postCount'] as int,
  );
}

Map<String, dynamic> _$ThreadAlertLastPostThreadToJson(
        ThreadAlertLastPostThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt?.toIso8601String(),
      'title': instance.title,
      'postCount': instance.postCount,
    };

ThreadAlertLastPostUser _$ThreadAlertLastPostUserFromJson(
    Map<String, dynamic> json) {
  return ThreadAlertLastPostUser(
    usergroup: json['usergroup'] as int,
    username: json['username'] as String,
    avatarUrl: json['avatarUrl'] as String,
  );
}

Map<String, dynamic> _$ThreadAlertLastPostUserToJson(
        ThreadAlertLastPostUser instance) =>
    <String, dynamic>{
      'usergroup': instance.usergroup,
      'avatarUrl': instance.avatarUrl,
      'username': instance.username,
    };
