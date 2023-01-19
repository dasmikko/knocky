import 'package:knocky/models/thread.dart';

class UserProfilePosts {
  final int currentPage;
  final int totalPosts;
  final List<ProfileThreadPost> posts;

  UserProfilePosts({this.currentPage, this.totalPosts, this.posts});

  factory UserProfilePosts.fromJson(Map<String, dynamic> json) {
    return UserProfilePosts(
      currentPage: json['currentPage'] as int,
      totalPosts: json['totalPosts'] as int,
      posts: (json['posts'] as List)
          ?.map((e) => e == null
              ? null
              : ProfileThreadPost.fromJson(e as Map<String, dynamic>))
          ?.toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        'currentPage': currentPage,
        'totalPosts': totalPosts,
        'posts': posts,
      };
}

class ProfileThreadPost {
  ProfileThreadPost({
    this.id,
    this.thread,
    this.page,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.ratings,
    this.bans,
    this.threadPostNumber,
    this.countryName,
    this.countryCode,
    this.appName,
  });

  int id;
  Thread thread;
  int page;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  ThreadUser user;
  List<ThreadPostRating> ratings;
  List<dynamic> bans;
  int threadPostNumber;
  String countryName;
  String countryCode;
  String appName;

  factory ProfileThreadPost.fromJson(Map<String, dynamic> json) =>
      ProfileThreadPost(
        id: json["id"] == null ? null : json["id"],
        thread: json["thread"] == null ? null : Thread.fromJson(json["thread"]),
        page: json["page"] == null ? null : json["page"],
        content: json["content"] == null ? null : json["content"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        user: json["user"] == null ? null : ThreadUser.fromJson(json["user"]),
        ratings: json["ratings"] == null
            ? null
            : List<ThreadPostRating>.from(
                json["ratings"].map((x) => ThreadPostRating.fromJson(x))),
        bans: json["bans"] == null
            ? null
            : List<dynamic>.from(json["bans"].map((x) => x)),
        threadPostNumber:
            json["threadPostNumber"] == null ? null : json["threadPostNumber"],
        countryName: json["countryName"] == null ? null : json["countryName"],
        countryCode: json["countryCode"] == null ? null : json["countryCode"],
        appName: json["appName"] == null ? null : json["appName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "thread": thread == null ? null : thread,
        "page": page == null ? null : page,
        "content": content == null ? null : content,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "user": user == null ? null : user.toJson(),
        "ratings": ratings == null
            ? null
            : List<dynamic>.from(ratings.map((x) => x.toJson())),
        "bans": bans == null ? null : List<dynamic>.from(bans.map((x) => x)),
        "threadPostNumber": threadPostNumber == null ? null : threadPostNumber,
        "countryName": countryName == null ? null : countryName,
        "countryCode": countryCode == null ? null : countryCode,
        "appName": appName == null ? null : appName,
      };
}
