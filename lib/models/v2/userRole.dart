import 'package:knocky/helpers/enums.dart';

class UserRole {
  UserRole({
    this.id,
    this.code,
    this.description,
    this.permissionCodes,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  RoleCode code;
  String description;
  List<dynamic> permissionCodes;
  DateTime createdAt;
  DateTime updatedAt;

  factory UserRole.fromJson(Map<String, dynamic> json) => UserRole(
        id: json["id"] == null ? null : json["id"],
        code: json["code"] == null ? null : codeValues.map[json["code"]],
        description: json["description"] == null ? null : json["description"],
        permissionCodes: json["permissionCodes"] == null
            ? null
            : List<dynamic>.from(json["permissionCodes"].map((x) => x)),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "code": code == null ? null : codeValues.reverse[code],
        "description": description == null ? null : description,
        "permissionCodes": permissionCodes == null
            ? null
            : List<dynamic>.from(permissionCodes.map((x) => x)),
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
      };
}

enum RoleCode {
  GUEST,
  BANNED_USER,
  BASIC_USER,
  LIMITED_USER,
  GOLD_USER,
  PAID_GOLD_USER,
  MODERATOR,
  MODERATOR_IN_TRAINING,
  SUPER_MODERATOR,
  ADMIN,
}

final codeValues = EnumValues({
  "guest": RoleCode.GUEST,
  "banned-user": RoleCode.BANNED_USER,
  "basic-user": RoleCode.BASIC_USER,
  "limited-user": RoleCode.LIMITED_USER,
  "moderator": RoleCode.MODERATOR,
  "moderator-in-training": RoleCode.MODERATOR_IN_TRAINING,
  "super-moderator": RoleCode.SUPER_MODERATOR,
  "paid-gold-user": RoleCode.PAID_GOLD_USER,
  "gold-user": RoleCode.GOLD_USER,
});
