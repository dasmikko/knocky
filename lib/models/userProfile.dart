import 'package:knocky/models/usergroup.dart';

class UserProfile {
  final int id;
  final String avatarUrl;
  final String backgroundUrl;
  final bool banned;
  final Usergroup usergroup;
  final String username;
  final int posts;
  final int threads;
  final DateTime joinDate;

  UserProfile(
      {this.id,
      this.usergroup,
      this.avatarUrl,
      this.backgroundUrl,
      this.banned,
      this.posts,
      this.threads,
      this.username,
      this.joinDate});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
        id: json['id'] as int,
        usergroup: Usergroup.values[json['usergroup'] as int],
        avatarUrl: json['avatarUrl'] as String,
        backgroundUrl: json['backgroundUrl'] as String,
        banned: json['banned'] as bool,
        posts: json['posts'] as int,
        threads: json['threads'] as int,
        username: json['username'] as String,
        joinDate: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String));
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'avatarUrl': avatarUrl,
        'backgroundUrl': backgroundUrl,
        'banned': banned,
        'usergroup': usergroup,
        'username': username,
        'posts': posts,
        'threads': threads,
      };
}
