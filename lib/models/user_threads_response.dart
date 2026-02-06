import 'package:json_annotation/json_annotation.dart';
import 'user_thread.dart';

part 'user_threads_response.g.dart';

@JsonSerializable()
class UserThreadsResponse {
  final int totalThreads;
  final int currentPage;
  final List<UserThread> threads;

  /// Calculate total pages (20 threads per page)
  int get totalPages => (totalThreads / 20).ceil();

  UserThreadsResponse({
    required this.totalThreads,
    required this.currentPage,
    required this.threads,
  });

  factory UserThreadsResponse.fromJson(Map<String, dynamic> json) =>
      _$UserThreadsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserThreadsResponseToJson(this);
}
