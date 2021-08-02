import 'package:json_annotation/json_annotation.dart';
import 'package:knocky/models/subforum.dart';
import 'package:knocky/models/usergroup.dart';
import 'package:knocky/models/viewers.dart';

part 'subforumDetails.g.dart';

@JsonSerializable()
class SubforumDetails {
  final int id;
  final int currentPage;
  final int iconId;
  final String name;
  final int totalThreads;
  List<SubforumThread> threads = [];

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
  final String backgroundUrl;
  final int firstUnreadId;
  final DateTime createdAt;
  final int iconId;
  final int id;
  final bool locked;
  final bool pinned;
  final int postCount;
  @JsonKey(defaultValue: 0)
  final int readThreadUnreadPosts;
  @JsonKey(defaultValue: 0)
  final int unreadPostCount;
  final String title;
  final int unreadType;
  final SubforumThreadUser user;
  final SubforumLastPost lastPost;
  final bool hasRead;
  final bool subscribed;
  final List<Map<int, String>> tags;

  SubforumThread(
      {this.backgroundUrl,
      this.createdAt,
      this.firstUnreadId,
      this.iconId,
      this.id,
      this.locked,
      this.pinned,
      this.postCount,
      this.readThreadUnreadPosts,
      this.unreadPostCount,
      this.title,
      this.unreadType,
      this.user,
      this.lastPost,
      this.hasRead,
      this.subscribed,
      this.tags});

  factory SubforumThread.fromJson(Map<String, dynamic> json) =>
      _$SubforumThreadFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumThreadToJson(this);
}

@JsonSerializable()
class SignificantThread {
  final int firstUnreadId;
  final DateTime createdAt;
  final int iconId;
  final int id;
  final bool locked;
  final bool pinned;
  final int postCount;
  @JsonKey(defaultValue: 0)
  final int readThreadUnreadPosts;
  @JsonKey(defaultValue: 0)
  final int unreadPostCount;
  final String title;
  final int unreadType;
  final SubforumThreadUser user;
  final SubforumLastPost lastPost;
  final String backgroundUrl;
  final Viewers viewers;

  SignificantThread(
      {this.createdAt,
      this.firstUnreadId,
      this.iconId,
      this.id,
      this.locked,
      this.pinned,
      this.postCount,
      this.readThreadUnreadPosts,
      this.unreadPostCount,
      this.title,
      this.unreadType,
      this.user,
      this.lastPost,
      this.backgroundUrl,
      this.viewers});

  factory SignificantThread.fromJson(Map<String, dynamic> json) =>
      _$SignificantThreadFromJson(json);
  Map<String, dynamic> toJson() => _$SignificantThreadToJson(this);
}

@JsonSerializable()
class SubforumThreadUser {
  final Usergroup usergroup;
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

  SubforumThreadLastPost({this.createdAt, this.id, this.thread, this.user});

  factory SubforumThreadLastPost.fromJson(Map<String, dynamic> json) =>
      _$SubforumThreadLastPostFromJson(json);
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
  final SubforumLastpostThreadLastpost lastPost;

  SubforumThreadLastPostThread(
      {this.createdAt, this.id, this.title, this.postCount, this.lastPost});

  factory SubforumThreadLastPostThread.fromJson(Map<String, dynamic> json) =>
      _$SubforumThreadLastPostThreadFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumThreadLastPostThreadToJson(this);
}

@JsonSerializable()
class SubforumThreadLastPostUser {
  final Usergroup usergroup;
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  final String username;

  SubforumThreadLastPostUser({this.usergroup, this.username, this.avatarUrl});

  factory SubforumThreadLastPostUser.fromJson(Map<String, dynamic> json) =>
      _$SubforumThreadLastPostUserFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumThreadLastPostUserToJson(this);
}

@JsonSerializable()
class SubforumLastpostThreadLastpost {
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final int id;
  final int thread;
  final String content;
  final SubforumLastPostUser user;
  final int page;

  SubforumLastpostThreadLastpost(
      {this.id,
      this.createdAt,
      this.thread,
      this.user,
      this.page,
      this.content});

  factory SubforumLastpostThreadLastpost.fromJson(Map<String, dynamic> json) =>
      _$SubforumLastpostThreadLastpostFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumLastpostThreadLastpostToJson(this);
}
