// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_threads_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserThreadsResponse _$UserThreadsResponseFromJson(Map<String, dynamic> json) =>
    UserThreadsResponse(
      totalThreads: (json['totalThreads'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      threads: (json['threads'] as List<dynamic>)
          .map((e) => UserThread.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserThreadsResponseToJson(
  UserThreadsResponse instance,
) => <String, dynamic>{
  'totalThreads': instance.totalThreads,
  'currentPage': instance.currentPage,
  'threads': instance.threads,
};
