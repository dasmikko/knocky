// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_social.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SteamData _$SteamDataFromJson(Map<String, dynamic> json) =>
    SteamData(name: json['name'] as String?, url: json['url'] as String?);

Map<String, dynamic> _$SteamDataToJson(SteamData instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
};

UserProfileSocial _$UserProfileSocialFromJson(Map<String, dynamic> json) =>
    UserProfileSocial(
      website: json['website'] as String?,
      steam: json['steam'] == null
          ? null
          : SteamData.fromJson(json['steam'] as Map<String, dynamic>),
      discord: json['discord'] as String?,
      github: json['github'] as String?,
      youtube: json['youtube'] as String?,
      twitter: json['twitter'] as String?,
      fediverse: json['fediverse'] as String?,
      twitch: json['twitch'] as String?,
      gitlab: json['gitlab'] as String?,
      tumblr: json['tumblr'] as String?,
      bluesky: json['bluesky'] as String?,
    );

Map<String, dynamic> _$UserProfileSocialToJson(UserProfileSocial instance) =>
    <String, dynamic>{
      'website': instance.website,
      'steam': instance.steam,
      'discord': instance.discord,
      'github': instance.github,
      'youtube': instance.youtube,
      'twitter': instance.twitter,
      'fediverse': instance.fediverse,
      'twitch': instance.twitch,
      'gitlab': instance.gitlab,
      'tumblr': instance.tumblr,
      'bluesky': instance.bluesky,
    };
