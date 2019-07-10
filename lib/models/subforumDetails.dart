import 'package:json_annotation/json_annotation.dart';
import 'package:knocky/models/subforum.dart';

part 'subforumDetails.g.dart';

@JsonSerializable()
class SubforumDetails {
  final int id;
  final int currentPage;
  final int iconId;
  final String name;
  final int totalThreads;
  List<SubforumThread> threads;

  SubforumDetails(
      {this.id,
      this.currentPage,
      this.iconId,
      this.name,
      this.totalThreads,
      this.threads});

  factory SubforumDetails.fromJson(Map<String, dynamic> json) =>
      _$SubforumDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumDetailsToJson(this);
}

@JsonSerializable()
class SubforumThread {
  final int firstUnreadId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'icon_id')
  final int iconId;
  final int id;
  final int locked;
  final int pinned;
  final int postCount;
  @JsonKey(defaultValue: 0)
  final int readThreadUnreadPosts;
  final String title;
  final int unreadType;
  final SubforumThreadUser user;
  final SubforumLastPost lastPost;

  SubforumThread({
    this.createdAt,
    this.firstUnreadId,
    this.iconId,
    this.id,
    this.locked,
    this.pinned,
    this.postCount,
    this.readThreadUnreadPosts,
    this.title,
    this.unreadType,
    this.user,
    this.lastPost
  });

  factory SubforumThread.fromJson(Map<String, dynamic> json) =>
      _$SubforumThreadFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumThreadToJson(this);
}

@JsonSerializable()
class SubforumThreadUser {
  final int usergroup;
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  final String username;
  final bool isBanned;

  SubforumThreadUser(
      {this.usergroup, this.username, this.avatarUrl, this.isBanned});

  factory SubforumThreadUser.fromJson(Map<String, dynamic> json) =>
      _$SubforumThreadUserFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumThreadUserToJson(this);
}

@JsonSerializable()
class SubforumThreadLastPost {
  final int id;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final SubforumThreadLastPostThread thread;
  final SubforumThreadLastPostUser user;

  SubforumThreadLastPost({
    this.createdAt,
    this.id,
    this.thread,
    this.user
  });

  factory SubforumThreadLastPost.fromJson(Map<String, dynamic> json) => _$SubforumThreadLastPostFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumThreadLastPostToJson(this);
}

@JsonSerializable()
class SubforumThreadLastPostThread {
  final int id;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final String title;
  @JsonKey(name: 'post_count')
  final int postCount;

  SubforumThreadLastPostThread({
    this.createdAt,
    this.id,
    this.title,
    this.postCount  
  });

  factory SubforumThreadLastPostThread.fromJson(Map<String, dynamic> json) => _$SubforumThreadLastPostThreadFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumThreadLastPostThreadToJson(this);
}

@JsonSerializable()
class SubforumThreadLastPostUser {
  final int usergroup;
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  final String username;

  SubforumThreadLastPostUser({
    this.usergroup,
    this.username,
    this.avatarUrl
  });

  factory SubforumThreadLastPostUser.fromJson(Map<String, dynamic> json) => _$SubforumThreadLastPostUserFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumThreadLastPostUserToJson(this);
}
