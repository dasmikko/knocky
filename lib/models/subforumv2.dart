// To parse this JSON data, do
//
//     final subforum = subforumFromJson(jsonString);

import 'dart:convert';

import 'package:knocky/models/v2/userRole.dart';

Subforum subforumFromJson(String str) => Subforum.fromJson(json.decode(str));

String subforumToJson(Subforum data) => json.encode(data.toJson());

class Subforum {
  Subforum({
    this.id,
    this.name,
    this.totalThreads,
    this.currentPage,
    this.threads,
  });

  int id;
  String name;
  int totalThreads;
  int currentPage;
  List<Thread> threads;

  factory Subforum.fromJson(Map<String, dynamic> json) => Subforum(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        totalThreads:
            json["totalThreads"] == null ? null : json["totalThreads"],
        currentPage: json["currentPage"] == null ? null : json["currentPage"],
        threads: json["threads"] == null
            ? null
            : List<Thread>.from(json["threads"].map((x) => Thread.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "totalThreads": totalThreads == null ? null : totalThreads,
        "currentPage": currentPage == null ? null : currentPage,
        "threads": threads == null
            ? null
            : List<dynamic>.from(threads.map((x) => x.toJson())),
      };
}

class Thread {
  Thread({
    this.id,
    this.title,
    this.iconId,
    this.subforumId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deleted,
    this.locked,
    this.pinned,
    this.lastPost,
    this.backgroundUrl,
    this.backgroundType,
    this.user,
    this.postCount,
    this.recentPostCount,
    this.unreadPostCount,
    this.readThreadUnreadPosts,
    this.read,
    this.hasRead,
    this.hasSeenNoNewPosts,
    this.firstUnreadId,
    this.firstPostTopRating,
    this.subforum,
    this.tags,
    this.viewers,
  });

  int id;
  String title;
  int iconId;
  int subforumId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  bool deleted;
  bool locked;
  bool pinned;
  LastPost lastPost;
  String backgroundUrl;
  String backgroundType;
  User user;
  int postCount;
  int recentPostCount;
  int unreadPostCount;
  int readThreadUnreadPosts;
  bool read;
  bool hasRead;
  bool hasSeenNoNewPosts;
  int firstUnreadId;
  FirstPostTopRating firstPostTopRating;
  dynamic subforum;
  List<Map<String, String>> tags;
  Viewers viewers;

  factory Thread.fromJson(Map<String, dynamic> json) => Thread(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        iconId: json["iconId"] == null ? null : json["iconId"],
        subforumId: json["subforumId"] == null ? null : json["subforumId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        deleted: json["deleted"] == null ? null : json["deleted"],
        locked: json["locked"] == null ? null : json["locked"],
        pinned: json["pinned"] == null ? null : json["pinned"],
        lastPost: json["lastPost"] == null
            ? null
            : LastPost.fromJson(json["lastPost"]),
        backgroundUrl:
            json["backgroundUrl"] == null ? null : json["backgroundUrl"],
        backgroundType:
            json["backgroundType"] == null ? null : json["backgroundType"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        postCount: json["postCount"] == null ? null : json["postCount"],
        recentPostCount:
            json["recentPostCount"] == null ? null : json["recentPostCount"],
        unreadPostCount:
            json["unreadPostCount"] == null ? null : json["unreadPostCount"],
        readThreadUnreadPosts: json["readThreadUnreadPosts"] == null
            ? null
            : json["readThreadUnreadPosts"],
        read: json["read"] == null ? null : json["read"],
        hasRead: json["hasRead"] == null ? null : json["hasRead"],
        hasSeenNoNewPosts: json["hasSeenNoNewPosts"] == null
            ? null
            : json["hasSeenNoNewPosts"],
        firstUnreadId:
            json["firstUnreadId"] == null ? null : json["firstUnreadId"],
        firstPostTopRating: json["firstPostTopRating"] == null
            ? null
            : FirstPostTopRating.fromJson(json["firstPostTopRating"]),
        subforum: json["subforum"],
        tags: json["tags"] == null
            ? null
            : List<Map<String, String>>.from(json["tags"].map((x) =>
                Map.from(x).map((k, v) => MapEntry<String, String>(k, v)))),
        viewers:
            json["viewers"] == null ? null : Viewers.fromJson(json["viewers"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "iconId": iconId == null ? null : iconId,
        "subforumId": subforumId == null ? null : subforumId,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "deletedAt": deletedAt,
        "deleted": deleted == null ? null : deleted,
        "locked": locked == null ? null : locked,
        "pinned": pinned == null ? null : pinned,
        "lastPost": lastPost == null ? null : lastPost.toJson(),
        "backgroundUrl": backgroundUrl == null ? null : backgroundUrl,
        "backgroundType": backgroundType == null ? null : backgroundType,
        "user": user == null ? null : user.toJson(),
        "postCount": postCount == null ? null : postCount,
        "recentPostCount": recentPostCount == null ? null : recentPostCount,
        "unreadPostCount": unreadPostCount == null ? null : unreadPostCount,
        "readThreadUnreadPosts":
            readThreadUnreadPosts == null ? null : readThreadUnreadPosts,
        "read": read == null ? null : read,
        "hasRead": hasRead == null ? null : hasRead,
        "hasSeenNoNewPosts":
            hasSeenNoNewPosts == null ? null : hasSeenNoNewPosts,
        "firstUnreadId": firstUnreadId == null ? null : firstUnreadId,
        "firstPostTopRating":
            firstPostTopRating == null ? null : firstPostTopRating.toJson(),
        "subforum": subforum,
        "tags": tags == null
            ? null
            : List<dynamic>.from(tags.map((x) =>
                Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v)))),
        "viewers": viewers == null ? null : viewers.toJson(),
      };
}

class FirstPostTopRating {
  FirstPostTopRating({
    this.id,
    this.rating,
    this.ratingId,
    this.users,
    this.count,
  });

  int id;
  String rating;
  int ratingId;
  List<dynamic> users;
  int count;

  factory FirstPostTopRating.fromJson(Map<String, dynamic> json) =>
      FirstPostTopRating(
        id: json["id"] == null ? null : json["id"],
        rating: json["rating"] == null ? null : json["rating"],
        ratingId: json["ratingId"] == null ? null : json["ratingId"],
        users: json["users"] == null
            ? null
            : List<dynamic>.from(json["users"].map((x) => x)),
        count: json["count"] == null ? null : json["count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "rating": rating == null ? null : rating,
        "ratingId": ratingId == null ? null : ratingId,
        "users": users == null ? null : List<dynamic>.from(users.map((x) => x)),
        "count": count == null ? null : count,
      };
}

class LastPost {
  LastPost({
    this.id,
    this.thread,
    this.page,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.ratings,
    this.bans,
    this.threadPostNumber,
    this.countryName,
    this.countryCode,
    this.appName,
  });

  int id;
  int thread;
  int page;
  dynamic content;
  DateTime createdAt;
  DateTime updatedAt;
  User user;
  List<dynamic> ratings;
  List<dynamic> bans;
  int threadPostNumber;
  String countryName;
  String countryCode;
  AppName appName;

  factory LastPost.fromJson(Map<String, dynamic> json) => LastPost(
        id: json["id"] == null ? null : json["id"],
        thread: json["thread"] == null ? null : json["thread"],
        page: json["page"] == null ? null : json["page"],
        content: json["content"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        ratings: json["ratings"] == null
            ? null
            : List<dynamic>.from(json["ratings"].map((x) => x)),
        bans: json["bans"] == null
            ? null
            : List<dynamic>.from(json["bans"].map((x) => x)),
        threadPostNumber:
            json["threadPostNumber"] == null ? null : json["threadPostNumber"],
        countryName: json["countryName"] == null ? null : json["countryName"],
        countryCode: json["countryCode"] == null ? null : json["countryCode"],
        appName:
            json["appName"] == null ? null : appNameValues.map[json["appName"]],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "thread": thread == null ? null : thread,
        "page": page == null ? null : page,
        "content": content,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "user": user == null ? null : user.toJson(),
        "ratings":
            ratings == null ? null : List<dynamic>.from(ratings.map((x) => x)),
        "bans": bans == null ? null : List<dynamic>.from(bans.map((x) => x)),
        "threadPostNumber": threadPostNumber == null ? null : threadPostNumber,
        "countryName": countryName == null ? null : countryName,
        "countryCode": countryCode == null ? null : countryCode,
        "appName": appName == null ? null : appNameValues.reverse[appName],
      };
}

enum AppName { KNOCKOUT_CHAT }

final appNameValues = EnumValues({"knockout.chat": AppName.KNOCKOUT_CHAT});

class User {
  User({
    this.id,
    this.role,
    this.username,
    this.usergroup,
    this.avatarUrl,
    this.backgroundUrl,
    this.posts,
    this.threads,
    this.createdAt,
    this.updatedAt,
    this.banned,
    this.isBanned,
    this.title,
    this.pronouns,
    this.useBioForTitle,
  });

  int id;
  UserRole role;
  String username;
  int usergroup;
  String avatarUrl;
  String backgroundUrl;
  int posts;
  int threads;
  DateTime createdAt;
  DateTime updatedAt;
  bool banned;
  bool isBanned;
  String title;
  String pronouns;
  int useBioForTitle;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] == null ? null : json["id"],
        role: json["role"] == null ? null : UserRole.fromJson(json["role"]),
        username: json["username"] == null ? null : json["username"],
        usergroup: json["usergroup"] == null ? null : json["usergroup"],
        avatarUrl: json["avatarUrl"] == null ? null : json["avatarUrl"],
        backgroundUrl:
            json["backgroundUrl"] == null ? null : json["backgroundUrl"],
        posts: json["posts"] == null ? null : json["posts"],
        threads: json["threads"] == null ? null : json["threads"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        banned: json["banned"] == null ? null : json["banned"],
        isBanned: json["isBanned"] == null ? null : json["isBanned"],
        title: json["title"] == null ? null : json["title"],
        pronouns: json["pronouns"] == null ? null : json["pronouns"],
        useBioForTitle:
            json["useBioForTitle"] == null ? null : json["useBioForTitle"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "role": role == null ? null : role.toJson(),
        "username": username == null ? null : username,
        "usergroup": usergroup == null ? null : usergroup,
        "avatarUrl": avatarUrl == null ? null : avatarUrl,
        "backgroundUrl": backgroundUrl == null ? null : backgroundUrl,
        "posts": posts == null ? null : posts,
        "threads": threads == null ? null : threads,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "banned": banned == null ? null : banned,
        "isBanned": isBanned == null ? null : isBanned,
        "title": title == null ? null : title,
        "pronouns": pronouns == null ? null : pronouns,
        "useBioForTitle": useBioForTitle == null ? null : useBioForTitle,
      };
}

class Role {
  Role({
    this.id,
    this.code,
    this.description,
    this.permissionCodes,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  Code code;
  String description;
  List<dynamic> permissionCodes;
  DateTime createdAt;
  DateTime updatedAt;

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"] == null ? null : json["id"],
        code: json["code"] == null ? null : codeValues.map[json["code"]],
        description: json["description"] == null ? null : json["description"],
        permissionCodes: json["permissionCodes"] == null
            ? null
            : List<dynamic>.from(json["permissionCodes"].map((x) => x)),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "code": code == null ? null : codeValues.reverse[code],
        "description": description == null ? null : description,
        "permissionCodes": permissionCodes == null
            ? null
            : List<dynamic>.from(permissionCodes.map((x) => x)),
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
      };
}

enum Code {
  BASIC_USER,
  MODERATOR,
  PAID_GOLD_USER,
  ADMIN,
  LIMITED_USER,
  BANNED_USER
}

final codeValues = EnumValues({
  "admin": Code.ADMIN,
  "banned-user": Code.BANNED_USER,
  "basic-user": Code.BASIC_USER,
  "limited-user": Code.LIMITED_USER,
  "moderator": Code.MODERATOR,
  "paid-gold-user": Code.PAID_GOLD_USER
});

class Viewers {
  Viewers({
    this.memberCount,
    this.guestCount,
  });

  int memberCount;
  int guestCount;

  factory Viewers.fromJson(Map<String, dynamic> json) => Viewers(
        memberCount: json["memberCount"] == null ? null : json["memberCount"],
        guestCount: json["guestCount"] == null ? null : json["guestCount"],
      );

  Map<String, dynamic> toJson() => {
        "memberCount": memberCount == null ? null : memberCount,
        "guestCount": guestCount == null ? null : guestCount,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
