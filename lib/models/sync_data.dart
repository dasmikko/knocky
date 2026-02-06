import 'package:json_annotation/json_annotation.dart';
import 'role.dart';
import 'sync_subscription.dart';

part 'sync_data.g.dart';

@JsonSerializable()
class SyncData {
  final int id;
  final String username;
  final bool isBanned;
  final String avatarUrl;
  final String backgroundUrl;
  final String createdAt;
  final Role role;
  final List<dynamic> mentions;
  final List<SyncSubscription> subscriptions;
  final List<int> subscriptionIds;

  SyncData({
    required this.id,
    required this.username,
    required this.isBanned,
    required this.avatarUrl,
    required this.backgroundUrl,
    required this.createdAt,
    required this.role,
    this.mentions = const [],
    this.subscriptions = const [],
    this.subscriptionIds = const [],
  });

  factory SyncData.fromJson(Map<String, dynamic> json) =>
      _$SyncDataFromJson(json);
  Map<String, dynamic> toJson() => _$SyncDataToJson(this);
}
