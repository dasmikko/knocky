// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncSubscription _$SyncSubscriptionFromJson(Map<String, dynamic> json) =>
    SyncSubscription(
      id: (json['id'] as num).toInt(),
      unreadPosts: (json['unreadPosts'] as num).toInt(),
      firstUnreadId: (json['firstUnreadId'] as num).toInt(),
      threadId: (json['threadId'] as num).toInt(),
      iconId: (json['icon_id'] as num?)?.toInt(),
      threadIcon: (json['threadIcon'] as num?)?.toInt(),
      threadTitle: json['threadTitle'] as String,
      threadUser: (json['threadUser'] as num).toInt(),
      threadLocked: json['threadLocked'] as bool,
      threadCreatedAt: json['threadCreatedAt'] as String,
      threadUpdatedAt: json['threadUpdatedAt'] as String,
      threadDeletedAt: json['threadDeletedAt'],
      threadBackgroundUrl: json['threadBackgroundUrl'] as String?,
      threadBackgroundType: json['threadBackgroundType'] as String?,
      threadUsername: json['threadUsername'] as String,
      threadUserAvatarUrl: json['threadUserAvatarUrl'] as String,
      threadUserRoleCode: json['threadUserRoleCode'] as String,
      threadPostCount: (json['threadPostCount'] as num).toInt(),
      lastPost: json['lastPost'] == null
          ? null
          : Post.fromJson(json['lastPost'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SyncSubscriptionToJson(SyncSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unreadPosts': instance.unreadPosts,
      'firstUnreadId': instance.firstUnreadId,
      'threadId': instance.threadId,
      'icon_id': instance.iconId,
      'threadIcon': instance.threadIcon,
      'threadTitle': instance.threadTitle,
      'threadUser': instance.threadUser,
      'threadLocked': instance.threadLocked,
      'threadCreatedAt': instance.threadCreatedAt,
      'threadUpdatedAt': instance.threadUpdatedAt,
      'threadDeletedAt': instance.threadDeletedAt,
      'threadBackgroundUrl': instance.threadBackgroundUrl,
      'threadBackgroundType': instance.threadBackgroundType,
      'threadUsername': instance.threadUsername,
      'threadUserAvatarUrl': instance.threadUserAvatarUrl,
      'threadUserRoleCode': instance.threadUserRoleCode,
      'threadPostCount': instance.threadPostCount,
      'lastPost': instance.lastPost,
    };
