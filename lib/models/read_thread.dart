import 'package:json_annotation/json_annotation.dart';

part 'read_thread.g.dart';

@JsonSerializable()
class ReadThread {
  final int lastPostNumber;
  final String lastSeen;
  final bool? isSubscription;
  final int firstUnreadId;
  final int unreadPostCount;

  ReadThread({
    required this.lastPostNumber,
    required this.lastSeen,
    this.isSubscription,
    required this.firstUnreadId,
    required this.unreadPostCount,
  });

  factory ReadThread.fromJson(Map<String, dynamic> json) =>
      _$ReadThreadFromJson(json);
  Map<String, dynamic> toJson() => _$ReadThreadToJson(this);
}
