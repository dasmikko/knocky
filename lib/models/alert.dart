import 'package:json_annotation/json_annotation.dart';
import 'thread.dart';

part 'alert.g.dart';

@JsonSerializable()
class Alert {
  final int id;
  final Thread thread;
  final int unreadPosts;
  final int firstUnreadId;

  Alert({
    required this.id,
    required this.thread,
    required this.unreadPosts,
    required this.firstUnreadId,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
  Map<String, dynamic> toJson() => _$AlertToJson(this);
}
