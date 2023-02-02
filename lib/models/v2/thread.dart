import 'package:knocky/models/v2/lastpost.dart';
import 'package:knocky/models/v2/user.dart';

class ForumThread {
  ForumThread({
    this.id,
    this.title,
    this.iconId,
    this.subforumId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deleted,
    this.locked,
    this.pinned,
    this.lastPost,
    this.backgroundUrl,
    this.backgroundType,
    this.user,
    this.postCount,
    this.recentPostCount,
    this.unreadPostCount,
    this.readThreadUnreadPosts,
    this.read,
    this.hasRead,
    this.hasSeenNoNewPosts,
    this.subforum,
    this.tags,
    this.viewers,
  });

  int? id;
  String? title;
  int? iconId;
  int? subforumId;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  bool? deleted;
  bool? locked;
  bool? pinned;
  ForumThreadLastPost? lastPost;
  String? backgroundUrl;
  String? backgroundType;
  int? user;
  int? postCount;
  int? recentPostCount;
  int? unreadPostCount;
  int? readThreadUnreadPosts;
  bool? read;
  bool? hasRead;
  bool? hasSeenNoNewPosts;
  dynamic subforum;
  List<dynamic>? tags;
  Viewers? viewers;

  factory ForumThread.fromJson(Map<String, dynamic> json) => ForumThread(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        iconId: json["iconId"] == null ? null : json["iconId"],
        subforumId: json["subforumId"] == null ? null : json["subforumId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"] == null
            ? null
            : DateTime.parse(json["deletedAt"]),
        deleted: json["deleted"] == null ? null : json["deleted"],
        locked: json["locked"] == null ? null : json["locked"],
        pinned: json["pinned"] == null ? null : json["pinned"],
        lastPost: json["lastPost"] == null
            ? null
            : ForumThreadLastPost.fromJson(json["lastPost"]),
        backgroundUrl:
            json["backgroundUrl"] == null ? null : json["backgroundUrl"],
        backgroundType:
            json["backgroundType"] == null ? null : json["backgroundType"],
        user: json["user"] == null ? null : json["user"],
        postCount: json["postCount"] == null ? null : json["postCount"],
        recentPostCount:
            json["recentPostCount"] == null ? null : json["recentPostCount"],
        unreadPostCount:
            json["unreadPostCount"] == null ? null : json["unreadPostCount"],
        readThreadUnreadPosts: json["readThreadUnreadPosts"] == null
            ? null
            : json["readThreadUnreadPosts"],
        read: json["read"] == null ? null : json["read"],
        hasRead: json["hasRead"] == null ? null : json["hasRead"],
        hasSeenNoNewPosts: json["hasSeenNoNewPosts"] == null
            ? null
            : json["hasSeenNoNewPosts"],
        subforum: json["subforum"],
        tags: json["tags"] == null
            ? null
            : List<dynamic>.from(json["tags"].map((x) => x)),
        viewers:
            json["viewers"] == null ? null : Viewers.fromJson(json["viewers"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "iconId": iconId == null ? null : iconId,
        "subforumId": subforumId == null ? null : subforumId,
        "createdAt": createdAt == null ? null : createdAt!.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "deletedAt": deletedAt == null ? null : deletedAt!.toIso8601String(),
        "deleted": deleted == null ? null : deleted,
        "locked": locked == null ? null : locked,
        "pinned": pinned == null ? null : pinned,
        "lastPost": lastPost == null ? null : lastPost!.toJson(),
        "backgroundUrl": backgroundUrl == null ? null : backgroundUrl,
        "backgroundType": backgroundType == null ? null : backgroundType,
        "user": user == null ? null : user,
        "postCount": postCount == null ? null : postCount,
        "recentPostCount": recentPostCount == null ? null : recentPostCount,
        "unreadPostCount": unreadPostCount == null ? null : unreadPostCount,
        "readThreadUnreadPosts":
            readThreadUnreadPosts == null ? null : readThreadUnreadPosts,
        "read": read == null ? null : read,
        "hasRead": hasRead == null ? null : hasRead,
        "hasSeenNoNewPosts":
            hasSeenNoNewPosts == null ? null : hasSeenNoNewPosts,
        "subforum": subforum,
        "tags": tags == null ? null : List<dynamic>.from(tags!.map((x) => x)),
        "viewers": viewers == null ? null : viewers!.toJson(),
      };
}

class SubforumThread {
  SubforumThread({
    this.id,
    this.title,
    this.iconId,
    this.subforumId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deleted,
    this.locked,
    this.pinned,
    this.lastPost,
    this.backgroundUrl,
    this.backgroundType,
    this.user,
    this.postCount,
    this.recentPostCount,
    this.unreadPostCount,
    this.readThreadUnreadPosts,
    this.read,
    this.hasRead,
    this.hasSeenNoNewPosts,
    this.firstUnreadId,
    this.firstPostTopRating,
    this.subforum,
    this.tags,
    this.viewers,
  });

  int? id;
  String? title;
  int? iconId;
  int? subforumId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  bool? deleted;
  bool? locked;
  bool? pinned;
  SubforumThreadLastPost? lastPost;
  String? backgroundUrl;
  String? backgroundType;
  User? user;
  int? postCount;
  int? recentPostCount;
  int? unreadPostCount;
  int? readThreadUnreadPosts;
  bool? read;
  bool? hasRead;
  bool? hasSeenNoNewPosts;
  int? firstUnreadId;
  FirstPostTopRating? firstPostTopRating;
  dynamic subforum;
  List<Map<String, String>>? tags;
  Viewers? viewers;

  factory SubforumThread.fromJson(Map<String, dynamic> json) => SubforumThread(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        iconId: json["iconId"] == null ? null : json["iconId"],
        subforumId: json["subforumId"] == null ? null : json["subforumId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        deleted: json["deleted"] == null ? null : json["deleted"],
        locked: json["locked"] == null ? null : json["locked"],
        pinned: json["pinned"] == null ? null : json["pinned"],
        lastPost: json["lastPost"] == null
            ? null
            : SubforumThreadLastPost.fromJson(json["lastPost"]),
        backgroundUrl:
            json["backgroundUrl"] == null ? null : json["backgroundUrl"],
        backgroundType:
            json["backgroundType"] == null ? null : json["backgroundType"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        postCount: json["postCount"] == null ? null : json["postCount"],
        recentPostCount:
            json["recentPostCount"] == null ? null : json["recentPostCount"],
        unreadPostCount:
            json["unreadPostCount"] == null ? null : json["unreadPostCount"],
        readThreadUnreadPosts: json["readThreadUnreadPosts"] == null
            ? null
            : json["readThreadUnreadPosts"],
        read: json["read"] == null ? null : json["read"],
        hasRead: json["hasRead"] == null ? null : json["hasRead"],
        hasSeenNoNewPosts: json["hasSeenNoNewPosts"] == null
            ? null
            : json["hasSeenNoNewPosts"],
        firstUnreadId:
            json["firstUnreadId"] == null ? null : json["firstUnreadId"],
        firstPostTopRating: json["firstPostTopRating"] == null
            ? null
            : FirstPostTopRating.fromJson(json["firstPostTopRating"]),
        subforum: json["subforum"],
        tags: json["tags"] == null
            ? null
            : List<Map<String, String>>.from(json["tags"].map((x) =>
                Map.from(x).map((k, v) => MapEntry<String, String>(k, v)))),
        viewers:
            json["viewers"] == null ? null : Viewers.fromJson(json["viewers"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "iconId": iconId == null ? null : iconId,
        "subforumId": subforumId == null ? null : subforumId,
        "createdAt": createdAt == null ? null : createdAt!.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "deletedAt": deletedAt,
        "deleted": deleted == null ? null : deleted,
        "locked": locked == null ? null : locked,
        "pinned": pinned == null ? null : pinned,
        "lastPost": lastPost == null ? null : lastPost!.toJson(),
        "backgroundUrl": backgroundUrl == null ? null : backgroundUrl,
        "backgroundType": backgroundType == null ? null : backgroundType,
        "user": user == null ? null : user!.toJson(),
        "postCount": postCount == null ? null : postCount,
        "recentPostCount": recentPostCount == null ? null : recentPostCount,
        "unreadPostCount": unreadPostCount == null ? null : unreadPostCount,
        "readThreadUnreadPosts":
            readThreadUnreadPosts == null ? null : readThreadUnreadPosts,
        "read": read == null ? null : read,
        "hasRead": hasRead == null ? null : hasRead,
        "hasSeenNoNewPosts":
            hasSeenNoNewPosts == null ? null : hasSeenNoNewPosts,
        "firstUnreadId": firstUnreadId == null ? null : firstUnreadId,
        "firstPostTopRating":
            firstPostTopRating == null ? null : firstPostTopRating!.toJson(),
        "subforum": subforum,
        "tags": tags == null
            ? null
            : List<dynamic>.from(tags!.map((x) =>
                Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v)))),
        "viewers": viewers == null ? null : viewers!.toJson(),
      };
}

class Viewers {
  Viewers({
    this.memberCount,
    this.guestCount,
  });

  int? memberCount;
  int? guestCount;

  factory Viewers.fromJson(Map<String, dynamic> json) => Viewers(
        memberCount: json["memberCount"] == null ? null : json["memberCount"],
        guestCount: json["guestCount"] == null ? null : json["guestCount"],
      );

  Map<String, dynamic> toJson() => {
        "memberCount": memberCount == null ? null : memberCount,
        "guestCount": guestCount == null ? null : guestCount,
      };
}

class FirstPostTopRating {
  FirstPostTopRating({
    this.id,
    this.rating,
    this.ratingId,
    this.users,
    this.count,
  });

  int? id;
  String? rating;
  int? ratingId;
  List<dynamic>? users;
  int? count;

  factory FirstPostTopRating.fromJson(Map<String, dynamic> json) =>
      FirstPostTopRating(
        id: json["id"] == null ? null : json["id"],
        rating: json["rating"] == null ? null : json["rating"],
        ratingId: json["ratingId"] == null ? null : json["ratingId"],
        users: json["users"] == null
            ? null
            : List<dynamic>.from(json["users"].map((x) => x)),
        count: json["count"] == null ? null : json["count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "rating": rating == null ? null : rating,
        "ratingId": ratingId == null ? null : ratingId,
        "users": users == null ? null : List<dynamic>.from(users!.map((x) => x)),
        "count": count == null ? null : count,
      };
}
