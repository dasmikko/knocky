import 'package:json_annotation/json_annotation.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/usergroup.dart';

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
  final SubforumOldLastPost lastPost;

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
  final DateTime createdAt;
  final int id;
  final int thread;
  final SubforumLastPostUser user;
  final int page;

  SubforumLastPost({
    this.id,
    this.createdAt,
    this.thread,
    this.user,
    this.page,
  });

  factory SubforumLastPost.fromJson(Map<String, dynamic> json) =>
      _$SubforumLastPostFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumLastPostToJson(this);
}

@JsonSerializable()
class SubforumOldLastPost {
  final DateTime createdAt;
  final int id;
  final SubforumThreadLastPostThread thread;
  final SubforumLastPostUser user;
  final int page;

  SubforumOldLastPost({
    this.id,
    this.createdAt,
    this.thread,
    this.user,
    this.page,
  });

  factory SubforumOldLastPost.fromJson(Map<String, dynamic> json) =>
      _$SubforumOldLastPostFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumOldLastPostToJson(this);
}

@JsonSerializable()
class SubForumLastPostThread {
  final int id;
  @JsonKey(name: 'post_count')
  final int postCount;
  @JsonKey(name: 'subforum_id')
  final int subforumId;
  final String title;
  final int page;

  SubForumLastPostThread({
    this.id,
    this.postCount,
    this.subforumId,
    this.title,
    this.page,
  });

  factory SubForumLastPostThread.fromJson(Map<String, dynamic> json) =>
      _$SubForumLastPostThreadFromJson(json);
  Map<String, dynamic> toJson() => _$SubForumLastPostThreadToJson(this);
}

@JsonSerializable()
class SubforumLastPostUser {
  final bool isBanned;
  final Usergroup usergroup;
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
