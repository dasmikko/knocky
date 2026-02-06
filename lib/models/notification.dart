import 'package:json_annotation/json_annotation.dart';
import 'conversation.dart';

part 'notification.g.dart';

@JsonSerializable()
class KnockyNotification {
  final int id;
  final String type;
  final int userId;
  final bool read;
  final String createdAt;
  final Conversation? data;

  KnockyNotification({
    required this.id,
    required this.type,
    required this.userId,
    required this.read,
    required this.createdAt,
    this.data,
  });

  factory KnockyNotification.fromJson(Map<String, dynamic> json) =>
      _$KnockyNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$KnockyNotificationToJson(this);
}
