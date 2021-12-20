import 'package:knocky/models/thread.dart';
import 'package:knocky/models/userProfileRatings.dart';
import 'package:knocky/widgets/profile/ratings.dart';

class NotificationModel {
  DateTime createdAt;
  int id;
  bool read;
  String type;
  int userId;
  NotificationDataModel data;

  NotificationModel(
      {this.createdAt, this.id, this.read, this.type, this.userId});

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
          createdAt: DateTime.parse(json['createdAt'] as String),
          id: json['id'] as int,
          read: json['read'] as bool,
          type: json['type'] as String,
          userId: json['userId'] as int);

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'id': id,
        'read': read,
        'type': type,
        'userId': userId
      };
}

class NotificationDataModel {
  String appName;
  String content;
  String countryCode;
  String contryName;
  DateTime createdAt;
  DateTime updatedAt;
  int id;
  int page;
  List<ThreadPostRatings> ratings;
  Thread thread;
  int threadPostNumber;
  ThreadUser user;

  NotificationDataModel(
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

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) =>
      NotificationDataModel(
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
        thread: Thread.fromJson(json['thread']),
        threadPostNumber: json['threadPostNumber'] as int,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        user: ThreadUser.fromJson(json['user']),
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
