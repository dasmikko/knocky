// To parse this JSON data, do
//
//     final forum = forumFromJson(jsonString);

import 'dart:convert';

import 'package:knocky/models/v2/userRole.dart' as UserRoleV2;

Forum forumFromJson(String str) => Forum.fromJson(json.decode(str));

String forumToJson(Forum data) => json.encode(data.toJson());

class Forum {
  Forum({
    this.list,
  });

  List<Subforum> list;

  factory Forum.fromJson(Map<String, dynamic> json) => Forum(
        list: json["list"] == null
            ? null
            : List<Subforum>.from(
                json["list"].map((x) => Subforum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "list": list == null
            ? null
            : List<dynamic>.from(list.map((x) => x.toJson())),
      };
}

class Subforum {
  Subforum({
    this.id,
    this.name,
    this.iconId,
    this.description,
    this.icon,
    this.totalThreads,
    this.totalPosts,
    this.lastPostId,
    this.lastPost,
  });

  int id;
  String name;
  int iconId;
  String description;
  String icon;
  int totalThreads;
  int totalPosts;
  int lastPostId;
  ListLastPost lastPost;

  factory Subforum.fromJson(Map<String, dynamic> json) => Subforum(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        iconId: json["iconId"] == null ? null : json["iconId"],
        description: json["description"] == null ? null : json["description"],
        icon: json["icon"] == null ? null : json["icon"],
        totalThreads:
            json["totalThreads"] == null ? null : json["totalThreads"],
        totalPosts: json["totalPosts"] == null ? null : json["totalPosts"],
        lastPostId: json["lastPostId"] == null ? null : json["lastPostId"],
        lastPost: json["lastPost"] == null
            ? null
            : ListLastPost.fromJson(json["lastPost"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "iconId": iconId == null ? null : iconId,
        "description": description == null ? null : description,
        "icon": icon == null ? null : icon,
        "totalThreads": totalThreads == null ? null : totalThreads,
        "totalPosts": totalPosts == null ? null : totalPosts,
        "lastPostId": lastPostId == null ? null : lastPostId,
        "lastPost": lastPost == null ? null : lastPost.toJson(),
      };
}

class ListLastPost {
  ListLastPost({
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
  Thread thread;
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

  factory ListLastPost.fromJson(Map<String, dynamic> json) => ListLastPost(
        id: json["id"] == null ? null : json["id"],
        thread: json["thread"] == null ? null : Thread.fromJson(json["thread"]),
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
        "thread": thread == null ? null : thread.toJson(),
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
    this.subforum,
    this.tags,
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
  ThreadLastPost lastPost;
  String backgroundUrl;
  String backgroundType;
  int user;
  int postCount;
  int recentPostCount;
  int unreadPostCount;
  int readThreadUnreadPosts;
  bool read;
  bool hasRead;
  bool hasSeenNoNewPosts;
  Subforum subforum;
  List<dynamic> tags;

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
            : ThreadLastPost.fromJson(json["lastPost"]),
        backgroundUrl:
            json["backgroundUrl"] == null ? null : json["backgroundUrl"],
        backgroundType:
            json["backgroundType"] == null ? null : json["backgroundType"],
        user: json["user"] == null ? null : json["user"],
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
        subforum: json["subforum"] == null
            ? null
            : Subforum.fromJson(json["subforum"]),
        tags: json["tags"] == null
            ? null
            : List<dynamic>.from(json["tags"].map((x) => x)),
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
        "user": user == null ? null : user,
        "postCount": postCount == null ? null : postCount,
        "recentPostCount": recentPostCount == null ? null : recentPostCount,
        "unreadPostCount": unreadPostCount == null ? null : unreadPostCount,
        "readThreadUnreadPosts":
            readThreadUnreadPosts == null ? null : readThreadUnreadPosts,
        "read": read == null ? null : read,
        "hasRead": hasRead == null ? null : hasRead,
        "hasSeenNoNewPosts":
            hasSeenNoNewPosts == null ? null : hasSeenNoNewPosts,
        "subforum": subforum.toJson(),
        "tags": tags == null ? null : List<dynamic>.from(tags.map((x) => x)),
      };
}

class ThreadLastPost {
  ThreadLastPost({
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

  factory ThreadLastPost.fromJson(Map<String, dynamic> json) => ThreadLastPost(
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

class User {
  User({
    this.id,
    this.role,
    this.username,
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
  UserRoleV2.UserRole role;
  String username;
  String avatarUrl;
  String backgroundUrl;
  int posts;
  int threads;
  DateTime createdAt;
  DateTime updatedAt;
  bool banned;
  bool isBanned;
  String title;
  Pronouns pronouns;
  int useBioForTitle;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] == null ? null : json["id"],
        role: json["role"] == null
            ? null
            : UserRoleV2.UserRole.fromJson(json["role"]),
        username: json["username"] == null ? null : json["username"],
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
        pronouns: json["pronouns"] == null
            ? null
            : pronounsValues.map[json["pronouns"]],
        useBioForTitle:
            json["useBioForTitle"] == null ? null : json["useBioForTitle"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "role": role == null ? null : role.toJson(),
        "username": username == null ? null : username,
        "avatarUrl": avatarUrl == null ? null : avatarUrl,
        "backgroundUrl": backgroundUrl == null ? null : backgroundUrl,
        "posts": posts == null ? null : posts,
        "threads": threads == null ? null : threads,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "banned": banned == null ? null : banned,
        "isBanned": isBanned == null ? null : isBanned,
        "title": title == null ? null : title,
        "pronouns": pronouns == null ? null : pronounsValues.reverse[pronouns],
        "useBioForTitle": useBioForTitle == null ? null : useBioForTitle,
      };
}

enum Pronouns { HE_HIM, EMPTY, PRONOUNS, PRONOUNS_HE_HIM }

final pronounsValues = EnumValues({
  "": Pronouns.EMPTY,
  "he/him": Pronouns.HE_HIM,
  "\ud835\udddb\ud835\uddd8 \ud83d\uddff \ud835\udddb\ud835\udddc\ud835\udde0":
      Pronouns.PRONOUNS,
  "he / him": Pronouns.PRONOUNS_HE_HIM
});

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
  GUEST,
  BANNED_USER,
  BASIC_USER,
  LIMITED_USER,
  GOLD_USER,
  PAID_GOLD_USER,
  MODERATOR,
  MODERATOR_IN_TRAINING,
  SUPER_MODERATOR,
  ADMIN,
}

final codeValues = EnumValues({
  "guest": Code.GUEST,
  "banned-user": Code.BANNED_USER,
  "basic-user": Code.BASIC_USER,
  "limited-user": Code.LIMITED_USER,
  "moderator": Code.MODERATOR,
  "moderator-in-training": Code.MODERATOR_IN_TRAINING,
  "super-moderator": Code.SUPER_MODERATOR,
  "paid-gold-user": Code.PAID_GOLD_USER,
  "gold-user": Code.GOLD_USER,
});

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
