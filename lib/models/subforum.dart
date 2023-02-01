import 'package:knocky/models/subforumDetails.dart';

class Subforum {
  final int id;
  final String icon;
  final String name;
  final String description;
  final int totalPosts;
  final int totalThreads;
  final int lastPostId;
  final SubforumOldLastPost lastPost;

  Subforum({
    this.id,
    this.icon,
    this.name,
    this.description,
    this.totalPosts,
    this.totalThreads,
    this.lastPostId,
    this.lastPost,
  });

  factory Subforum.fromJson(Map<String, dynamic> json) => Subforum(
        id: json['id'] as int,
        icon: json['icon'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        totalPosts: json['totalPosts'] as int,
        totalThreads: json['totalThreads'] as int,
        lastPostId: json['lastPost_id'] as int,
        lastPost: json['lastPost'] == null
            ? null
            : SubforumOldLastPost.fromJson(
                json['lastPost'] as Map<String, dynamic>),
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'icon': icon,
        'name': name,
        'description': description,
        'totalPosts': totalPosts,
        'totalThreads': totalThreads,
        'lastPostId': lastPostId,
        'lastPost': lastPost,
      };
}

class SubforumLastPost {
  final DateTime createdAt;
  final int id;
  final int thread;
  final SubforumLastPostUser user;
  final int page;

  SubforumLastPost({
    this.id,
    this.createdAt,
    this.thread,
    this.user,
    this.page,
  });

  factory SubforumLastPost.fromJson(Map<String, dynamic> json) =>
      SubforumLastPost(
        id: json['id'] as int,
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        thread: json['thread'] as int,
        user: json['user'] == null
            ? null
            : SubforumLastPostUser.fromJson(
                json['user'] as Map<String, dynamic>),
        page: json['page'] as int,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt,
        'thread': thread,
        'user': user,
        'page': page,
      };
}

class SubforumOldLastPost {
  final DateTime createdAt;
  final int id;
  final SubforumThreadLastPostThread thread;
  final SubforumLastPostUser user;
  final int page;

  SubforumOldLastPost({
    this.id,
    this.createdAt,
    this.thread,
    this.user,
    this.page,
  });

  factory SubforumOldLastPost.fromJson(Map<String, dynamic> json) {
    return SubforumOldLastPost(
      id: json['id'] as int,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      thread: json['thread'] == null
          ? null
          : SubforumThreadLastPostThread.fromJson(
              json['thread'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : SubforumLastPostUser.fromJson(json['user'] as Map<String, dynamic>),
      page: json['page'] as int,
    );
  }
  Map<String, dynamic> toJson() => {
        'createdAt': createdAt?.toIso8601String(),
        'id': id,
        'thread': thread,
        'user': user,
        'page': page,
      };
}

class SubForumLastPostThread {
  final int id;
  final int postCount;
  final int subforumId;
  final String title;
  final int page;

  SubForumLastPostThread({
    this.id,
    this.postCount,
    this.subforumId,
    this.title,
    this.page,
  });

  factory SubForumLastPostThread.fromJson(Map<String, dynamic> json) {
    return SubForumLastPostThread(
      id: json['id'] as int,
      postCount: json['post_count'] as int,
      subforumId: json['subforum_id'] as int,
      title: json['title'] as String,
      page: json['page'] as int,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'post_count': postCount,
        'subforum_id': subforumId,
        'title': title,
        'page': page,
      };
}

class SubforumLastPostUser {
  final bool isBanned;
  final String username;

  SubforumLastPostUser({
    this.isBanned,
    this.username,
  });

  factory SubforumLastPostUser.fromJson(Map<String, dynamic> json) {
    return SubforumLastPostUser(
      isBanned: json['isBanned'] as bool,
      username: json['username'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'isBanned': isBanned,
        'username': username,
      };
}
