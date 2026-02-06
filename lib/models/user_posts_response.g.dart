// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_posts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPostsResponse _$UserPostsResponseFromJson(Map<String, dynamic> json) =>
    UserPostsResponse(
      totalPosts: (json['totalPosts'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      posts: (json['posts'] as List<dynamic>)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserPostsResponseToJson(UserPostsResponse instance) =>
    <String, dynamic>{
      'totalPosts': instance.totalPosts,
      'currentPage': instance.currentPage,
      'posts': instance.posts,
    };
