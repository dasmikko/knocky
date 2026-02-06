// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Viewers _$ViewersFromJson(Map<String, dynamic> json) => Viewers(
  memberCount: (json['memberCount'] as num).toInt(),
  guestCount: (json['guestCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ViewersToJson(Viewers instance) => <String, dynamic>{
  'memberCount': instance.memberCount,
  'guestCount': instance.guestCount,
};
