// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subforum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subforum _$SubforumFromJson(Map<String, dynamic> json) => Subforum(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
  totalThreads: (json['totalThreads'] as num).toInt(),
  totalPosts: (json['totalPosts'] as num).toInt(),
  lastPost: _postFromJson(json['lastPost']),
);

Map<String, dynamic> _$SubforumToJson(Subforum instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'icon': instance.icon,
  'totalThreads': instance.totalThreads,
  'totalPosts': instance.totalPosts,
  'lastPost': instance.lastPost,
};
