import 'package:json_annotation/json_annotation.dart';
import 'package:knocky/models/usergroup.dart';

part 'userProfile.g.dart';

@JsonSerializable()
class UserProfile {
  final int id;
  final String avatarUrl;
  final String backgroundUrl;
  final bool banned;
  final Usergroup usergroup;
  final String username;
  final int posts;
  final int threads;

  UserProfile({
    this.id,
    this.usergroup,
    this.avatarUrl,
    this.backgroundUrl,
    this.banned,
    this.posts,
    this.threads,
    this.username,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
