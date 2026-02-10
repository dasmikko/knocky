// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ban.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ban _$BanFromJson(Map<String, dynamic> json) => Ban(
  id: (json['id'] as num).toInt(),
  banReason: json['banReason'] as String,
  expiresAt: json['expiresAt'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  user: json['user'] == null
      ? null
      : ThreadUser.fromJson(json['user'] as Map<String, dynamic>),
  bannedBy: json['bannedBy'] == null
      ? null
      : ThreadUser.fromJson(json['bannedBy'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BanToJson(Ban instance) => <String, dynamic>{
  'id': instance.id,
  'banReason': instance.banReason,
  'expiresAt': instance.expiresAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'user': instance.user,
  'bannedBy': instance.bannedBy,
};
