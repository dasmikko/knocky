// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subforum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subforum _$SubforumFromJson(Map<String, dynamic> json) {
  return Subforum(
      id: json['id'] as int,
      icon: json['icon'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      totalPosts: json['totalPosts'] as int,
      totalThreads: json['totalThreads'] as int);
}

Map<String, dynamic> _$SubforumToJson(Subforum instance) => <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'name': instance.name,
      'description': instance.description,
      'totalPosts': instance.totalPosts,
      'totalThreads': instance.totalThreads
    };
