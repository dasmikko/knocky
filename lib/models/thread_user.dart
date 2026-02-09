import 'package:json_annotation/json_annotation.dart';
import 'role.dart';

part 'thread_user.g.dart';

@JsonSerializable()
class ThreadUser {
  final int id;
  final Role role;
  final String username;
  @JsonKey(defaultValue: '')
  final String avatarUrl;
  @JsonKey(defaultValue: '')
  final String backgroundUrl;
  final int posts;
  final int threads;
  final String createdAt;
  final String updatedAt;
  final bool banned;
  final bool isBanned;
  final String? title;
  final String? pronouns;
  final int? useBioForTitle;
  final String? lastOnlineAt;
  final int? showOnlineStatus;
  final int? disableIncomingMessages;
  final bool? online;

  ThreadUser({
    required this.id,
    required this.role,
    required this.username,
    required this.avatarUrl,
    required this.backgroundUrl,
    required this.posts,
    required this.threads,
    required this.createdAt,
    required this.updatedAt,
    required this.banned,
    required this.isBanned,
    this.title,
    this.pronouns,
    this.useBioForTitle,
    this.lastOnlineAt,
    this.showOnlineStatus,
    this.disableIncomingMessages,
    this.online,
  });

  factory ThreadUser.fromJson(Map<String, dynamic> json) =>
      _$ThreadUserFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadUserToJson(this);
}
