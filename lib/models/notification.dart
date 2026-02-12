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

  /// Raw JSON data for non-MESSAGE types (POST_REPLY, POST_MENTION,
  /// PROFILE_COMMENT, REPORT_RESOLUTION).
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic>? rawData;

  KnockyNotification({
    required this.id,
    required this.type,
    required this.userId,
    required this.read,
    required this.createdAt,
    this.data,
    this.rawData,
  });

  factory KnockyNotification.fromJson(Map<String, dynamic> json) {
    final notification = _$KnockyNotificationFromJson(json);
    final rawData = json['data'] as Map<String, dynamic>?;

    if (json['type'] == 'MESSAGE' && rawData != null) {
      try {
        return KnockyNotification(
          id: notification.id,
          type: notification.type,
          userId: notification.userId,
          read: notification.read,
          createdAt: notification.createdAt,
          data: Conversation.fromJson(rawData),
          rawData: rawData,
        );
      } catch (_) {
        return KnockyNotification(
          id: notification.id,
          type: notification.type,
          userId: notification.userId,
          read: notification.read,
          createdAt: notification.createdAt,
          rawData: rawData,
        );
      }
    }

    return KnockyNotification(
      id: notification.id,
      type: notification.type,
      userId: notification.userId,
      read: notification.read,
      createdAt: notification.createdAt,
      rawData: rawData,
    );
  }

  Map<String, dynamic> toJson() => _$KnockyNotificationToJson(this);
}
