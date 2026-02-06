// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertsResponse _$AlertsResponseFromJson(Map<String, dynamic> json) =>
    AlertsResponse(
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAlerts: (json['totalAlerts'] as num).toInt(),
      ids: (json['ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$AlertsResponseToJson(AlertsResponse instance) =>
    <String, dynamic>{
      'alerts': instance.alerts,
      'totalAlerts': instance.totalAlerts,
      'ids': instance.ids,
    };
