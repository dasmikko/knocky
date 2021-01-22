import 'package:json_annotation/json_annotation.dart';

part 'events.g.dart';

@JsonSerializable()
class KnockoutEvent {
  String content;
  DateTime createdAt;
  int executedBy;
  int id;

  KnockoutEvent({
    this.content,
    this.createdAt,
    this.id,
    this.executedBy,
  });

  factory KnockoutEvent.fromJson(Map<String, dynamic> json) =>
      _$KnockoutEventFromJson(json);
  Map<String, dynamic> toJson() => _$KnockoutEventToJson(this);
}
