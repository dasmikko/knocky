import 'package:json_annotation/json_annotation.dart';

part 'threadAlert.g.dart';

@JsonSerializable()
class ThreadAlert {
  final int firstUnreadId;
  @JsonKey(nullable: true)
  final String threadBackgroundUrl;
  @JsonKey(name: 'icon_id')
  final int iconId;
  final DateTime threadCreatedAt;
  @JsonKey(nullable: true)
  final DateTime threadDeletedAt;
  final String threadTitle;
  final DateTime threadUpdateAt;
  final int threadUser;
  final int threadPostCount;
  final String threadUserAvatarUrl;
  final int threadUserUsergroup;
  final String threadUsername;
  final int threadId;
  final String title;
  final int unreadPosts;
  @JsonKey(nullable: true, name: 'updated_at')
  final DateTime updatedAt;
  final ThreadAlertLastPost lastPost;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ThreadAlert(
      {this.firstUnreadId,
      this.threadBackgroundUrl,
      this.iconId,
      this.threadCreatedAt,
      this.threadDeletedAt,
      this.threadTitle,
      this.threadUpdateAt,
      this.threadUser,
      this.threadId,
      this.threadUserAvatarUrl,
      this.threadUsername,
      this.threadUserUsergroup,
      this.title,
      this.unreadPosts,
      this.updatedAt,
      this.lastPost,
      this.createdAt,
      this.threadPostCount});

  factory ThreadAlert.fromJson(Map<String, dynamic> json) =>
      _$ThreadAlertFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadAlertToJson(this);
}

@JsonSerializable()
class ThreadAlertLastPost {
  final int id;
  @JsonKey(name: 'created_at')
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
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final String title;
  @JsonKey(name: 'post_count')
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
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  final String username;

  ThreadAlertLastPostUser({this.usergroup, this.username, this.avatarUrl});

  factory ThreadAlertLastPostUser.fromJson(Map<String, dynamic> json) =>
      _$ThreadAlertLastPostUserFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadAlertLastPostUserToJson(this);
}
