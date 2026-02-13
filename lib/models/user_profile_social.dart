import 'package:json_annotation/json_annotation.dart';

part 'user_profile_social.g.dart';

@JsonSerializable()
class SteamData {
  final String? name;
  final String? url;

  SteamData({this.name, this.url});

  factory SteamData.fromJson(Map<String, dynamic> json) =>
      _$SteamDataFromJson(json);
  Map<String, dynamic> toJson() => _$SteamDataToJson(this);
}

@JsonSerializable()
class UserProfileSocial {
  final String? website;
  final SteamData? steam;
  final String? discord;
  final String? github;
  final String? youtube;
  final String? twitter;
  final String? fediverse;
  final String? twitch;
  final String? gitlab;
  final String? tumblr;
  final String? bluesky;

  UserProfileSocial({
    this.website,
    this.steam,
    this.discord,
    this.github,
    this.youtube,
    this.twitter,
    this.fediverse,
    this.twitch,
    this.gitlab,
    this.tumblr,
    this.bluesky,
  });

  factory UserProfileSocial.fromJson(Map<String, dynamic> json) =>
      _$UserProfileSocialFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileSocialToJson(this);
}
