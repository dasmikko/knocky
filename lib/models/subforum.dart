import 'package:json_annotation/json_annotation.dart';
import 'post.dart';

part 'subforum.g.dart';

@JsonSerializable()
class Subforum {
  final int id;
  final String name;
  final String description;
  final String icon;
  final int totalThreads;
  final int totalPosts;
  @JsonKey(fromJson: _postFromJson)
  final Post? lastPost;

  Subforum({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.totalThreads,
    required this.totalPosts,
    this.lastPost,
  });

  factory Subforum.fromJson(Map<String, dynamic> json) => _$SubforumFromJson(json);

  Map<String, dynamic> toJson() => _$SubforumToJson(this);
}

Post? _postFromJson(dynamic json) {
  if (json == null) return null;
  if (json is Map<String, dynamic> && json.isEmpty) return null;
  return Post.fromJson(json as Map<String, dynamic>);
}
