import 'package:json_annotation/json_annotation.dart';
import 'package:knocky/models/threadAlert.dart';

@JsonSerializable()
class ThreadAlertPage {
  final List<ThreadAlert> alerts;
  final int totalAlerts;

  ThreadAlertPage({this.alerts, this.totalAlerts});

  factory ThreadAlertPage.fromJson(Map<String, dynamic> json) =>
      _$ThreadAlertPageFromJson(json);
}

ThreadAlertPage _$ThreadAlertPageFromJson(Map<String, dynamic> json) {
  var alerts = (json["alerts"] as List)
          ?.map((threadAlertJson) => ThreadAlert.fromJson(threadAlertJson))
          ?.toList() ??
      <ThreadAlert>[];
  return ThreadAlertPage(
      alerts: alerts, totalAlerts: json["totalAlerts"] as int);
}
