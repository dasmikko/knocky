import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserBans {
  final List<UserBan>? userBans;

  UserBans({this.userBans});

  factory UserBans.fromJson(List<dynamic> json) => fromJson(json);
}

UserBans fromJson(List<dynamic> json) {
  var bans = json
      .map((mapEntries) => new UserBan(
            id: mapEntries['id'],
            banReason: mapEntries['banReason'],
            bannedBy: mapEntries['bannedBy'],
            createdAt: DateTime.parse(mapEntries['createdAt']),
            expiresAt: DateTime.parse(mapEntries['expiresAt']),
            updatedAt: DateTime.parse(mapEntries['updatedAt']),
            post: mapEntries['post'],
            thread: mapEntries['thread'],
            user: mapEntries['user'],
          ))
      .toList();
  return new UserBans(userBans: bans);
}

@JsonSerializable()
class UserBan {
  final int? id;
  final String? banReason;
  final dynamic bannedBy;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final DateTime? updatedAt;
  final dynamic post;
  final dynamic thread;
  final dynamic user;

  UserBan(
      {this.id,
      this.banReason,
      this.bannedBy,
      this.createdAt,
      this.expiresAt,
      this.updatedAt,
      this.post,
      this.thread,
      this.user});
}
