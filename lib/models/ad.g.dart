// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KnockoutAd _$KnockoutAdFromJson(Map<String, dynamic> json) {
  return KnockoutAd(
    description: json['description'] as String,
    imageUrl: json['imageUrl'] as String,
    query: json['query'] as String,
  );
}

Map<String, dynamic> _$KnockoutAdToJson(KnockoutAd instance) =>
    <String, dynamic>{
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'query': instance.query,
    };
