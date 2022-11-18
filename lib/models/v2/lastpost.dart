import 'package:knocky/models/v2/user.dart';

class ForumLastPost {
  ForumLastPost({
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
  ForumThreadLastPost thread;
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
  String appName;

  factory ForumLastPost.fromJson(Map<String, dynamic> json) => ForumLastPost(
        id: json["id"] == null ? null : json["id"],
        thread: json["thread"] == null
            ? null
            : ForumThreadLastPost.fromJson(json["thread"]),
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
        appName: json["appName"] == null ? null : json["appName"],
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
        "appName": appName == null ? null : appName,
      };
}

class ForumThreadLastPost {
  ForumThreadLastPost({
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
  String appName;

  factory ForumThreadLastPost.fromJson(Map<String, dynamic> json) =>
      ForumThreadLastPost(
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
        appName: json["appName"] == null ? null : json["appName"],
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
        "appName": appName == null ? null : appName,
      };
}

class SubforumThreadLastPost {
  SubforumThreadLastPost({
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
  String appName;

  factory SubforumThreadLastPost.fromJson(Map<String, dynamic> json) =>
      SubforumThreadLastPost(
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
        appName: json["appName"] == null ? null : json["appName"],
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
        "appName": appName == null ? null : appName,
      };
}
