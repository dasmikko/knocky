import 'package:json_annotation/json_annotation.dart';
import 'post.dart';

part 'user_posts_response.g.dart';

@JsonSerializable()
class UserPostsResponse {
  final int totalPosts;
  final int currentPage;
  final List<Post> posts;

  /// Calculate total pages (20 posts per page)
  int get totalPages => (totalPosts / 20).ceil();

  UserPostsResponse({
    required this.totalPosts,
    required this.currentPage,
    required this.posts,
  });

  factory UserPostsResponse.fromJson(Map<String, dynamic> json) =>
      _$UserPostsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserPostsResponseToJson(this);
}