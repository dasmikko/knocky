import 'package:json_annotation/json_annotation.dart';
import 'package:knocky/models/thread.dart';

part 'userProfilePosts.g.dart';

@JsonSerializable()
class UserProfilePosts {
  final int currentPage;
  final int totalPosts;
  final List<ThreadPost> posts;

  UserProfilePosts({
    this.currentPage,
    this.totalPosts,
    this.posts
  });

  factory UserProfilePosts.fromJson(Map<String, dynamic> json) =>
      _$UserProfilePostsFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfilePostsToJson(this);
}
