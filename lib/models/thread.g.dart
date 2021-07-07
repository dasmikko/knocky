// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Thread _$ThreadFromJson(Map<String, dynamic> json) {
  return Thread(
    currentPage: json['currentPage'] as int,
    iconId: json['iconId'] as int,
    readThreadLastSeen: json['readThreadLastSeen'] == null
        ? null
        : DateTime.parse(json['readThreadLastSeen'] as String),
    id: json['id'] as int,
    locked: json['locked'] as bool,
    pinned: json['pinned'] as bool,
    title: json['title'] as String,
    totalPosts: json['totalPosts'] as int,
    subforumId: json['subforumId'] as int,
    subforumName: json['subforumName'] as String,
    posts: (json['posts'] as List)
        ?.map((e) =>
            e == null ? null : ThreadPost.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    user: json['user'] == null
        ? null
        : ThreadUser.fromJson(json['user'] as Map<String, dynamic>),
    subscriptionLastSeen: json['subscriptionLastSeen'] == null
        ? null
        : DateTime.parse(json['subscriptionLastSeen'] as String),
    subscriptionLastPostNumber: json['subscriptionLastPostNumber'] as int,
    subscribed: json['subscribed'] as bool ?? 0,
    userId: json['userId'] as int,
    threadBackgroundType: json['threadBackgroundType'] as String,
    threadBackgroundUrl: json['threadBackgroundUrl'] as String,
  );
}

Map<String, dynamic> _$ThreadToJson(Thread instance) => <String, dynamic>{
      'id': instance.id,
      'currentPage': instance.currentPage,
      'iconId': instance.iconId,
      'locked': instance.locked,
      'pinned': instance.pinned,
      'subforumId': instance.subforumId,
      'subforumName': instance.subforumName,
      'title': instance.title,
      'totalPosts': instance.totalPosts,
      'readThreadLastSeen': instance.readThreadLastSeen?.toIso8601String(),
      'subscriptionLastSeen': instance.subscriptionLastSeen?.toIso8601String(),
      'subscriptionLastPostNumber': instance.subscriptionLastPostNumber,
      'posts': instance.posts,
      'user': instance.user,
      'userId': instance.userId,
      'subscribed': instance.subscribed,
      'threadBackgroundType': instance.threadBackgroundType,
      'threadBackgroundUrl': instance.threadBackgroundUrl,
    };

ThreadUser _$ThreadUserFromJson(Map<String, dynamic> json) {
  return ThreadUser(
    usergroup: json['usergroup'] as int,
    username: json['username'] as String,
  );
}

Map<String, dynamic> _$ThreadUserToJson(ThreadUser instance) =>
    <String, dynamic>{
      'usergroup': instance.usergroup,
      'username': instance.username,
    };

ThreadPost _$ThreadPostFromJson(Map<String, dynamic> json) {
  return ThreadPost(
    id: json['id'] as int,
    content: _contentFromJson(json['content'] as String),
    user: json['user'] == null
        ? null
        : ThreadPostUser.fromJson(json['user'] as Map<String, dynamic>),
    thread: json['thread'] as int,
    threadPostNumber: json['threadPostNumber'] as int,
    ratings: (json['ratings'] as List)
        ?.map((e) => e == null
            ? null
            : ThreadPostRatings.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    bans: (json['bans'] as List)
        ?.map((e) => e == null
            ? null
            : ThreadPostBan.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ThreadPostToJson(ThreadPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt?.toIso8601String(),
      'content': _contentToJson(instance.content),
      'user': instance.user,
      'ratings': instance.ratings,
      'thread': instance.thread,
      'threadPostNumber': instance.threadPostNumber,
      'bans': instance.bans,
    };

ThreadPostBan _$ThreadPostBanFromJson(Map<String, dynamic> json) {
  return ThreadPostBan(
    banBannedBy: json['banBannedBy'] as String,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    expiresAt: json['expiresAt'] == null
        ? null
        : DateTime.parse(json['expiresAt'] as String),
    post: json['post'] as int,
    banReason: json['banReason'] as String,
  );
}

Map<String, dynamic> _$ThreadPostBanToJson(ThreadPostBan instance) =>
    <String, dynamic>{
      'banBannedBy': instance.banBannedBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'post': instance.post,
      'banReason': instance.banReason,
    };

ThreadPostRatings _$ThreadPostRatingsFromJson(Map<String, dynamic> json) {
  return ThreadPostRatings(
    ratingId: _ratingIdHandler(json['rating_id']),
    rating: json['rating'] as String,
    count: json['count'] as int,
    users: (json['users'] as List)
        ?.map((e) => e == null
            ? null
            : ThreadPostUser.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ThreadPostRatingsToJson(ThreadPostRatings instance) =>
    <String, dynamic>{
      'rating_id': instance.ratingId,
      'rating': instance.rating,
      'count': instance.count,
      'users': instance.users,
    };

ThreadPostUser _$ThreadPostUserFromJson(Map<String, dynamic> json) {
  return ThreadPostUser(
    id: json['id'] as int,
    avatarUrl: json['avatarUrl'] as String,
    backgroundUrl: json['backgroundUrl'] as String,
    isBanned: json['isBanned'] as bool,
    usergroup: json['usergroup'] as int,
    username: json['username'] as String,
  );
}

Map<String, dynamic> _$ThreadPostUserToJson(ThreadPostUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'avatarUrl': instance.avatarUrl,
      'backgroundUrl': instance.backgroundUrl,
      'isBanned': instance.isBanned,
      'usergroup': instance.usergroup,
      'username': instance.username,
    };
