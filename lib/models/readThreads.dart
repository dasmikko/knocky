import 'package:json_annotation/json_annotation.dart';

part 'readThreads.g.dart';

@JsonSerializable()
class ReadThreads {
  int lastPostNumber;
  DateTime lastSeen;
  int threadId;

  ReadThreads({this.lastPostNumber, this.lastSeen, this.threadId});

  factory ReadThreads.fromJson(Map<String, dynamic> json) =>
      _$ReadThreadsFromJson(json);
  Map<String, dynamic> toJson() => _$ReadThreadsToJson(this);
}
