// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userProfileThreads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileThreads _$UserProfileThreadsFromJson(Map<String, dynamic> json) {
  return UserProfileThreads(
    currentPage: json['currentPage'] as int,
    totalThreads: json['totalThreads'] as int,
    threads: (json['threads'] as List)
        ?.map((e) => e == null
            ? null
            : SignificantThread.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$UserProfileThreadsToJson(UserProfileThreads instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'totalThreads': instance.totalThreads,
      'threads': instance.threads,
    };
