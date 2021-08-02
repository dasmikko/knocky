import 'package:json_annotation/json_annotation.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/models/usergroup.dart';

part 'threadAlert.g.dart';

@JsonSerializable()
class ThreadAlert {
  final int firstUnreadId;
  @JsonKey(nullable: true)
  final String threadBackgroundUrl;
  final int postCount;
  final int id;
  final String title;
  final int unreadPostCount;
  final ThreadAlertLastPost lastPost;
  final int iconId;
  final String backgroundUrl;
  @JsonKey(nullable: true)
  final bool locked;
  final ThreadUser user;

  ThreadAlert(
      {this.firstUnreadId,
      this.threadBackgroundUrl,
      this.id,
      this.title,
      this.unreadPostCount,
      this.lastPost,
      this.postCount,
      this.iconId,
      this.backgroundUrl,
      this.locked,
      this.user});

  factory ThreadAlert.fromJson(Map<String, dynamic> json) =>
      _$ThreadAlertFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadAlertToJson(this);
}

@JsonSerializable()
class ThreadAlertLastPost {
  final int id;
  final DateTime createdAt;
  final int thread;
  final int threadPostNumber;
  final int page;
  final ThreadAlertLastPostUser user;

  ThreadAlertLastPost(
      {this.createdAt,
      this.id,
      this.thread,
      this.threadPostNumber,
      this.page,
      this.user});

  factory ThreadAlertLastPost.fromJson(Map<String, dynamic> json) =>
      _$ThreadAlertLastPostFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadAlertLastPostToJson(this);
}

@JsonSerializable()
class ThreadAlertLastPostThread {
  final int id;
  final DateTime createdAt;
  final String title;
  final int postCount;

  ThreadAlertLastPostThread(
      {this.createdAt, this.id, this.title, this.postCount});

  factory ThreadAlertLastPostThread.fromJson(Map<String, dynamic> json) =>
      _$ThreadAlertLastPostThreadFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadAlertLastPostThreadToJson(this);
}

@JsonSerializable()
class ThreadAlertLastPostUser {
  final Usergroup usergroup;
  final String avatarUrl;
  final String username;

  ThreadAlertLastPostUser({this.usergroup, this.username, this.avatarUrl});

  factory ThreadAlertLastPostUser.fromJson(Map<String, dynamic> json) =>
      _$ThreadAlertLastPostUserFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadAlertLastPostUserToJson(this);
}
