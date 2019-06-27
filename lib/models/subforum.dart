import 'package:json_annotation/json_annotation.dart';

part 'subforum.g.dart';

@JsonSerializable()
class Subforum {
  final int id;
  final String icon;
  final String name;
  final String description;
  final int totalPosts;
  final int totalThreads;

  Subforum({this.id, this.icon, this.name, this.description, this.totalPosts, this.totalThreads});

  factory Subforum.fromJson(Map<String, dynamic> json) => _$SubforumFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumToJson(this);
}