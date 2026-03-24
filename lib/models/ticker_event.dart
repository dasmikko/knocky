import 'package:json_annotation/json_annotation.dart';
import 'thread_user.dart';

part 'ticker_event.g.dart';

@JsonSerializable()
class TickerEvent {
  final int id;
  final String type;
  final ThreadUser creator;
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> content;
  final String createdAt;
  @JsonKey(fromJson: _dataFromJson)
  final Map<String, dynamic> data;

  TickerEvent({
    required this.id,
    required this.type,
    required this.creator,
    required this.content,
    required this.createdAt,
    required this.data,
  });

  factory TickerEvent.fromJson(Map<String, dynamic> json) =>
      _$TickerEventFromJson(json);
  Map<String, dynamic> toJson() => _$TickerEventToJson(this);

  // Convenience accessors for event data

  /// Thread title (for thread events)
  String? get threadTitle => data['title'] as String?;

  /// Thread ID (for thread events, or nested in post/ban events)
  int? get threadId {
    if (data.containsKey('title')) return data['id'] as int?;
    final thread = data['thread'];
    if (thread is Map<String, dynamic>) return thread['id'] as int?;
    return null;
  }

  /// Thread title from nested thread (for post/ban events)
  String? get nestedThreadTitle {
    final thread = data['thread'];
    if (thread is Map<String, dynamic>) return thread['title'] as String?;
    return null;
  }

  /// Subforum info (for thread-moved events)
  String? get subforumName {
    final subforum = data['subforum'];
    if (subforum is Map<String, dynamic>) return subforum['name'] as String?;
    return null;
  }

  int? get subforumId {
    final subforum = data['subforum'];
    if (subforum is Map<String, dynamic>) return subforum['id'] as int?;
    return null;
  }

  /// Target user (for user events like ban, avatar removed, etc.)
  String? get targetUsername {
    // For ban events, the target user is nested
    final user = data['user'];
    if (user is Map<String, dynamic>) return user['username'] as String?;
    // For user events, data itself is the user
    return data['username'] as String?;
  }

  int? get targetUserId {
    final user = data['user'];
    if (user is Map<String, dynamic>) return user['id'] as int?;
    return data['id'] as int?;
  }

  /// Ban reason (for ban events)
  String? get banReason => data['banReason'] as String?;

  /// Post page (for post/rating events)
  int? get postPage {
    if (data.containsKey('page')) return data['page'] as int?;
    return null;
  }

  /// Post ID (for post/rating events)
  int? get postId {
    if (data.containsKey('page')) return data['id'] as int?;
    return null;
  }
}

Map<String, dynamic> _dataFromJson(dynamic json) {
  if (json == null) return {};
  if (json is Map<String, dynamic>) return json;
  return {};
}
