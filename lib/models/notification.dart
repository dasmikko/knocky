import 'package:knocky/models/subforum.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/models/userProfileRatings.dart';
import 'package:knocky/widgets/profile/ratings.dart';

class NotificationModel {
  DateTime createdAt;
  int id;
  bool read;
  String type;
  int userId;
  dynamic data;

  NotificationModel(
      {this.createdAt, this.id, this.read, this.type, this.userId, this.data});

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
          createdAt: DateTime.parse(json['createdAt'] as String),
          id: json['id'] as int,
          read: json['read'] as bool,
          type: json['type'] as String,
          data: json['type'] == 'POST_REPLY'
              ? NotificationPostReplyDataModel.fromJson(
                  json['data'] as Map<String, dynamic>)
              : null,
          userId: json['userId'] as int);

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'id': id,
        'read': read,
        'type': type,
        'data': data.toJson(),
        'userId': userId
      };
}

class NotificationPostReplyDataModel {
  String appName;
  String content;
  String countryCode;
  String contryName;
  DateTime createdAt;
  DateTime updatedAt;
  int id;
  int page;
  List<ThreadPostRatings> ratings;
  NotificationDataThread thread;
  int threadPostNumber;
  ThreadPostUser user;

  NotificationPostReplyDataModel(
      {this.createdAt,
      this.id,
      this.appName,
      this.content,
      this.contryName,
      this.countryCode,
      this.page,
      this.ratings,
      this.thread,
      this.threadPostNumber,
      this.updatedAt,
      this.user});

  factory NotificationPostReplyDataModel.fromJson(Map<String, dynamic> json) =>
      NotificationPostReplyDataModel(
        createdAt: DateTime.parse(json['createdAt'] as String),
        id: json['id'] as int,
        appName: json['appName'] as String,
        content: json['content'] as String,
        countryCode: json['countryCode'] as String,
        page: json['page'] as int,
        ratings: (json['ratings'] as List)
            ?.map((e) => e == null
                ? null
                : ThreadPostRatings.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        thread: NotificationDataThread.fromJson(json['thread']),
        threadPostNumber: json['threadPostNumber'] as int,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        user: ThreadPostUser.fromJson(json['user']),
      );

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'id': id,
        'appName': appName,
        'content': content,
        'countryCode': countryCode,
        'page': page,
        'ratings': ratings,
        'thread': thread.toJson(),
        'threadPostNumber': threadPostNumber,
        'updatedAt': updatedAt.toIso8601String(),
        'user': user.toJson(),
      };
}

class NotificationDataThread {
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

  NotificationDataThread(
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

  factory NotificationDataThread.fromJson(Map<String, dynamic> json) {
    return NotificationDataThread(
      backgroundUrl:
          json['backgroundUrl'] == null ? '' : json['backgroundUrl'] as String,
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
      subscribed: json['subscribed'] as bool,
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
