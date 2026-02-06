import 'package:json_annotation/json_annotation.dart';
import 'thread_post.dart';
import 'thread_user.dart';
import 'read_thread.dart';
import 'subforum.dart';
import 'viewers.dart';

part 'thread_response.g.dart';

@JsonSerializable()
class ThreadResponse {
  final int id;
  final String title;
  final bool locked;
  final bool pinned;
  final bool deleted;
  final int iconId;
  final int subforumId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? threadBackgroundUrl;
  final String? threadBackgroundType;
  final int totalPosts;
  final int currentPage;
  final List<ThreadPost> posts;
  final ThreadUser? user;
  final ReadThread? readThread;
  final Subforum? subforum;
  final Viewers? viewers;
  final List<dynamic> tags;

  ThreadResponse({
    required this.id,
    required this.title,
    required this.locked,
    required this.pinned,
    this.deleted = false,
    this.iconId = 0,
    this.subforumId = 0,
    this.createdAt = '',
    this.updatedAt = '',
    this.deletedAt,
    this.threadBackgroundUrl,
    this.threadBackgroundType,
    required this.totalPosts,
    required this.currentPage,
    required this.posts,
    this.user,
    this.readThread,
    this.subforum,
    this.viewers,
    this.tags = const [],
  });

  int get totalPages => (totalPosts / 20).ceil();

  factory ThreadResponse.fromJson(Map<String, dynamic> json) =>
      _$ThreadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadResponseToJson(this);
}
