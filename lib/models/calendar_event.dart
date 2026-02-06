import 'package:json_annotation/json_annotation.dart';
import 'thread_user.dart';

part 'calendar_event.g.dart';

/// Simplified thread model for calendar events.
/// The API returns thread.user as just an int (user ID), not a full object.
@JsonSerializable()
class CalendarEventThread {
  final int id;
  final String title;
  final int iconId;
  final int subforumId;
  final String? backgroundUrl;
  final String? backgroundType;

  CalendarEventThread({
    required this.id,
    required this.title,
    required this.iconId,
    required this.subforumId,
    this.backgroundUrl,
    this.backgroundType,
  });

  factory CalendarEventThread.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventThreadFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarEventThreadToJson(this);
}

@JsonSerializable()
class CalendarEvent {
  final int id;
  final ThreadUser createdBy;
  final String title;
  final String description;
  @JsonKey(fromJson: _threadFromJson)
  final CalendarEventThread? thread;
  final String startsAt;
  final String endsAt;
  final String createdAt;
  final String updatedAt;

  CalendarEvent({
    required this.id,
    required this.createdBy,
    required this.title,
    required this.description,
    this.thread,
    required this.startsAt,
    required this.endsAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);
}

CalendarEventThread? _threadFromJson(dynamic json) {
  if (json == null) return null;
  if (json is Map<String, dynamic> && json.isEmpty) return null;
  return CalendarEventThread.fromJson(json as Map<String, dynamic>);
}
