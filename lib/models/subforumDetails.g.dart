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
        ?.toList(),
  );
}

Map<String, dynamic> _$SubforumDetailsToJson(SubforumDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentPage': instance.currentPage,
      'iconId': instance.iconId,
      'name': instance.name,
      'totalThreads': instance.totalThreads,
      'threads': instance.threads,
    };

SubforumThread _$SubforumThreadFromJson(Map<String, dynamic> json) {
  return SubforumThread(
    backgroundUrl: json['backgroundUrl'] as String,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    firstUnreadId: json['firstUnreadId'] as int,
    iconId: json['iconId'] as int,
    id: json['id'] as int,
    locked: json['locked'] as bool,
    pinned: json['pinned'] as bool,
    postCount: json['postCount'] as int,
    readThreadUnreadPosts: json['readThreadUnreadPosts'] as int ?? 0,
    unreadPostCount: json['unreadPostCount'] as int ?? 0,
    title: json['title'] as String,
    unreadType: json['unreadType'] as int,
    user: json['user'] == null
        ? null
        : SubforumThreadUser.fromJson(json['user'] as Map<String, dynamic>),
    lastPost: json['lastPost'] == null
        ? null
        : SubforumLastPost.fromJson(json['lastPost'] as Map<String, dynamic>),
    hasRead: json['hasRead'] as bool,
    subscribed: json['subscribed'] as bool,
    tags: (json['tags'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(int.parse(k), e as String),
            ))
        ?.toList(),
  );
}

Map<String, dynamic> _$SubforumThreadToJson(SubforumThread instance) =>
    <String, dynamic>{
      'backgroundUrl': instance.backgroundUrl,
      'firstUnreadId': instance.firstUnreadId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'iconId': instance.iconId,
      'id': instance.id,
      'locked': instance.locked,
      'pinned': instance.pinned,
      'postCount': instance.postCount,
      'readThreadUnreadPosts': instance.readThreadUnreadPosts,
      'unreadPostCount': instance.unreadPostCount,
      'title': instance.title,
      'unreadType': instance.unreadType,
      'user': instance.user,
      'lastPost': instance.lastPost,
      'hasRead': instance.hasRead,
      'subscribed': instance.subscribed,
      'tags': instance.tags
          ?.map((e) => e?.map((k, e) => MapEntry(k.toString(), e)))
          ?.toList(),
    };

SignificantThread _$SignificantThreadFromJson(Map<String, dynamic> json) {
  return SignificantThread(
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    firstUnreadId: json['firstUnreadId'] as int,
    iconId: json['iconId'] as int,
    id: json['id'] as int,
    locked: json['locked'] as bool,
    pinned: json['pinned'] as bool,
    postCount: json['postCount'] as int,
    readThreadUnreadPosts: json['readThreadUnreadPosts'] as int ?? 0,
    unreadPostCount: json['unreadPostCount'] as int ?? 0,
    title: json['title'] as String,
    unreadType: json['unreadType'] as int,
    user: json['user'] == null
        ? null
        : SubforumThreadUser.fromJson(json['user'] as Map<String, dynamic>),
    lastPost: json['lastPost'] == null
        ? null
        : SubforumLastPost.fromJson(json['lastPost'] as Map<String, dynamic>),
    backgroundUrl: json['backgroundUrl'] as String,
    viewers: json['viewers'] == null
        ? null
        : Viewers.fromJson(json['viewers'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SignificantThreadToJson(SignificantThread instance) =>
    <String, dynamic>{
      'firstUnreadId': instance.firstUnreadId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'iconId': instance.iconId,
      'id': instance.id,
      'locked': instance.locked,
      'pinned': instance.pinned,
      'postCount': instance.postCount,
      'readThreadUnreadPosts': instance.readThreadUnreadPosts,
      'unreadPostCount': instance.unreadPostCount,
      'title': instance.title,
      'unreadType': instance.unreadType,
      'user': instance.user,
      'lastPost': instance.lastPost,
      'backgroundUrl': instance.backgroundUrl,
      'viewers': instance.viewers,
    };

SubforumThreadUser _$SubforumThreadUserFromJson(Map<String, dynamic> json) {
  return SubforumThreadUser(
    usergroup: Usergroup.values[json['usergroup'] as int],
    username: json['username'] as String,
    avatarUrl: json['avatar_url'] as String,
    isBanned: json['isBanned'] as bool,
  );
}

Map<String, dynamic> _$SubforumThreadUserToJson(SubforumThreadUser instance) =>
    <String, dynamic>{
      'usergroup': instance.usergroup,
      'avatar_url': instance.avatarUrl,
      'username': instance.username,
      'isBanned': instance.isBanned,
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
            json['user'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SubforumThreadLastPostToJson(
        SubforumThreadLastPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'thread': instance.thread,
      'user': instance.user,
    };

SubforumThreadLastPostThread _$SubforumThreadLastPostThreadFromJson(
    Map<String, dynamic> json) {
  return SubforumThreadLastPostThread(
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    id: json['id'] as int,
    title: json['title'] as String,
    postCount: json['post_count'] as int,
    lastPost: json['lastPost'] == null
        ? null
        : SubforumLastpostThreadLastpost.fromJson(
            json['lastPost'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SubforumThreadLastPostThreadToJson(
        SubforumThreadLastPostThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'title': instance.title,
      'post_count': instance.postCount,
      'lastPost': instance.lastPost,
    };

SubforumThreadLastPostUser _$SubforumThreadLastPostUserFromJson(
    Map<String, dynamic> json) {
  return SubforumThreadLastPostUser(
    usergroup: Usergroup.values[json['usergroup'] as int],
    username: json['username'] as String,
    avatarUrl: json['avatar_url'] as String,
  );
}

Map<String, dynamic> _$SubforumThreadLastPostUserToJson(
        SubforumThreadLastPostUser instance) =>
    <String, dynamic>{
      'usergroup': instance.usergroup,
      'avatar_url': instance.avatarUrl,
      'username': instance.username,
    };

SubforumLastpostThreadLastpost _$SubforumLastpostThreadLastpostFromJson(
    Map<String, dynamic> json) {
  return SubforumLastpostThreadLastpost(
    id: json['id'] as int,
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    thread: json['thread'] as int,
    user: json['user'] == null
        ? null
        : SubforumLastPostUser.fromJson(json['user'] as Map<String, dynamic>),
    page: json['page'] as int,
    content: json['content'] as String,
  );
}

Map<String, dynamic> _$SubforumLastpostThreadLastpostToJson(
        SubforumLastpostThreadLastpost instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt?.toIso8601String(),
      'id': instance.id,
      'thread': instance.thread,
      'content': instance.content,
      'user': instance.user,
      'page': instance.page,
    };
