// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadSearchResponse _$ThreadSearchResponseFromJson(
  Map<String, dynamic> json,
) => ThreadSearchResponse(
  totalThreads: (json['totalThreads'] as num).toInt(),
  threads: (json['threads'] as List<dynamic>)
      .map((e) => Thread.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ThreadSearchResponseToJson(
  ThreadSearchResponse instance,
) => <String, dynamic>{
  'totalThreads': instance.totalThreads,
  'threads': instance.threads,
};
