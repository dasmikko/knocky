// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subforum_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubforumDetail _$SubforumDetailFromJson(Map<String, dynamic> json) =>
    SubforumDetail(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      lastPost: json['lastPost'] as Map<String, dynamic>,
      totalThreads: (json['totalThreads'] as num).toInt(),
      totalPosts: (json['totalPosts'] as num).toInt(),
    );

Map<String, dynamic> _$SubforumDetailToJson(SubforumDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'lastPost': instance.lastPost,
      'totalThreads': instance.totalThreads,
      'totalPosts': instance.totalPosts,
    };
