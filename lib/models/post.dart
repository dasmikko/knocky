import 'package:json_annotation/json_annotation.dart';
import 'thread_user.dart';
import 'post_thread_info.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final int id;
  final int threadId;
  final int page;
  final String content;
  final String createdAt;
  final String updatedAt;
  final int userId;
  final List<dynamic> ratings;
  final List<dynamic> bans;
  final int threadPostNumber;
  final String? countryName;
  final String? countryCode;
  final String? appName;
  final dynamic distinguished;
  final ThreadUser user;
  @JsonKey(fromJson: _threadFromJson, toJson: _threadToJson)
  final dynamic thread;

  /// Returns thread info if available (when thread is an object, not just an int)
  PostThreadInfo? get threadInfo {
    if (thread is PostThreadInfo) return thread as PostThreadInfo;
    return null;
  }

  /// Returns the thread ID regardless of whether thread is int or object
  int get threadIdValue {
    if (thread is int) return thread as int;
    if (thread is PostThreadInfo) return (thread as PostThreadInfo).id;
    return 0;
  }

  Post({
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
    required this.thread,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

/// Parses thread field which can be either int or object
dynamic _threadFromJson(dynamic json) {
  if (json == null) return 0;
  if (json is int) return json;
  if (json is Map<String, dynamic>) {
    return PostThreadInfo.fromJson(json);
  }
  return 0;
}

/// Serializes thread field
dynamic _threadToJson(dynamic thread) {
  if (thread is int) return thread;
  if (thread is PostThreadInfo) return thread.toJson();
  return 0;
}
