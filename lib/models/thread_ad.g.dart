// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_ad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadAd _$ThreadAdFromJson(Map<String, dynamic> json) => ThreadAd(
  id: (json['id'] as num).toInt(),
  description: json['description'] as String,
  query: json['query'] as String,
  imageUrl: json['imageUrl'] as String,
);

Map<String, dynamic> _$ThreadAdToJson(ThreadAd instance) => <String, dynamic>{
  'id': instance.id,
  'description': instance.description,
  'query': instance.query,
  'imageUrl': instance.imageUrl,
};
