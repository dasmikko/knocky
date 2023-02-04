// To parse this JSON data, do
//
//     final forum = forumFromJson(jsonString);

import 'dart:convert';

import 'package:knocky/models/v2/lastpost.dart';

Forum forumFromJson(String str) => Forum.fromJson(json.decode(str));

String forumToJson(Forum data) => json.encode(data.toJson());

class Forum {
  Forum({
    this.list,
  });

  List<ListElement>? list;

  factory Forum.fromJson(Map<String, dynamic> json) => Forum(
        list: json["list"] == null
            ? null
            : List<ListElement>.from(
                json["list"].map((x) => ListElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "list": list == null
            ? null
            : List<dynamic>.from(list!.map((x) => x.toJson())),
      };
}

class ListElement {
  ListElement({
    this.id,
    this.name,
    this.iconId,
    this.description,
    this.icon,
    this.totalThreads,
    this.totalPosts,
    this.lastPostId,
    this.lastPost,
  });

  int? id;
  String? name;
  int? iconId;
  String? description;
  String? icon;
  int? totalThreads;
  int? totalPosts;
  int? lastPostId;
  ForumLastPost? lastPost;

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        iconId: json["iconId"] == null ? null : json["iconId"],
        description: json["description"] == null ? null : json["description"],
        icon: json["icon"] == null ? null : json["icon"],
        totalThreads:
            json["totalThreads"] == null ? null : json["totalThreads"],
        totalPosts: json["totalPosts"] == null ? null : json["totalPosts"],
        lastPostId: json["lastPostId"] == null ? null : json["lastPostId"],
        lastPost: json["lastPost"] == null
            ? null
            : ForumLastPost.fromJson(json["lastPost"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "iconId": iconId == null ? null : iconId,
        "description": description == null ? null : description,
        "icon": icon == null ? null : icon,
        "totalThreads": totalThreads == null ? null : totalThreads,
        "totalPosts": totalPosts == null ? null : totalPosts,
        "lastPostId": lastPostId == null ? null : lastPostId,
        "lastPost": lastPost == null ? null : lastPost!.toJson(),
      };
}
