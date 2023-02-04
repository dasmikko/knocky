import 'package:knocky/models/subforumDetails.dart';

class UserProfileThreads {
  final int? currentPage;
  final int? totalThreads;
  final List<SignificantThread>? threads;

  UserProfileThreads({this.currentPage, this.totalThreads, this.threads});

  factory UserProfileThreads.fromJson(Map<String, dynamic> json) {
    return UserProfileThreads(
      currentPage: json['currentPage'] as int?,
      totalThreads: json['totalThreads'] as int?,
      threads: json['threads'] == null
          ? null
          : List<SignificantThread>.from(
              json['threads'].map(
                (x) => SignificantThread.fromJson(x),
              ),
            ),
    );
  }
  Map<String, dynamic> toJson() => {
        'currentPage': currentPage,
        'totalThreads': totalThreads,
        'threads': threads,
      };
}
