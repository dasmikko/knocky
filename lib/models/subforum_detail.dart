import 'package:json_annotation/json_annotation.dart';

part 'subforum_detail.g.dart';

@JsonSerializable()
class SubforumDetail {
  final int id;
  final String name;
  final String description;
  final String icon;
  final Map<String, dynamic> lastPost;
  final int totalThreads;
  final int totalPosts;

  SubforumDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.lastPost,
    required this.totalThreads,
    required this.totalPosts,
  });

  factory SubforumDetail.fromJson(Map<String, dynamic> json) =>
      _$SubforumDetailFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumDetailToJson(this);
}
