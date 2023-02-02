// To parse this JSON data, do
//
//     final syncData = syncDataFromJson(jsonString);

import 'dart:convert';

import 'package:knocky/models/v2/lastpost.dart';
import 'package:knocky/models/v2/userRole.dart';

SyncData syncDataFromJson(String str) => SyncData.fromJson(json.decode(str));

String syncDataToJson(SyncData data) => json.encode(data.toJson());

class SyncData {
  SyncData({
    this.id,
    this.username,
    this.isBanned,
    this.avatarUrl,
    this.backgroundUrl,
    this.createdAt,
    this.mentions,
    this.subscriptions,
    this.subscriptionIds,
    this.role,
  });

  int? id;
  String? username;
  bool? isBanned;
  String? avatarUrl;
  String? backgroundUrl;
  DateTime? createdAt;
  List<dynamic>? mentions;
  List<Subscription>? subscriptions;
  List<int>? subscriptionIds;
  UserRole? role;

  factory SyncData.fromRawJson(String str) =>
      SyncData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SyncData.fromJson(Map<String, dynamic> json) => SyncData(
        id: json["id"],
        username: json["username"],
        isBanned: json["isBanned"],
        avatarUrl: json["avatarUrl"],
        backgroundUrl: json["backgroundUrl"],
        createdAt: DateTime.parse(json["createdAt"]),
        mentions: List<dynamic>.from(json["mentions"].map((x) => x)),
        subscriptions: List<Subscription>.from(
            json["subscriptions"].map((x) => Subscription.fromJson(x))),
        subscriptionIds: List<int>.from(json["subscriptionIds"].map((x) => x)),
        role: UserRole.fromJson(json["role"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "isBanned": isBanned,
        "avatarUrl": avatarUrl,
        "backgroundUrl": backgroundUrl,
        "createdAt": createdAt!.toIso8601String(),
        "mentions": List<dynamic>.from(mentions!.map((x) => x)),
        "subscriptions":
            List<dynamic>.from(subscriptions!.map((x) => x.toJson())),
        "subscriptionIds": List<dynamic>.from(subscriptionIds!.map((x) => x)),
        "role": role!.toJson(),
      };
}

class Subscription {
  Subscription({
    this.id,
    this.unreadPosts,
    this.firstUnreadId,
    this.threadId,
    this.iconId,
    this.threadIcon,
    this.threadTitle,
    this.threadUser,
    this.threadLocked,
    this.threadCreatedAt,
    this.threadUpdatedAt,
    this.threadDeletedAt,
    this.threadBackgroundUrl,
    this.threadBackgroundType,
    this.threadUsername,
    this.threadUserAvatarUrl,
    this.threadUserRoleCode,
    this.threadPostCount,
    this.lastPost,
  });

  int? id;
  int? unreadPosts;
  int? firstUnreadId;
  int? threadId;
  int? iconId;
  int? threadIcon;
  String? threadTitle;
  int? threadUser;
  bool? threadLocked;
  DateTime? threadCreatedAt;
  DateTime? threadUpdatedAt;
  bool? threadDeletedAt;
  String? threadBackgroundUrl;
  String? threadBackgroundType;
  String? threadUsername;
  String? threadUserAvatarUrl;
  RoleCode? threadUserRoleCode;
  int? threadPostCount;
  ForumThreadLastPost? lastPost;

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json["id"],
        unreadPosts: json["unreadPosts"],
        firstUnreadId: json["firstUnreadId"],
        threadId: json["threadId"],
        iconId: json["icon_id"],
        threadIcon: json["threadIcon"],
        threadTitle: json["threadTitle"],
        threadUser: json["threadUser"],
        threadLocked: json["threadLocked"],
        threadCreatedAt: DateTime.parse(json["threadCreatedAt"]),
        threadUpdatedAt: DateTime.parse(json["threadUpdatedAt"]),
        threadDeletedAt: json["threadDeletedAt"],
        threadBackgroundUrl: json["threadBackgroundUrl"] == null
            ? null
            : json["threadBackgroundUrl"],
        threadBackgroundType: json["threadBackgroundType"] == null
            ? null
            : json["threadBackgroundType"],
        threadUsername: json["threadUsername"],
        threadUserAvatarUrl: json["threadUserAvatarUrl"],
        threadUserRoleCode: codeValues.map[json["threadUserRoleCode"]],
        threadPostCount: json["threadPostCount"],
        lastPost: ForumThreadLastPost.fromJson(json["lastPost"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "unreadPosts": unreadPosts,
        "firstUnreadId": firstUnreadId,
        "threadId": threadId,
        "icon_id": iconId,
        "threadIcon": threadIcon,
        "threadTitle": threadTitle,
        "threadUser": threadUser,
        "threadLocked": threadLocked,
        "threadCreatedAt": threadCreatedAt!.toIso8601String(),
        "threadUpdatedAt": threadUpdatedAt!.toIso8601String(),
        "threadDeletedAt": threadDeletedAt,
        "threadBackgroundUrl":
            threadBackgroundUrl == null ? null : threadBackgroundUrl,
        "threadBackgroundType":
            threadBackgroundType == null ? null : threadBackgroundType,
        "threadUsername": threadUsername,
        "threadUserAvatarUrl": threadUserAvatarUrl,
        "threadUserRoleCode":
            threadUserRoleCodeValues.reverse![threadUserRoleCode],
        "threadPostCount": threadPostCount,
        "lastPost": lastPost!.toJson(),
      };
}

final threadUserRoleCodeValues = EnumValues({
  "guest": RoleCode.GUEST,
  "banned-user": RoleCode.BANNED_USER,
  "basic-user": RoleCode.BASIC_USER,
  "limited-user": RoleCode.LIMITED_USER,
  "moderator": RoleCode.MODERATOR,
  "moderator-in-training": RoleCode.MODERATOR_IN_TRAINING,
  "super-moderator": RoleCode.SUPER_MODERATOR,
  "paid-gold-user": RoleCode.PAID_GOLD_USER,
  "gold-user": RoleCode.GOLD_USER,
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
