import 'package:knocky/models/thread.dart';

class UserProfilePosts {
  final int? currentPage;
  final int? totalPosts;
  final List<ThreadPost>? posts;

  UserProfilePosts({this.currentPage, this.totalPosts, this.posts});

  factory UserProfilePosts.fromJson(Map<String, dynamic> json) {
    return UserProfilePosts(
      currentPage: json['currentPage'] as int?,
      totalPosts: json['totalPosts'] as int?,
      posts: json['posts'] == null
          ? null
          : List<ThreadPost>.from(
              json['posts'].map(
                (x) => ThreadPost.fromJson(x),
              ),
            ),
    );
  }
  Map<String, dynamic> toJson() => {
        'currentPage': currentPage,
        'totalPosts': totalPosts,
        'posts': posts,
      };
}
