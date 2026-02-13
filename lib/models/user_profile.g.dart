// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: (json['id'] as num).toInt(),
  bio: json['bio'] as String?,
  social: json['social'] == null
      ? null
      : UserProfileSocial.fromJson(json['social'] as Map<String, dynamic>),
  background: json['background'] as Map<String, dynamic>?,
  header: json['header'] as String?,
  disableComments: json['disableComments'] as bool? ?? false,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bio': instance.bio,
      'social': instance.social,
      'background': instance.background,
      'header': instance.header,
      'disableComments': instance.disableComments,
    };
