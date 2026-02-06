import 'package:json_annotation/json_annotation.dart';
import 'post.dart';

part 'sync_subscription.g.dart';

@JsonSerializable()
class SyncSubscription {
  final int id;
  final int unreadPosts;
  final int firstUnreadId;
  final int threadId;
  @JsonKey(name: 'icon_id')
  final int? iconId;
  final int? threadIcon;
  final String threadTitle;
  final int threadUser;
  final bool threadLocked;
  final String threadCreatedAt;
  final String threadUpdatedAt;
  final dynamic threadDeletedAt;
  final String? threadBackgroundUrl;
  final String? threadBackgroundType;
  final String threadUsername;
  final String threadUserAvatarUrl;
  final String threadUserRoleCode;
  final int threadPostCount;
  final Post? lastPost;

  SyncSubscription({
    required this.id,
    required this.unreadPosts,
    required this.firstUnreadId,
    required this.threadId,
    this.iconId,
    this.threadIcon,
    required this.threadTitle,
    required this.threadUser,
    required this.threadLocked,
    required this.threadCreatedAt,
    required this.threadUpdatedAt,
    this.threadDeletedAt,
    this.threadBackgroundUrl,
    this.threadBackgroundType,
    required this.threadUsername,
    required this.threadUserAvatarUrl,
    required this.threadUserRoleCode,
    required this.threadPostCount,
    this.lastPost,
  });

  factory SyncSubscription.fromJson(Map<String, dynamic> json) =>
      _$SyncSubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$SyncSubscriptionToJson(this);
}
