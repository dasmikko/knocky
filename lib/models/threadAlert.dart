import 'package:json_annotation/json_annotation.dart';

part 'threadAlert.g.dart';

@JsonSerializable()
class ThreadAlert {
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  @JsonKey(name: 'background_url')  
  final String backgroundUrl;
  final String email;
  final int firstUnreadId;
  @JsonKey(name: 'icon_id')
  final int iconId;
  final int id;
  @JsonKey(name: 'last_seen')
  final DateTime lastSeen;
  final int locked;
  final int pinned;
  @JsonKey(name: 'subforum_id')
  final int subforumId;
  final DateTime threadCreatedAt;
  @JsonKey(nullable: true)
  final DateTime threadDeletedAt;
  final String threadTitle;
  final DateTime threadUpdateAt;
  final int threadUser;
  final String threadUserAvatarUrl;
  final int threadUserUsergroup;
  final String threadUsername;
  @JsonKey(name: 'thread_id')
  final int threadId;
  final String title;
  final int unreadPosts;
  @JsonKey(nullable: true, name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'user_id')
  final int userId;
  final int usergroup;
  final String username;


  ThreadAlert({
    this.avatarUrl,
    this.backgroundUrl,
    this.email,
    this.firstUnreadId,
    this.iconId,
    this.id,
    this.lastSeen,
    this.locked,
    this.pinned,
    this.subforumId,
    this.threadCreatedAt,
    this.threadDeletedAt,
    this.threadTitle,
    this.threadUpdateAt,
    this.threadUser,
    this.username,
    this.threadId,
    this.threadUserAvatarUrl,
    this.threadUsername,
    this.threadUserUsergroup,
    this.title,
    this.unreadPosts,
    this.updatedAt,
    this.usergroup,
    this.userId
  });
  
  factory ThreadAlert.fromJson(Map<String, dynamic> json) => _$ThreadAlertFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadAlertToJson(this);
}