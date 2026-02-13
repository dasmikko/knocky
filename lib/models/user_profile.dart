import 'package:json_annotation/json_annotation.dart';
import 'user_profile_social.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final int id;
  final String? bio;
  final UserProfileSocial? social;
  final Map<String, dynamic>? background;
  final String? header;
  @JsonKey(defaultValue: false)
  final bool disableComments;

  UserProfile({
    required this.id,
    this.bio,
    this.social,
    this.background,
    this.header,
    this.disableComments = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
