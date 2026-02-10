import 'package:json_annotation/json_annotation.dart';
import 'thread_user.dart';

part 'ban.g.dart';

@JsonSerializable()
class Ban {
  final int id;
  final String banReason;
  final String expiresAt;
  final String createdAt;
  final String updatedAt;
  final ThreadUser? user;
  final ThreadUser? bannedBy;

  Ban({
    required this.id,
    required this.banReason,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.bannedBy,
  });

  bool get isPermanent {
    final expiry = DateTime.tryParse(expiresAt);
    if (expiry == null) return false;
    return expiry.year >= 2099;
  }

  factory Ban.fromJson(Map<String, dynamic> json) => _$BanFromJson(json);
  Map<String, dynamic> toJson() => _$BanToJson(this);
}
