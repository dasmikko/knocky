import 'package:knocky/models/v2/userRole.dart';

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

  int? id;
  UserRole? role;
  String? username;
  String? avatarUrl;
  String? backgroundUrl;
  int? posts;
  int? threads;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? banned;
  bool? isBanned;
  String? title;
  String? pronouns;
  int? useBioForTitle;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] == null ? null : json["id"],
        role: json["role"] == null ? null : UserRole.fromJson(json["role"]),
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
        pronouns: json["pronouns"] == null ? null : json["pronouns"],
        useBioForTitle:
            json["useBioForTitle"] == null ? null : json["useBioForTitle"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "role": role == null ? null : role!.toJson(),
        "username": username == null ? null : username,
        "avatarUrl": avatarUrl == null ? null : avatarUrl,
        "backgroundUrl": backgroundUrl == null ? null : backgroundUrl,
        "posts": posts == null ? null : posts,
        "threads": threads == null ? null : threads,
        "createdAt": createdAt == null ? null : createdAt!.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "banned": banned == null ? null : banned,
        "isBanned": isBanned == null ? null : isBanned,
        "title": title == null ? null : title,
        "pronouns": pronouns == null ? null : pronouns,
        "useBioForTitle": useBioForTitle == null ? null : useBioForTitle,
      };
}
