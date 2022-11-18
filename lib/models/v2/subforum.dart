// To parse this JSON data, do
//
//     final subforum = subforumFromJson(jsonString);

import 'dart:convert';

import 'package:knocky/models/subforumDetails.dart';

Subforum subforumFromJson(String str) => Subforum.fromJson(json.decode(str));

String subforumToJson(Subforum data) => json.encode(data.toJson());

class Subforum {
  Subforum({
    this.id,
    this.name,
    this.totalThreads,
    this.currentPage,
    this.threads,
  });

  int id;
  String name;
  int totalThreads;
  int currentPage;
  List<SubforumThread> threads;

  factory Subforum.fromJson(Map<String, dynamic> json) => Subforum(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        totalThreads:
            json["totalThreads"] == null ? null : json["totalThreads"],
        currentPage: json["currentPage"] == null ? null : json["currentPage"],
        threads: json["threads"] == null
            ? null
            : List<SubforumThread>.from(
                json["threads"].map((x) => SubforumThread.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "totalThreads": totalThreads == null ? null : totalThreads,
        "currentPage": currentPage == null ? null : currentPage,
        "threads": threads == null
            ? null
            : List<dynamic>.from(threads.map((x) => x.toJson())),
      };
}
