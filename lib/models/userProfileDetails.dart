import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserProfileDetails {
  final int id;
  final String backgroundUrl;
  final String bio;
  final Map<String, dynamic> social;
  UserProfileDetails({this.id, this.backgroundUrl, this.bio, this.social});

  factory UserProfileDetails.fromJson(Map<String, dynamic> json) =>
      fromJson(json);
}

UserProfileDetails fromJson(Map<String, dynamic> json) {
  return UserProfileDetails(
      id: json['id'] as int,
      backgroundUrl: json['backgroundUrl'] as String,
      bio: json['bio'] as String,
      social: json['social'] as Map<String, dynamic>);
}
