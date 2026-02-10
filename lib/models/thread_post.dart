import 'package:json_annotation/json_annotation.dart';
import 'ban.dart';
import 'thread_user.dart';

part 'thread_post.g.dart';

@JsonSerializable()
class ThreadPost {
  final int id;
  final int threadId;
  final int page;
  final String content;
  final String createdAt;
  final String updatedAt;
  final int userId;
  final List<dynamic> ratings;
  final List<Ban> bans;
  final int threadPostNumber;
  final String? countryName;
  final String? countryCode;
  final String? appName;
  final dynamic distinguished;
  final ThreadUser user;
  final List<dynamic> responses;
  final List<dynamic> mentionUsers;
  final ThreadUser? lastEditedUser;

  ThreadPost({
    required this.id,
    required this.threadId,
    required this.page,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.ratings,
    required this.bans,
    required this.threadPostNumber,
    this.countryName,
    this.countryCode,
    this.appName,
    this.distinguished,
    required this.user,
    required this.responses,
    required this.mentionUsers,
    this.lastEditedUser,
  });

  factory ThreadPost.fromJson(Map<String, dynamic> json) =>
      _$ThreadPostFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadPostToJson(this);
}
