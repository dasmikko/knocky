import 'package:json_annotation/json_annotation.dart';

part 'threadAlert.g.dart';

@JsonSerializable()
class ThreadAlert {
  final int firstUnreadId;
  @JsonKey(nullable: true)
  final String threadBackgroundUrl;
  @JsonKey(nullable: true)
  final String threadTitle;
  final int threadUser;
  final bool threadLocked;
  final int threadPostCount;
  final String threadUserAvatarUrl;
  final int threadUserUsergroup;
  final int threadIcon;
  final String threadUsername;
  final int threadId;
  final String title;
  final int unreadPosts;
  final ThreadAlertLastPost lastPost;

  ThreadAlert(
      {this.firstUnreadId,
      this.threadBackgroundUrl,
      this.threadTitle,
      this.threadUser,
      this.threadId,
      this.threadUserAvatarUrl,
      this.threadUsername,
      this.threadUserUsergroup,
      this.threadLocked,
      this.threadIcon,
      this.title,
      this.unreadPosts,
      this.lastPost,
      this.threadPostCount});

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
  final int usergroup;
  final String avatarUrl;
  final String username;

  ThreadAlertLastPostUser({this.usergroup, this.username, this.avatarUrl});

  factory ThreadAlertLastPostUser.fromJson(Map<String, dynamic> json) =>
      _$ThreadAlertLastPostUserFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadAlertLastPostUserToJson(this);
}
