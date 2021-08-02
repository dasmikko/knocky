// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subforum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subforum _$SubforumFromJson(Map<String, dynamic> json) {
  return Subforum(
    id: json['id'] as int,
    icon: json['icon'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    totalPosts: json['totalPosts'] as int,
    totalThreads: json['totalThreads'] as int,
    lastPostId: json['lastPost_id'] as int,
    lastPost: json['lastPost'] == null
        ? null
        : SubforumOldLastPost.fromJson(
            json['lastPost'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SubforumToJson(Subforum instance) => <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'name': instance.name,
      'description': instance.description,
      'totalPosts': instance.totalPosts,
      'totalThreads': instance.totalThreads,
      'lastPost_id': instance.lastPostId,
      'lastPost': instance.lastPost,
    };

SubforumLastPost _$SubforumLastPostFromJson(Map<String, dynamic> json) {
  return SubforumLastPost(
    id: json['id'] as int,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    thread: json['thread'] as int,
    user: json['user'] == null
        ? null
        : SubforumLastPostUser.fromJson(json['user'] as Map<String, dynamic>),
    page: json['page'] as int,
  );
}

Map<String, dynamic> _$SubforumLastPostToJson(SubforumLastPost instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt?.toIso8601String(),
      'id': instance.id,
      'thread': instance.thread,
      'user': instance.user,
      'page': instance.page,
    };

SubforumOldLastPost _$SubforumOldLastPostFromJson(Map<String, dynamic> json) {
  return SubforumOldLastPost(
    id: json['id'] as int,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    thread: json['thread'] == null
        ? null
        : SubforumThreadLastPostThread.fromJson(
            json['thread'] as Map<String, dynamic>),
    user: json['user'] == null
        ? null
        : SubforumLastPostUser.fromJson(json['user'] as Map<String, dynamic>),
    page: json['page'] as int,
  );
}

Map<String, dynamic> _$SubforumOldLastPostToJson(
        SubforumOldLastPost instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt?.toIso8601String(),
      'id': instance.id,
      'thread': instance.thread,
      'user': instance.user,
      'page': instance.page,
    };

SubForumLastPostThread _$SubForumLastPostThreadFromJson(
    Map<String, dynamic> json) {
  return SubForumLastPostThread(
    id: json['id'] as int,
    postCount: json['post_count'] as int,
    subforumId: json['subforum_id'] as int,
    title: json['title'] as String,
    page: json['page'] as int,
  );
}

Map<String, dynamic> _$SubForumLastPostThreadToJson(
        SubForumLastPostThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_count': instance.postCount,
      'subforum_id': instance.subforumId,
      'title': instance.title,
      'page': instance.page,
    };

SubforumLastPostUser _$SubforumLastPostUserFromJson(Map<String, dynamic> json) {
  return SubforumLastPostUser(
    isBanned: json['isBanned'] as bool,
    usergroup: Usergroup.values[json['usergroup'] as int],
    username: json['username'] as String,
  );
}

Map<String, dynamic> _$SubforumLastPostUserToJson(
        SubforumLastPostUser instance) =>
    <String, dynamic>{
      'isBanned': instance.isBanned,
      'usergroup': instance.usergroup,
      'username': instance.username,
    };
