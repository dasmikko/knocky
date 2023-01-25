import 'package:knocky/models/subforum.dart';
import 'package:knocky/models/usergroup.dart';
import 'package:knocky/models/viewers.dart';

class SubforumDetails {
  final int id;
  final int currentPage;
  final int iconId;
  final String name;
  final int totalThreads;
  List<SubforumThread> threads = [];

  SubforumDetails(
      {this.id,
      this.currentPage,
      this.iconId,
      this.name,
      this.totalThreads,
      this.threads});

  factory SubforumDetails.fromJson(Map<String, dynamic> json) {
    return SubforumDetails(
      id: json['id'] as int,
      currentPage: json['currentPage'] as int,
      iconId: json['iconId'] as int,
      name: json['name'] as String,
      totalThreads: json['totalThreads'] as int,
      threads: (json['threads'] as List)
          ?.map((e) => e == null
              ? null
              : SubforumThread.fromJson(e as Map<String, dynamic>))
          ?.toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'currentPage': currentPage,
        'iconId': iconId,
        'name': name,
        'totalThreads': totalThreads,
        'threads': threads,
      };
}

class SubforumThread {
  final String backgroundUrl;
  final int firstUnreadId;
  final DateTime createdAt;
  final int iconId;
  final int id;
  final bool locked;
  final bool pinned;
  final int postCount;
  final int readThreadUnreadPosts;
  final int unreadPostCount;
  final String title;
  final int unreadType;
  final SubforumThreadUser user;
  final SubforumLastPost lastPost;
  final bool hasRead;
  final bool subscribed;
  final List<Map<int, String>> tags;

  SubforumThread(
      {this.backgroundUrl,
      this.createdAt,
      this.firstUnreadId,
      this.iconId,
      this.id,
      this.locked,
      this.pinned,
      this.postCount,
      this.readThreadUnreadPosts,
      this.unreadPostCount,
      this.title,
      this.unreadType,
      this.user,
      this.lastPost,
      this.hasRead,
      this.subscribed,
      this.tags});

  factory SubforumThread.fromJson(Map<String, dynamic> json) {
    return SubforumThread(
      backgroundUrl: json['backgroundUrl'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      firstUnreadId: json['firstUnreadId'] as int,
      iconId: json['iconId'] as int,
      id: json['id'] as int,
      locked: json['locked'] as bool,
      pinned: json['pinned'] as bool,
      postCount: json['postCount'] as int,
      readThreadUnreadPosts: json['readThreadUnreadPosts'] as int ?? 0,
      unreadPostCount: json['unreadPostCount'] as int ?? 0,
      title: json['title'] as String,
      unreadType: json['unreadType'] as int,
      user: json['user'] == null
          ? null
          : SubforumThreadUser.fromJson(json['user'] as Map<String, dynamic>),
      lastPost: json['lastPost'] == null
          ? null
          : SubforumLastPost.fromJson(json['lastPost'] as Map<String, dynamic>),
      hasRead: json['hasRead'] as bool,
      subscribed:
          json['subscribed'] == null ? false : json['subscribed'] as bool,
      tags: (json['tags'] as List)
          ?.map((e) => (e as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(int.parse(k), e as String),
              ))
          ?.toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        'backgroundUrl': backgroundUrl,
        'firstUnreadId': firstUnreadId,
        'createdAt': createdAt?.toIso8601String(),
        'iconId': iconId,
        'id': id,
        'locked': locked,
        'pinned': pinned,
        'postCount': postCount,
        'readThreadUnreadPosts': readThreadUnreadPosts,
        'unreadPostCount': unreadPostCount,
        'title': title,
        'unreadType': unreadType,
        'user': user,
        'lastPost': lastPost,
        'hasRead': hasRead,
        'subscribed': subscribed,
        'tags': tags
            ?.map((e) => e?.map((k, e) => MapEntry(k.toString(), e)))
            ?.toList(),
      };
}

class SignificantThread {
  final int firstUnreadId;
  final DateTime createdAt;
  final int iconId;
  final int id;
  final bool locked;
  final bool pinned;
  final bool read;
  final int postCount;
  final int readThreadUnreadPosts;
  final int unreadPostCount;
  final String title;
  final int unreadType;
  final SubforumThreadUser user;
  final int userId;
  final SubforumLastPost lastPost;
  final int subforumId;
  final String backgroundUrl;
  final Viewers viewers;

  SignificantThread(
      {this.createdAt,
      this.firstUnreadId,
      this.iconId,
      this.id,
      this.locked,
      this.pinned,
      this.read,
      this.postCount,
      this.readThreadUnreadPosts,
      this.unreadPostCount,
      this.title,
      this.unreadType,
      this.user,
      this.userId,
      this.lastPost,
      this.backgroundUrl,
      this.viewers,
      this.subforumId});

  factory SignificantThread.fromJson(Map<String, dynamic> json) {
    return SignificantThread(
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      firstUnreadId: json['firstUnreadId'] as int,
      iconId: json['iconId'] as int,
      id: json['id'] as int,
      locked: json['locked'] as bool,
      pinned: json['pinned'] as bool,
      read: json['read'] as bool,
      postCount: json['postCount'] as int,
      readThreadUnreadPosts: json['readThreadUnreadPosts'] as int ?? 0,
      unreadPostCount: json['unreadPostCount'] as int ?? 0,
      title: json['title'] as String,
      unreadType: json['unreadType'] as int,
      subforumId: json['subforumId'] as int,
      user: json["user"] == null || json['user'] is int
          ? null
          : SubforumThreadUser.fromJson(json['user'] as Map<String, dynamic>),
      userId: json["user"] != null && json['user'] is int ? json["user"] : null,
      lastPost: json['lastPost'] == null
          ? null
          : SubforumLastPost.fromJson(json['lastPost'] as Map<String, dynamic>),
      backgroundUrl: json['backgroundUrl'] as String,
      viewers: json['viewers'] == null
          ? null
          : Viewers.fromJson(json['viewers'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() => {
        'firstUnreadId': firstUnreadId,
        'createdAt': createdAt?.toIso8601String(),
        'iconId': iconId,
        'id': id,
        'locked': locked,
        'pinned': pinned,
        'postCount': postCount,
        'readThreadUnreadPosts': readThreadUnreadPosts,
        'unreadPostCount': unreadPostCount,
        'title': title,
        'unreadType': unreadType,
        'user': user.toJson(),
        'userId': userId,
        'lastPost': lastPost,
        'backgroundUrl': backgroundUrl,
        'viewers': viewers,
      };
}

class SubforumThreadUser {
  final Usergroup usergroup;
  final String avatarUrl;
  final String username;
  final bool isBanned;

  SubforumThreadUser(
      {this.usergroup, this.username, this.avatarUrl, this.isBanned});

  factory SubforumThreadUser.fromJson(Map<String, dynamic> json) {
    return SubforumThreadUser(
      usergroup: Usergroup.values[json['usergroup'] as int],
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String,
      isBanned: json['isBanned'] as bool,
    );
  }
  Map<String, dynamic> toJson() => {
        'usergroup': usergroup,
        'avatar_url': avatarUrl,
        'username': username,
        'isBanned': isBanned,
      };
}

class SubforumThreadLastPost {
  final int id;
  final DateTime createdAt;
  final SubforumThreadLastPostThread thread;
  final SubforumThreadLastPostUser user;

  SubforumThreadLastPost({this.createdAt, this.id, this.thread, this.user});

  factory SubforumThreadLastPost.fromJson(Map<String, dynamic> json) {
    return SubforumThreadLastPost(
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      id: json['id'] as int,
      thread: json['thread'] == null
          ? null
          : SubforumThreadLastPostThread.fromJson(
              json['thread'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : SubforumThreadLastPostUser.fromJson(
              json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt?.toIso8601String(),
        'thread': thread,
        'user': user,
      };
}

class SubforumThreadLastPostThread {
  final int id;
  final DateTime createdAt;
  final String title;
  final int postCount;
  final SubforumLastpostThreadLastpost lastPost;

  SubforumThreadLastPostThread(
      {this.createdAt, this.id, this.title, this.postCount, this.lastPost});

  factory SubforumThreadLastPostThread.fromJson(Map<String, dynamic> json) {
    return SubforumThreadLastPostThread(
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      id: json['id'] as int,
      title: json['title'] as String,
      postCount: json['post_count'] as int,
      lastPost: json['lastPost'] == null
          ? null
          : SubforumLastpostThreadLastpost.fromJson(
              json['lastPost'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt?.toIso8601String(),
        'title': title,
        'post_count': postCount,
        'lastPost': lastPost,
      };
}

class SubforumThreadLastPostUser {
  final Usergroup usergroup;
  final String avatarUrl;
  final String username;

  SubforumThreadLastPostUser({this.usergroup, this.username, this.avatarUrl});

  factory SubforumThreadLastPostUser.fromJson(Map<String, dynamic> json) {
    return SubforumThreadLastPostUser(
      usergroup: Usergroup.values[json['usergroup'] as int],
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'usergroup': usergroup,
        'avatar_url': avatarUrl,
        'username': username,
      };
}

class SubforumLastpostThreadLastpost {
  final DateTime createdAt;
  final int id;
  final int thread;
  final String content;
  final SubforumLastPostUser user;
  final int page;

  SubforumLastpostThreadLastpost(
      {this.id,
      this.createdAt,
      this.thread,
      this.user,
      this.page,
      this.content});

  factory SubforumLastpostThreadLastpost.fromJson(Map<String, dynamic> json) {
    return SubforumLastpostThreadLastpost(
      id: json['id'] as int,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      thread: json['thread'] as int,
      user: json['user'] == null
          ? null
          : SubforumLastPostUser.fromJson(json['user'] as Map<String, dynamic>),
      page: json['page'] as int,
      content: json['content'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'created_at': createdAt?.toIso8601String(),
        'id': id,
        'thread': thread,
        'content': content,
        'user': user,
        'page': page,
      };
}
