import 'package:knocky/models/subforumDetails.dart';

class UserProfileThreads {
  final int currentPage;
  final int totalThreads;
  final List<SignificantThread> threads;

  UserProfileThreads({this.currentPage, this.totalThreads, this.threads});

  factory UserProfileThreads.fromJson(Map<String, dynamic> json) {
    return UserProfileThreads(
      currentPage: json['currentPage'] as int,
      totalThreads: json['totalThreads'] as int,
      threads: (json['threads'] as List)
          ?.map((e) => e == null
              ? null
              : SignificantThread.fromJson(e as Map<String, dynamic>))
          ?.toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        'currentPage': currentPage,
        'totalThreads': totalThreads,
        'threads': threads,
      };
}
