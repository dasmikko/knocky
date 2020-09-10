import 'package:json_annotation/json_annotation.dart';
import 'package:knocky_edge/models/subforumDetails.dart';

part 'userProfileThreads.g.dart';

@JsonSerializable()
class UserProfileThreads {
  final int currentPage;
  final int totalPosts;
  final List<SubforumThreadLatestPopular> threads;

  UserProfileThreads({this.currentPage, this.totalPosts, this.threads});

  factory UserProfileThreads.fromJson(Map<String, dynamic> json) =>
      _$UserProfileThreadsFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileThreadsToJson(this);
}
