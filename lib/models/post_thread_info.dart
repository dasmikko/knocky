import 'package:json_annotation/json_annotation.dart';

part 'post_thread_info.g.dart';

/// Lightweight thread info embedded in posts (used in subforum lastPost)
@JsonSerializable()
class PostThreadInfo {
  final int id;
  final String title;
  final int iconId;
  final int subforumId;
  final String createdAt;
  final String updatedAt;

  PostThreadInfo({
    required this.id,
    required this.title,
    required this.iconId,
    required this.subforumId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostThreadInfo.fromJson(Map<String, dynamic> json) =>
      _$PostThreadInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PostThreadInfoToJson(this);
}
