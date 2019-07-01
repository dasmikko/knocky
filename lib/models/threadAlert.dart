import 'package:json_annotation/json_annotation.dart';

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
    this.threadUser
  });


}