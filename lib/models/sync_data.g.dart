// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncData _$SyncDataFromJson(Map<String, dynamic> json) => SyncData(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  isBanned: json['isBanned'] as bool,
  avatarUrl: json['avatarUrl'] as String,
  backgroundUrl: json['backgroundUrl'] as String,
  createdAt: json['createdAt'] as String,
  role: Role.fromJson(json['role'] as Map<String, dynamic>),
  mentions: json['mentions'] as List<dynamic>? ?? const [],
  subscriptions:
      (json['subscriptions'] as List<dynamic>?)
          ?.map((e) => SyncSubscription.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  subscriptionIds:
      (json['subscriptionIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
);

Map<String, dynamic> _$SyncDataToJson(SyncData instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'isBanned': instance.isBanned,
  'avatarUrl': instance.avatarUrl,
  'backgroundUrl': instance.backgroundUrl,
  'createdAt': instance.createdAt,
  'role': instance.role,
  'mentions': instance.mentions,
  'subscriptions': instance.subscriptions,
  'subscriptionIds': instance.subscriptionIds,
};
