// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_thread_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostThreadInfo _$PostThreadInfoFromJson(Map<String, dynamic> json) =>
    PostThreadInfo(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      iconId: (json['iconId'] as num).toInt(),
      subforumId: (json['subforumId'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$PostThreadInfoToJson(PostThreadInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'iconId': instance.iconId,
      'subforumId': instance.subforumId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
