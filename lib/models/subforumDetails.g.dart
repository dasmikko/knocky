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
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      firstUnreadId: json['firstUnreadId'] as int,
      iconId: json['icon_id'] as int,
      id: json['id'] as int,
      locked: json['locked'] as int,
      pinned: json['pinned'] as int,
      postCount: json['postCount'] as int,
      readThreadUnreadPosts: json['readThreadUnreadPosts'] as int ?? 0,
      title: json['title'] as String,
      unreadType: json['unreadType'] as int,
      user: json['user'] == null
          ? null
          : SubforumThreadUser.fromJson(json['user'] as Map<String, dynamic>),
      lastPost: json['lastPost'] == null
          ? null
          : SubforumLastPost.fromJson(
              json['lastPost'] as Map<String, dynamic>));
}

Map<String, dynamic> _$SubforumThreadToJson(SubforumThread instance) =>
    <String, dynamic>{
      'firstUnreadId': instance.firstUnreadId,
      'created_at': instance.createdAt?.toIso8601String(),
      'icon_id': instance.iconId,
      'id': instance.id,
      'locked': instance.locked,
      'pinned': instance.pinned,
      'postCount': instance.postCount,
      'readThreadUnreadPosts': instance.readThreadUnreadPosts,
      'title': instance.title,
      'unreadType': instance.unreadType,
      'user': instance.user,
      'lastPost': instance.lastPost
    };

SubforumThreadUser _$SubforumThreadUserFromJson(Map<String, dynamic> json) {
  return SubforumThreadUser(
      usergroup: json['usergroup'] as int,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String,
      isBanned: json['isBanned'] as bool);
}

Map<String, dynamic> _$SubforumThreadUserToJson(SubforumThreadUser instance) =>
    <String, dynamic>{
      'usergroup': instance.usergroup,
      'avatar_url': instance.avatarUrl,
      'username': instance.username,
      'isBanned': instance.isBanned
    };

SubforumThreadLastPost _$SubforumThreadLastPostFromJson(
    Map<String, dynamic> json) {
  return SubforumThreadLastPost(
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      id: json['id'] as int,
      thread: json['thread'] == null
          ? null
          : SubforumThreadLastPostThread.fromJson(
              json['thread'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : SubforumThreadLastPostUser.fromJson(
              json['user'] as Map<String, dynamic>));
}

Map<String, dynamic> _$SubforumThreadLastPostToJson(
        SubforumThreadLastPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'thread': instance.thread,
      'user': instance.user
    };

SubforumThreadLastPostThread _$SubforumThreadLastPostThreadFromJson(
    Map<String, dynamic> json) {
  return SubforumThreadLastPostThread(
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      id: json['id'] as int,
      title: json['title'] as String,
      postCount: json['post_count'] as int);
}

Map<String, dynamic> _$SubforumThreadLastPostThreadToJson(
        SubforumThreadLastPostThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'title': instance.title,
      'post_count': instance.postCount
    };

SubforumThreadLastPostUser _$SubforumThreadLastPostUserFromJson(
    Map<String, dynamic> json) {
  return SubforumThreadLastPostUser(
      usergroup: json['usergroup'] as int,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String);
}

Map<String, dynamic> _$SubforumThreadLastPostUserToJson(
        SubforumThreadLastPostUser instance) =>
    <String, dynamic>{
      'usergroup': instance.usergroup,
      'avatar_url': instance.avatarUrl,
      'username': instance.username
    };
