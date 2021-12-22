import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/thread.dart';

class NotificationModel {
  DateTime createdAt;
  int id;
  bool read;
  String type;
  int userId;
  NotificationPostReplyDataModel replyData;
  NotificationMessageDataModel messageData;

  NotificationModel(
      {this.createdAt,
      this.id,
      this.read,
      this.type,
      this.userId,
      this.replyData,
      this.messageData});

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
          createdAt: DateTime.parse(json['createdAt'] as String),
          id: json['id'] as int,
          read: json['read'] as bool,
          type: json['type'] as String,
          replyData: json['type'] == 'POST_REPLY'
              ? NotificationPostReplyDataModel.fromJson(
                  json['data'] as Map<String, dynamic>)
              : null,
          messageData: json['type'] == 'MESSAGE'
              ? NotificationMessageDataModel.fromJson(
                  json['data'] as Map<String, dynamic>)
              : null,
          userId: json['userId'] as int);

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'id': id,
        'read': read,
        'type': type,
        'replyData': replyData.toJson(),
        'messageData': messageData.toJson(),
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
  SubforumThread thread;
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
        thread: SubforumThread.fromJson(json['thread']),
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

class NotificationMessageDataModel {
  final int id;
  final List<NotificationMessageDataMessageModel> messages;
  final DateTime createdAt;
  final List<ThreadPostUser> users;

  NotificationMessageDataModel({
    this.createdAt,
    this.id,
    this.users,
    this.messages,
  });

  factory NotificationMessageDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationMessageDataModel(
      messages: (json['messages'] as List)
          ?.map((e) => e == null
              ? null
              : NotificationMessageDataMessageModel.fromJson(
                  e as Map<String, dynamic>))
          ?.toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      id: json['id'] as int,
      users: (json['users'] as List)
          ?.map((e) => e == null
              ? null
              : ThreadPostUser.fromJson(e as Map<String, dynamic>))
          ?.toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        'createdAt': createdAt?.toIso8601String(),
        'messages': messages,
        'id': id,
        'user': users,
      };
}

class NotificationMessageDataMessageModel {
  final int id;
  final String content;
  final int conversationId;
  final DateTime createdAt;
  final DateTime readAt;
  final DateTime updatedAt;
  final ThreadPostUser user;

  NotificationMessageDataMessageModel({
    this.content,
    this.conversationId,
    this.createdAt,
    this.id,
    this.readAt,
    this.updatedAt,
    this.user,
  });

  factory NotificationMessageDataMessageModel.fromJson(
      Map<String, dynamic> json) {
    return NotificationMessageDataMessageModel(
      content: json['content'] as String,
      conversationId: json['conversationId'] as int,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      id: json['id'] as int,
      user: ThreadPostUser.fromJson(json['user']),
    );
  }
  Map<String, dynamic> toJson() => {
        'createdAt': createdAt?.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'content': content,
        'conversationId': conversationId,
        'id': id,
        'user': user,
      };
}
