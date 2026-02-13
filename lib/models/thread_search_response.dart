import 'package:json_annotation/json_annotation.dart';
import 'thread.dart';

part 'thread_search_response.g.dart';

@JsonSerializable()
class ThreadSearchResponse {
  final int totalThreads;
  final List<Thread> threads;

  ThreadSearchResponse({
    required this.totalThreads,
    required this.threads,
  });

  int get totalPages => (totalThreads / 10).ceil().clamp(1, 9999);

  factory ThreadSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$ThreadSearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadSearchResponseToJson(this);
}
