// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userProfilePosts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfilePosts _$UserProfilePostsFromJson(Map<String, dynamic> json) {
  return UserProfilePosts(
    currentPage: json['currentPage'] as int,
    totalPosts: json['totalPosts'] as int,
    posts: (json['posts'] as List)
        ?.map((e) =>
            e == null ? null : ThreadPost.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$UserProfilePostsToJson(UserProfilePosts instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'totalPosts': instance.totalPosts,
      'posts': instance.posts,
    };
