// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subforum_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubforumResponse _$SubforumResponseFromJson(Map<String, dynamic> json) =>
    SubforumResponse(
      subforum: SubforumDetail.fromJson(
        json['subforum'] as Map<String, dynamic>,
      ),
      page: (json['page'] as num).toInt(),
      threads: (json['threads'] as List<dynamic>)
          .map((e) => Thread.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubforumResponseToJson(SubforumResponse instance) =>
    <String, dynamic>{
      'subforum': instance.subforum,
      'page': instance.page,
      'threads': instance.threads,
    };
