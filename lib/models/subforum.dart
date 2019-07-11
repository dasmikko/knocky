import 'package:json_annotation/json_annotation.dart';

part 'subforum.g.dart';

@JsonSerializable()
class Subforum {
  final int id;
  final String icon;
  final String name;
  final String description;
  final int totalPosts;
  final int totalThreads;
  @JsonKey(name: 'lastPost_id')
  final int lastPostId;
  final SubforumLastPost lastPost;

  Subforum({
    this.id,
    this.icon,
    this.name,
    this.description,
    this.totalPosts,
    this.totalThreads,
    this.lastPostId,
    this.lastPost,
  });

  factory Subforum.fromJson(Map<String, dynamic> json) =>
      _$SubforumFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumToJson(this);
}

@JsonSerializable()
class SubforumLastPost {
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final int id;
  final SubForumLastPostThread thread;
  final SubforumLastPostUser user;

  SubforumLastPost({
    this.id,
    this.createdAt,
    this.thread,
    this.user,
  });

  factory SubforumLastPost.fromJson(Map<String, dynamic> json) =>
      _$SubforumLastPostFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumLastPostToJson(this);
}

@JsonSerializable()
class SubForumLastPostThread {
  final int id;
  @JsonKey(name: 'post_count')
  final int postCount;
  @JsonKey(name: 'subforum_id')
  final int subforumId;
  final String title;

  SubForumLastPostThread({
    this.id,
    this.postCount,
    this.subforumId,
    this.title,
  });

  factory SubForumLastPostThread.fromJson(Map<String, dynamic> json) =>
      _$SubForumLastPostThreadFromJson(json);
  Map<String, dynamic> toJson() => _$SubForumLastPostThreadToJson(this);
}

@JsonSerializable()
class SubforumLastPostUser {
  final bool isBanned;
  final int usergroup;
  final String username;

  SubforumLastPostUser({
    this.isBanned,
    this.usergroup,
    this.username,
  });

  factory SubforumLastPostUser.fromJson(Map<String, dynamic> json) =>
      _$SubforumLastPostUserFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumLastPostUserToJson(this);
}
