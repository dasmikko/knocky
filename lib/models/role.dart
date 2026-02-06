import 'package:json_annotation/json_annotation.dart';

part 'role.g.dart';

@JsonSerializable()
class Role {
  final int id;
  final String code;
  final String description;
  final List<String> permissionCodes;
  final String createdAt;
  final String updatedAt;

  Role({
    required this.id,
    required this.code,
    required this.description,
    required this.permissionCodes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
