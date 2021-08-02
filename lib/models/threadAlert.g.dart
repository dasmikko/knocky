// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threadAlert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadAlert _$ThreadAlertFromJson(Map<String, dynamic> json) {
  return ThreadAlert(
      firstUnreadId: json['firstUnreadId'] as int,
      threadBackgroundUrl: json['threadBackgroundUrl'] as String,
      title: json['threadTitle'] as String,
      id: json['threadId'] as int,
      unreadPostCount: json['unreadPosts'] as int,
      lastPost: json['lastPost'] == null
          ? null
          : ThreadAlertLastPost.fromJson(
              json['lastPost'] as Map<String, dynamic>),
      postCount: json['threadPostCount'] as int,
      iconId: json['icon_id'] as int,
      backgroundUrl: json['threadBackgroundUrl'] as String,
      locked: json['threadLocked'] as bool,
      user: _$ThreadAlertUser(json));
}

ThreadUser _$ThreadAlertUser(Map<String, dynamic> json) {
  return ThreadUser(
    usergroup: Usergroup.values[json['threadUserUsergroup'] as int],
    username: json['threadUsername'] as String,
  );
}

Map<String, dynamic> _$ThreadAlertToJson(ThreadAlert instance) =>
    <String, dynamic>{
      'firstUnreadId': instance.firstUnreadId,
      'threadBackgroundUrl': instance.threadBackgroundUrl,
      'threadTitle': instance.title,
      'threadLocked': instance.locked,
      'threadPostCount': instance.postCount,
      'threadIcon': instance.iconId,
      'threadId': instance.id,
      'unreadPosts': instance.unreadPostCount,
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
    usergroup: Usergroup.values[json['usergroup'] as int],
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
