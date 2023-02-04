import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Viewers {
  final int? memberCount;
  Viewers({this.memberCount});

  factory Viewers.fromJson(Map<String, dynamic> json) {
    return Viewers(memberCount: json['memberCount'] as int?);
  }
}
