// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readThreads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadThreads _$ReadThreadsFromJson(Map<String, dynamic> json) {
  return ReadThreads(
    lastPostNumber: json['lastPostNumber'] as int,
    lastSeen: json['lastSeen'] == null
        ? null
        : DateTime.parse(json['lastSeen'] as String),
    threadId: json['threadId'] as int,
  );
}

Map<String, dynamic> _$ReadThreadsToJson(ReadThreads instance) =>
    <String, dynamic>{
      'lastPostNumber': instance.lastPostNumber,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'threadId': instance.threadId,
    };
