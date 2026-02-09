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

  @JsonKey(includeFromJson: false, includeToJson: false)
  final Conversation? data;

  KnockyNotification({
    required this.id,
    required this.type,
    required this.userId,
    required this.read,
    required this.createdAt,
    this.data,
  });

  factory KnockyNotification.fromJson(Map<String, dynamic> json) {
    final notification = _$KnockyNotificationFromJson(json);
    // Only parse data as Conversation for MESSAGE notifications.
    // Other types (POST_REPLY, POST_MENTION, PROFILE_COMMENT, REPORT_RESOLUTION)
    // have differently shaped data.
    if (json['type'] == 'MESSAGE' && json['data'] is Map<String, dynamic>) {
      try {
        return KnockyNotification(
          id: notification.id,
          type: notification.type,
          userId: notification.userId,
          read: notification.read,
          createdAt: notification.createdAt,
          data: Conversation.fromJson(json['data'] as Map<String, dynamic>),
        );
      } catch (_) {
        return notification;
      }
    }
    return notification;
  }

  Map<String, dynamic> toJson() => _$KnockyNotificationToJson(this);
}
