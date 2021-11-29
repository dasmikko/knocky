import 'package:knocky/models/slateDocument.dart';
import 'dart:convert';
import 'package:knocky/models/usergroup.dart';

class Thread {
  final int id;
  final int currentPage;
  final int iconId;
  final bool locked;
  final bool pinned;
  final int subforumId;
  final String subforumName;
  final String title;
  final int totalPosts;
  final DateTime readThreadLastSeen;
  final DateTime subscriptionLastSeen;
  final int subscriptionLastPostNumber;
  final List<ThreadPost> posts;
  final ThreadUser user;
  final int userId;
  final bool subscribed;
  final String threadBackgroundType;
  final String threadBackgroundUrl;

  Thread(
      {this.currentPage,
      this.iconId,
      this.readThreadLastSeen,
      this.id,
      this.locked,
      this.pinned,
      this.title,
      this.totalPosts,
      this.subforumId,
      this.subforumName,
      this.posts,
      this.user,
      this.subscriptionLastSeen,
      this.subscriptionLastPostNumber,
      this.subscribed,
      this.userId,
      this.threadBackgroundType,
      this.threadBackgroundUrl});

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      currentPage: json['currentPage'] as int,
      iconId: json['iconId'] as int,
      readThreadLastSeen: json['readThreadLastSeen'] == null
          ? null
          : DateTime.parse(json['readThreadLastSeen'] as String),
      id: json['id'] as int,
      locked: json['locked'] as bool,
      pinned: json['pinned'] as bool,
      title: json['title'] as String,
      totalPosts: json['totalPosts'] as int,
      subforumId: json['subforumId'] as int,
      subforumName: json['subforumName'] as String,
      posts: (json['posts'] as List)
          ?.map((e) =>
              e == null ? null : ThreadPost.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      user: json['user'] == null
          ? null
          : ThreadUser.fromJson(json['user'] as Map<String, dynamic>),
      subscriptionLastSeen: json['subscriptionLastSeen'] == null
          ? null
          : DateTime.parse(json['subscriptionLastSeen'] as String),
      subscribed:
          json['isSubscribedTo'] as bool ?? json['subscribed'] as bool ?? false,
      userId: json['userId'] as int,
      threadBackgroundType: json['threadBackgroundType'] as String,
      threadBackgroundUrl: json['threadBackgroundUrl'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'currentPage': currentPage,
        'iconId': iconId,
        'locked': locked,
        'pinned': pinned,
        'subforumId': subforumId,
        'subforumName': subforumName,
        'title': title,
        'totalPosts': totalPosts,
        'readThreadLastSeen': readThreadLastSeen?.toIso8601String(),
        'subscriptionLastSeen': subscriptionLastSeen?.toIso8601String(),
        'posts': posts,
        'user': user,
        'userId': userId,
        'isSubscribedTo': subscribed,
        'threadBackgroundType': threadBackgroundType,
        'threadBackgroundUrl': threadBackgroundUrl,
      };
}

class ThreadUser {
  final Usergroup usergroup;
  final String username;

  ThreadUser({this.usergroup, this.username});

  factory ThreadUser.fromJson(Map<String, dynamic> json) {
    return ThreadUser(
      usergroup: Usergroup.values[json['usergroup'] as int],
      username: json['username'] as String,
    );
  }

  factory ThreadUser.threadAlertUser(Map<String, dynamic> json) {
    return ThreadUser(
      usergroup: Usergroup.values[json['threadUserUsergroup'] as int],
      username: json['threadUsername'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'usergroup': usergroup,
        'username': username,
      };
}

class ThreadPost {
  final int id;
  final DateTime createdAt;
  final dynamic content;
  final ThreadPostUser user;
  final List<ThreadPostRatings> ratings;
  final List<ThreadPostBan> bans;
  final int threadPostNumber;
  final Thread thread;
  final int page;

  ThreadPost(
      {this.id,
      this.content,
      this.user,
      this.ratings,
      this.createdAt,
      this.bans,
      this.threadPostNumber,
      this.page,
      this.thread});

  factory ThreadPost.fromJson(Map<String, dynamic> json) {
    return ThreadPost(
        id: json['id'] as int,
        content: _contentFromJson(json['content'] as String),
        user: json['user'] == null
            ? null
            : ThreadPostUser.fromJson(json['user'] as Map<String, dynamic>),
        ratings: (json['ratings'] as List)
            ?.map((e) => e == null
                ? null
                : ThreadPostRatings.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        bans: (json['bans'] as List)
            ?.map((e) => e == null
                ? null
                : ThreadPostBan.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        threadPostNumber: json['threadPostNumber'] as int,
        page: json['page'] as int,
        thread:
            json.containsKey('thread') && json['thread'] is Map<String, dynamic>
                ? Thread.fromJson(json['thread'])
                : null);
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt?.toIso8601String(),
        'content': _contentToJson(content),
        'user': user,
        'ratings': ratings,
        'bans': bans,
        'threadPostNumber': threadPostNumber,
      };

  ThreadPost.clone(ThreadPost post)
      : this(
            id: post.id,
            content: post.content,
            user: post.user,
            ratings: post.ratings,
            createdAt: post.createdAt,
            bans: post.bans);
}

dynamic _contentFromJson(String jsonString) {
  try {
    SlateObject content = SlateObject.fromJson(json.decode(jsonString));
    return content;
  } catch (err) {
    return jsonString;
  }
}

Map _contentToJson(SlateObject slateObject) => slateObject.toJson();

class ThreadPostBan {
  final String banBannedBy;
  final DateTime banCreatedAt;
  final DateTime banExpiresAt;
  final int banPostId;
  final String banReason;

  ThreadPostBan({
    this.banBannedBy,
    this.banCreatedAt,
    this.banExpiresAt,
    this.banPostId,
    this.banReason,
  });

  factory ThreadPostBan.fromJson(Map<String, dynamic> json) {
    return ThreadPostBan(
      banBannedBy: json['banBannedBy'] as String,
      banCreatedAt: json['banCreatedAt'] == null
          ? null
          : DateTime.parse(json['banCreatedAt'] as String),
      banExpiresAt: json['banExpiresAt'] == null
          ? null
          : DateTime.parse(json['banExpiresAt'] as String),
      banPostId: json['banPostId'] as int,
      banReason: json['banReason'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'banBannedBy': banBannedBy,
        'banCreatedAt': banCreatedAt?.toIso8601String(),
        'banExpiresAt': banExpiresAt?.toIso8601String(),
        'banPostId': banPostId,
        'banReason': banReason,
      };
}

class ThreadPostRatings {
  final String ratingId;
  final String rating;
  final int count;
  final List<String> users;

  ThreadPostRatings({
    this.ratingId,
    this.rating,
    this.count,
    this.users,
  });

  factory ThreadPostRatings.fromJson(Map<String, dynamic> json) {
    // 'users' are just List<string> for thread posts,
    // but List<Map<string, dynamic>> for profile posts
    var users = (json['users'] as List)
        .map((user) => user is String ? user : user['username'] as String)
        .toList();
    return ThreadPostRatings(
      ratingId: _ratingIdHandler(json['rating_id']),
      rating: json['rating'] as String,
      count: json['count'] as int,
      users: users,
    );
  }
  Map<String, dynamic> toJson() => {
        'rating_id': ratingId,
        'rating': rating,
        'count': count,
        'users': users,
      };
}

String _ratingIdHandler(dynamic id) {
  if (id is int) return id.toString();
  return id;
}

class ThreadPostUser {
  final int id;
  final String avatarUrl;
  final String backgroundUrl;
  final bool isBanned;
  final Usergroup usergroup;
  final String username;

  ThreadPostUser(
      {this.id,
      this.avatarUrl,
      this.backgroundUrl,
      this.isBanned,
      this.usergroup,
      this.username});

  factory ThreadPostUser.fromJson(Map<String, dynamic> json) {
    return ThreadPostUser(
      id: json['id'] as int,
      avatarUrl: json['avatarUrl'] as String,
      backgroundUrl: json['backgroundUrl'] as String,
      isBanned: json['isBanned'] as bool,
      usergroup: Usergroup.values[json['usergroup'] as int],
      username: json['username'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'avatarUrl': avatarUrl,
        'backgroundUrl': backgroundUrl,
        'isBanned': isBanned,
        'usergroup': usergroup,
        'username': username,
      };
}
