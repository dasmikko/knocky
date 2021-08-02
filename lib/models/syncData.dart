import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/models/usergroup.dart';

part 'syncData.g.dart';

@JsonSerializable()
class SyncDataModel {
  final String avatarUrl;
  final String backgroundUrl;
  final int id;
  final bool isBanned;
  final List<SyncDataMentionModel> mentions;
  final Usergroup usergroup;
  final String username;
  final List<ThreadAlert> subscriptions;

  SyncDataModel(
      {this.avatarUrl,
      this.backgroundUrl,
      this.id,
      this.usergroup,
      this.username,
      this.isBanned,
      this.mentions,
      this.subscriptions});

  factory SyncDataModel.fromJson(Map<String, dynamic> json) =>
      _$SyncDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$SyncDataModelToJson(this);
}

@JsonSerializable()
class SyncDataMentionModel {
  @JsonKey(fromJson: _contentFromJson)
  final String content;
  final DateTime createdAt;
  final int mentionId;
  final int postId;
  final int threadId;
  final int threadPage;

  SyncDataMentionModel({
    this.content,
    this.postId,
    this.createdAt,
    this.mentionId,
    this.threadId,
    this.threadPage,
  });

  factory SyncDataMentionModel.fromJson(Map<String, dynamic> json) =>
      _$SyncDataMentionModelFromJson(json);
  Map<String, dynamic> toJson() => _$SyncDataMentionModelToJson(this);
}

String _contentFromJson(String jsonString) {
  List<dynamic> list = json.decode(jsonString) as List;
  return list.first;
}
