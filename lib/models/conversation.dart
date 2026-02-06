import 'package:json_annotation/json_annotation.dart';
import 'message.dart';
import 'thread_user.dart';

part 'conversation.g.dart';

@JsonSerializable()
class Conversation {
  final int id;
  final List<Message> messages;
  final List<ThreadUser> users;
  final String createdAt;
  final String updatedAt;

  Conversation({
    required this.id,
    required this.messages,
    required this.users,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the other participants in the conversation (excluding the current user)
  List<ThreadUser> getOtherUsers(int currentUserId) {
    return users.where((u) => u.id != currentUserId).toList();
  }

  /// Get the latest message in the conversation
  Message? get latestMessage => messages.isNotEmpty ? messages.first : null;

  /// Check if there are unread messages
  bool hasUnread(int currentUserId) {
    return messages.any((m) => m.user.id != currentUserId && m.readAt == null);
  }

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}
