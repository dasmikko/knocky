import 'package:json_annotation/json_annotation.dart';
import 'subforum_detail.dart';
import 'thread.dart';

part 'subforum_response.g.dart';

@JsonSerializable()
class SubforumResponse {
  final SubforumDetail subforum;
  final int page;
  final List<Thread> threads;

  SubforumResponse({
    required this.subforum,
    required this.page,
    required this.threads,
  });

  int get totalPages => (subforum.totalThreads / 20).ceil().clamp(1, 9999);

  factory SubforumResponse.fromJson(Map<String, dynamic> json) =>
      _$SubforumResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumResponseToJson(this);
}
