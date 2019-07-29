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
        : SubforumLastPost.fromJson(json['lastPost'] as Map<String, dynamic>),
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
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    thread: json['thread'] == null
        ? null
        : SubForumLastPostThread.fromJson(
            json['thread'] as Map<String, dynamic>),
    user: json['user'] == null
        ? null
        : SubforumLastPostUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SubforumLastPostToJson(SubforumLastPost instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt?.toIso8601String(),
      'id': instance.id,
      'thread': instance.thread,
      'user': instance.user,
    };

SubForumLastPostThread _$SubForumLastPostThreadFromJson(
    Map<String, dynamic> json) {
  return SubForumLastPostThread(
    id: json['id'] as int,
    postCount: json['post_count'] as int,
    subforumId: json['subforum_id'] as int,
    title: json['title'] as String,
  );
}

Map<String, dynamic> _$SubForumLastPostThreadToJson(
        SubForumLastPostThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_count': instance.postCount,
      'subforum_id': instance.subforumId,
      'title': instance.title,
    };

SubforumLastPostUser _$SubforumLastPostUserFromJson(Map<String, dynamic> json) {
  return SubforumLastPostUser(
    isBanned: json['isBanned'] as bool,
    usergroup: json['usergroup'] as int,
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
