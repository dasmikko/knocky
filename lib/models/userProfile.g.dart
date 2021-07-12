// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userProfile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return UserProfile(
    id: json['id'] as int,
    usergroup: Usergroup.values[json['usergroup'] as int],
    avatarUrl: json['avatarUrl'] as String,
    backgroundUrl: json['backgroundUrl'] as String,
    banned: json['banned'] as bool,
    posts: json['posts'] as int,
    threads: json['threads'] as int,
    username: json['username'] as String,
  );
}

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'avatarUrl': instance.avatarUrl,
      'backgroundUrl': instance.backgroundUrl,
      'banned': instance.banned,
      'usergroup': instance.usergroup,
      'username': instance.username,
      'posts': instance.posts,
      'threads': instance.threads,
    };
