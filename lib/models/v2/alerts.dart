// To parse this JSON data, do
//
//     final alerts = alertsFromJson(jsonString);

import 'dart:convert';

import 'package:knocky/models/v2/thread.dart';

class Alerts {
  Alerts({
    this.alerts,
    this.totalAlerts,
    this.ids,
  });

  List<Alert>? alerts;
  int? totalAlerts;
  List<int>? ids;

  factory Alerts.fromRawJson(String str) => Alerts.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Alerts.fromJson(Map<String, dynamic> json) => Alerts(
        alerts: List<Alert>.from(json["alerts"].map((x) => Alert.fromJson(x))),
        totalAlerts: json["totalAlerts"],
        ids: List<int>.from(json["ids"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "alerts": List<dynamic>.from(alerts!.map((x) => x.toJson())),
        "totalAlerts": totalAlerts,
        "ids": List<dynamic>.from(ids!.map((x) => x)),
      };
}

class Alert {
  Alert({
    this.id,
    this.thread,
    this.unreadPosts,
    this.firstUnreadId,
  });

  int? id;
  SubforumThread? thread;
  int? unreadPosts;
  int? firstUnreadId;

  factory Alert.fromRawJson(String str) => Alert.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id: json["id"],
        thread: SubforumThread.fromJson(json["thread"]),
        unreadPosts: json["unreadPosts"],
        firstUnreadId: json["firstUnreadId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "thread": thread!.toJson(),
        "unreadPosts": unreadPosts,
        "firstUnreadId": firstUnreadId,
      };
}
