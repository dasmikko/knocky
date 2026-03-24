// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticker_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TickerEvent _$TickerEventFromJson(Map<String, dynamic> json) => TickerEvent(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  creator: ThreadUser.fromJson(json['creator'] as Map<String, dynamic>),
  content: json['content'] as Map<String, dynamic>? ?? {},
  createdAt: json['createdAt'] as String,
  data: _dataFromJson(json['data']),
);

Map<String, dynamic> _$TickerEventToJson(TickerEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'creator': instance.creator,
      'content': instance.content,
      'createdAt': instance.createdAt,
      'data': instance.data,
    };
