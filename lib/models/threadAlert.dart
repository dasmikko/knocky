import 'package:knocky/models/thread.dart';
import 'package:knocky/models/usergroup.dart';

class ThreadAlert {
  final int firstUnreadId;
  final String threadBackgroundUrl;
  final int postCount;
  final int id;
  final String title;
  final int unreadPostCount;
  final ThreadAlertLastPost lastPost;
  final int iconId;
  final String backgroundUrl;
  final bool locked;
  final ThreadUser user;

  ThreadAlert(
      {this.firstUnreadId,
      this.threadBackgroundUrl,
      this.id,
      this.title,
      this.unreadPostCount,
      this.lastPost,
      this.postCount,
      this.iconId,
      this.backgroundUrl,
      this.locked,
      this.user});

  factory ThreadAlert.fromJson(Map<String, dynamic> json) {
    return ThreadAlert(
      firstUnreadId: json['firstUnreadId'] as int,
      threadBackgroundUrl: json['threadBackgroundUrl'] as String,
      title: json['threadTitle'] as String,
      id: json['threadId'] as int,
      unreadPostCount: json['unreadPosts'] as int,
      lastPost: json['lastPost'] == null
          ? null
          : ThreadAlertLastPost.fromJson(
              json['lastPost'] as Map<String, dynamic>),
      postCount: json['threadPostCount'] as int,
      iconId: json['icon_id'] as int,
      backgroundUrl: json['threadBackgroundUrl'] as String,
      locked: json['threadLocked'] as bool,
      user: ThreadUser.threadAlertUser(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'firstUnreadId': firstUnreadId,
        'threadBackgroundUrl': threadBackgroundUrl,
        'threadTitle': title,
        'threadLocked': locked,
        'threadPostCount': postCount,
        'threadIcon': iconId,
        'threadId': id,
        'unreadPosts': unreadPostCount,
        'lastPost': lastPost,
      };
}

class ThreadAlertLastPost {
  final int id;
  final DateTime createdAt;
  final int thread;
  final int threadPostNumber;
  final int page;
  final ThreadAlertLastPostUser user;

  ThreadAlertLastPost(
      {this.createdAt,
      this.id,
      this.thread,
      this.threadPostNumber,
      this.page,
      this.user});

  factory ThreadAlertLastPost.fromJson(Map<String, dynamic> json) {
    return ThreadAlertLastPost(
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      id: json['id'] as int,
      thread: json['thread'] as int,
      threadPostNumber: json['threadPostNumber'] as int,
      page: json['page'] as int,
      user: json['user'] == null
          ? null
          : ThreadAlertLastPostUser.fromJson(
              json['user'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt?.toIso8601String(),
        'thread': thread,
        'threadPostNumber': threadPostNumber,
        'page': page,
        'user': user,
      };
}

class ThreadAlertLastPostThread {
  final int id;
  final DateTime createdAt;
  final String title;
  final int postCount;

  ThreadAlertLastPostThread(
      {this.createdAt, this.id, this.title, this.postCount});

  factory ThreadAlertLastPostThread.fromJson(Map<String, dynamic> json) {
    return ThreadAlertLastPostThread(
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      id: json['id'] as int,
      title: json['title'] as String,
      postCount: json['postCount'] as int,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt?.toIso8601String(),
        'title': title,
        'postCount': postCount,
      };
}

class ThreadAlertLastPostUser {
  final Usergroup usergroup;
  final String avatarUrl;
  final String username;

  ThreadAlertLastPostUser({this.usergroup, this.username, this.avatarUrl});

  factory ThreadAlertLastPostUser.fromJson(Map<String, dynamic> json) {
    return ThreadAlertLastPostUser(
      usergroup: Usergroup.values[json['usergroup'] as int],
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'usergroup': usergroup,
        'avatarUrl': avatarUrl,
        'username': username,
      };
}
