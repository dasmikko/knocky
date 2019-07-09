// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readThreads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadThreads _$ReadThreadsFromJson(Map<String, dynamic> json) {
  return ReadThreads(
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      threadId: json['threadId'] as int);
}

Map<String, dynamic> _$ReadThreadsToJson(ReadThreads instance) =>
    <String, dynamic>{
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'threadId': instance.threadId
    };
