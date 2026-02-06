import 'package:json_annotation/json_annotation.dart';

part 'viewers.g.dart';

@JsonSerializable()
class Viewers {
  final int memberCount;
  @JsonKey(defaultValue: 0)
  final int guestCount;

  Viewers({
    required this.memberCount,
    required this.guestCount,
  });

  factory Viewers.fromJson(Map<String, dynamic> json) =>
      _$ViewersFromJson(json);
  Map<String, dynamic> toJson() => _$ViewersToJson(this);
}
