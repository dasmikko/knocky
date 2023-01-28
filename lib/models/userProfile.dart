import 'package:knocky/models/v2/userRole.dart';

class UserProfile {
  final int id;
  final String avatarUrl;
  final String backgroundUrl;
  final bool banned;
  final String username;
  final int posts;
  final int threads;
  final UserRole role;
  final DateTime joinDate;
  final String pronouns;
  final String title;

  UserProfile(
      {this.id,
      this.role,
      this.avatarUrl,
      this.backgroundUrl,
      this.banned,
      this.posts,
      this.threads,
      this.username,
      this.joinDate,
      this.pronouns,
      this.title});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      role: json['role'] == null ? null : UserRole.fromJson(json['role']),
      avatarUrl: json['avatarUrl'] as String,
      backgroundUrl: json['backgroundUrl'] as String,
      banned: json['banned'] as bool,
      posts: json['posts'] as int,
      threads: json['threads'] as int,
      username: json['username'] as String,
      joinDate: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      pronouns: json['pronouns'] as String,
      title: json['title'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'avatarUrl': avatarUrl,
        'backgroundUrl': backgroundUrl,
        'banned': banned,
        'role': role,
        'username': username,
        'posts': posts,
        'threads': threads,
        'pronouns': pronouns,
        'title': title
      };
}
