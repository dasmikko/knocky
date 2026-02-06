import 'package:json_annotation/json_annotation.dart';
import 'post.dart';
import 'thread_user.dart';
import 'read_thread.dart';
import 'rating.dart';
import 'viewers.dart';

part 'thread.g.dart';

@JsonSerializable()
class Thread {
  final int id;
  final String title;
  final int iconId;
  final int subforumId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final bool deleted;
  final bool locked;
  final bool pinned;
  @JsonKey(fromJson: _postFromJson)
  final Post? lastPost;
  final String? backgroundUrl;
  final String? backgroundType;
  final ThreadUser user;
  final int postCount;
  final int recentPostCount;
  final ReadThread? readThread;
  final Rating? firstPostTopRating;
  final dynamic subforum;
  final List<dynamic> tags;
  final Viewers? viewers;

  Thread({
    required this.id,
    required this.title,
    required this.iconId,
    required this.subforumId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deleted,
    required this.locked,
    required this.pinned,
    this.lastPost,
    this.backgroundUrl,
    this.backgroundType,
    required this.user,
    required this.postCount,
    required this.recentPostCount,
    this.readThread,
    this.firstPostTopRating,
    this.subforum,
    required this.tags,
    this.viewers,
  });

  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadToJson(this);
}

Post? _postFromJson(dynamic json) {
  if (json == null) return null;
  if (json is Map<String, dynamic> && json.isEmpty) return null;
  return Post.fromJson(json as Map<String, dynamic>);
}
