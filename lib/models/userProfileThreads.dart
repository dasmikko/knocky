import 'package:json_annotation/json_annotation.dart';
import 'package:knocky/models/subforumDetails.dart';

part 'userProfileThreads.g.dart';

@JsonSerializable()
class UserProfileThreads {
  final int currentPage;
  final int totalThreads;
  final List<SignificantThread> threads;

  UserProfileThreads({this.currentPage, this.totalThreads, this.threads});

  factory UserProfileThreads.fromJson(Map<String, dynamic> json) =>
      _$UserProfileThreadsFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileThreadsToJson(this);
}
