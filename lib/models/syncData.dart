import 'dart:convert';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/models/usergroup.dart';
import 'package:knocky/models/v2/userRole.dart';

class SyncDataModel {
  final String? avatarUrl;
  final String? backgroundUrl;
  final int? id;
  final bool? isBanned;
  final List<SyncDataMentionModel>? mentions;
  final Usergroup? usergroup;
  final UserRole? role;
  final String? username;
  final List<ThreadAlert>? subscriptions;

  SyncDataModel(
      {this.avatarUrl,
      this.backgroundUrl,
      this.id,
      this.usergroup,
      this.username,
      this.isBanned,
      this.mentions,
      this.subscriptions,
      this.role});

  factory SyncDataModel.fromJson(Map<String, dynamic> json) {
    return SyncDataModel(
      avatarUrl: json['avatarUrl'] as String?,
      backgroundUrl: json['backgroundUrl'] as String?,
      id: json['id'] as int?,
      role: json['role'] == null ? null : UserRole.fromJson(json['role']),
      usergroup: json['usergroup'] == null
          ? null
          : Usergroup.values[json['usergroup'] as int],
      username: json['username'] as String?,
      isBanned: json['isBanned'] as bool?,
      mentions: json['mentions'] == null
          ? null
          : List<SyncDataMentionModel>.from(
              json['mentions'].map(
                (x) => SyncDataMentionModel.fromJson(x),
              ),
            ),
      subscriptions: json['subscriptions'] == null
          ? null
          : List<ThreadAlert>.from(
              json['subscriptions'].map(
                (x) => ThreadAlert.fromJson(x),
              ),
            ),
    );
  }
  Map<String, dynamic> toJson() => {
        'avatarUrl': avatarUrl,
        'backgroundUrl': backgroundUrl,
        'id': id,
        'isBanned': isBanned,
        'mentions': mentions,
        'usergroup': usergroup,
        'username': username,
      };
}

class SyncDataMentionModel {
  final String? content;
  final DateTime? createdAt;
  final int? mentionId;
  final int? postId;
  final int? threadId;
  final int? threadPage;

  SyncDataMentionModel({
    this.content,
    this.postId,
    this.createdAt,
    this.mentionId,
    this.threadId,
    this.threadPage,
  });

  factory SyncDataMentionModel.fromJson(Map<String, dynamic> json) {
    return SyncDataMentionModel(
      content: _contentFromJson(json['content'] as String),
      postId: json['postId'] as int?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      mentionId: json['mentionId'] as int?,
      threadId: json['threadId'] as int?,
      threadPage: json['threadPage'] as int?,
    );
  }
  Map<String, dynamic> toJson() => {
        'content': content,
        'createdAt': createdAt!.toIso8601String(),
        'mentionId': mentionId,
        'postId': postId,
        'threadId': threadId,
        'threadPage': threadPage,
      };
}

String _contentFromJson(String jsonString) {
  List<dynamic> list = json.decode(jsonString) as List;
  return list.first;
}
