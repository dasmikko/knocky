import 'package:json_annotation/json_annotation.dart';
import 'thread_user.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final int id;
  final int conversationId;
  final ThreadUser? user;
  final String content;
  final String? readAt;
  final String createdAt;
  final String updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    this.user,
    required this.content,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
