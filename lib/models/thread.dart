//import 'package:knocky/models/slateDocument.dart';
import 'dart:convert';
import 'package:knocky/models/usergroup.dart';

// To parse this JSON data, do
//
//     final thread = threadFromJson(jsonString);

Thread threadFromJson(String str) => Thread.fromJson(json.decode(str));

String threadToJson(Thread data) => json.encode(data.toJson());

class Thread {
  Thread({
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
    this.totalPosts,
    this.currentPage,
    this.threadBackgroundUrl,
    this.threadBackgroundType,
    this.posts,
    this.readThreadLastSeen,
    this.subscribed,
    this.subscriptionLastSeen,
    this.subscriptionLastPostNumber,
  });

  int id;
  String title;
  int iconId;
  int subforumId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  bool deleted;
  bool locked;
  bool pinned;
  ThreadPost lastPost;
  dynamic backgroundUrl;
  dynamic backgroundType;
  ThreadUser user;
  int postCount;
  int recentPostCount;
  int unreadPostCount;
  int readThreadUnreadPosts;
  bool read;
  bool hasRead;
  bool hasSeenNoNewPosts;
  ThreadSubforum subforum;
  List<dynamic> tags;
  ThreadViewers viewers;
  int totalPosts;
  int currentPage;
  dynamic threadBackgroundUrl;
  dynamic threadBackgroundType;
  List<ThreadPost> posts;
  DateTime readThreadLastSeen;
  bool subscribed;
  DateTime subscriptionLastSeen;
  int subscriptionLastPostNumber;

  factory Thread.fromJson(Map<String, dynamic> json) => Thread(
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
            : ThreadPost.fromJson(json["lastPost"]),
        backgroundUrl: json["backgroundUrl"],
        backgroundType: json["backgroundType"],
        user: json["user"] == null ? null : ThreadUser.fromJson(json["user"]),
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
        subforum: json["subforum"] == null
            ? null
            : ThreadSubforum.fromJson(json["subforum"]),
        tags: json["tags"] == null
            ? null
            : List<dynamic>.from(json["tags"].map((x) => x)),
        viewers: json["viewers"] == null
            ? null
            : ThreadViewers.fromJson(json["viewers"]),
        totalPosts: json["totalPosts"] == null ? null : json["totalPosts"],
        currentPage: json["currentPage"] == null ? null : json["currentPage"],
        threadBackgroundUrl: json["threadBackgroundUrl"],
        threadBackgroundType: json["threadBackgroundType"],
        posts: json["posts"] == null
            ? null
            : List<ThreadPost>.from(
                json["posts"].map((x) => ThreadPost.fromJson(x))),
        readThreadLastSeen: json["readThreadLastSeen"] == null
            ? null
            : DateTime.parse(json["readThreadLastSeen"]),
        subscribed: json["subscribed"] == null ? null : json["subscribed"],
        subscriptionLastSeen: json["subscriptionLastSeen"] == null
            ? null
            : DateTime.parse(json["subscriptionLastSeen"]),
        subscriptionLastPostNumber: json["subscriptionLastPostNumber"] == null
            ? null
            : json["subscriptionLastPostNumber"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "iconId": iconId == null ? null : iconId,
        "subforumId": subforumId == null ? null : subforumId,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "deletedAt": deletedAt,
        "deleted": deleted == null ? null : deleted,
        "locked": locked == null ? null : locked,
        "pinned": pinned == null ? null : pinned,
        "lastPost": lastPost == null ? null : lastPost.toJson(),
        "backgroundUrl": backgroundUrl,
        "backgroundType": backgroundType,
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
        "subforum": subforum == null ? null : subforum.toJson(),
        "tags": tags == null ? null : List<dynamic>.from(tags.map((x) => x)),
        "viewers": viewers == null ? null : viewers.toJson(),
        "totalPosts": totalPosts == null ? null : totalPosts,
        "currentPage": currentPage == null ? null : currentPage,
        "threadBackgroundUrl": threadBackgroundUrl,
        "threadBackgroundType": threadBackgroundType,
        "posts": posts == null
            ? null
            : List<dynamic>.from(posts.map((x) => x.toJson())),
        "readThreadLastSeen": readThreadLastSeen == null
            ? null
            : readThreadLastSeen.toIso8601String(),
        "subscribed": subscribed == null ? null : subscribed,
        "subscriptionLastSeen": subscriptionLastSeen == null
            ? null
            : subscriptionLastSeen.toIso8601String(),
        "subscriptionLastPostNumber": subscriptionLastPostNumber == null
            ? null
            : subscriptionLastPostNumber,
      };
}

class ThreadPost {
  ThreadPost({
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
  int thread;
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

  factory ThreadPost.fromJson(Map<String, dynamic> json) => ThreadPost(
        id: json["id"] == null ? null : json["id"],
        thread: json["thread"] == null ? null : json["thread"],
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

class ThreadPostRating {
  ThreadPostRating({
    this.id,
    this.rating,
    this.ratingId,
    this.users,
    this.count,
  });

  int id;
  String rating;
  int ratingId;
  List<ThreadUser> users;
  int count;

  factory ThreadPostRating.fromJson(Map<String, dynamic> json) =>
      ThreadPostRating(
        id: json["id"] == null ? null : json["id"],
        rating: json["rating"] == null ? null : json["rating"],
        ratingId: json["ratingId"] == null ? null : json["ratingId"],
        users: json["users"] == null
            ? null
            : List<ThreadUser>.from(
                json["users"].map((x) => ThreadUser.fromJson(x))),
        count: json["count"] == null ? null : json["count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "rating": rating == null ? null : rating,
        "ratingId": ratingId == null ? null : ratingId,
        "users": users == null
            ? null
            : List<dynamic>.from(users.map((x) => x.toJson())),
        "count": count == null ? null : count,
      };
}

class ThreadUser {
  ThreadUser({
    this.id,
    this.role,
    this.username,
    this.usergroup,
    this.avatarUrl,
    this.backgroundUrl,
    this.posts,
    this.threads,
    this.createdAt,
    this.updatedAt,
    this.banned,
    this.isBanned,
    this.title,
    this.pronouns,
    this.useBioForTitle,
  });

  int id;
  ThreadUserRole role;
  String username;
  Usergroup usergroup;
  String avatarUrl;
  String backgroundUrl;
  int posts;
  int threads;
  DateTime createdAt;
  DateTime updatedAt;
  bool banned;
  bool isBanned;
  String title;
  String pronouns;
  int useBioForTitle;

  factory ThreadUser.fromJson(Map<String, dynamic> json) => ThreadUser(
        id: json["id"] == null ? null : json["id"],
        role:
            json["role"] == null ? null : ThreadUserRole.fromJson(json["role"]),
        username: json["username"] == null ? null : json["username"],
        usergroup: json["usergroup"] == null
            ? null
            : Usergroup.values[json['usergroup'] as int],
        avatarUrl: json["avatarUrl"] == null ? null : json["avatarUrl"],
        backgroundUrl:
            json["backgroundUrl"] == null ? null : json["backgroundUrl"],
        posts: json["posts"] == null ? null : json["posts"],
        threads: json["threads"] == null ? null : json["threads"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        banned: json["banned"] == null ? null : json["banned"],
        isBanned: json["isBanned"] == null ? null : json["isBanned"],
        title: json["title"] == null ? null : json["title"],
        pronouns: json["pronouns"] == null ? null : json["pronouns"],
        useBioForTitle:
            json["useBioForTitle"] == null ? null : json["useBioForTitle"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "role": role == null ? null : role.toJson(),
        "username": username == null ? null : username,
        "usergroup": usergroup == null ? null : usergroup,
        "avatarUrl": avatarUrl == null ? null : avatarUrl,
        "backgroundUrl": backgroundUrl == null ? null : backgroundUrl,
        "posts": posts == null ? null : posts,
        "threads": threads == null ? null : threads,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "banned": banned == null ? null : banned,
        "isBanned": isBanned == null ? null : isBanned,
        "title": title == null ? null : title,
        "pronouns": pronouns == null ? null : pronouns,
        "useBioForTitle": useBioForTitle == null ? null : useBioForTitle,
      };
}

class ThreadUserRole {
  ThreadUserRole({
    this.id,
    this.code,
    this.description,
    this.permissionCodes,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  Code code;
  String description;
  List<dynamic> permissionCodes;
  DateTime createdAt;
  DateTime updatedAt;

  factory ThreadUserRole.fromJson(Map<String, dynamic> json) => ThreadUserRole(
        id: json["id"] == null ? null : json["id"],
        code: json["code"] == null ? null : codeValues.map[json["code"]],
        description: json["description"] == null ? null : json["description"],
        permissionCodes: json["permissionCodes"] == null
            ? null
            : List<dynamic>.from(json["permissionCodes"].map((x) => x)),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "code": code == null ? null : codeValues.reverse[code],
        "description": description == null ? null : description,
        "permissionCodes": permissionCodes == null
            ? null
            : List<dynamic>.from(permissionCodes.map((x) => x)),
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
      };
}

enum Code {
  GUEST,
  BANNED_USER,
  BASIC_USER,
  LIMITED_USER,
  GOLD_USER,
  PAID_GOLD_USER,
  MODERATOR,
  MODERATOR_IN_TRAINING,
  SUPER_MODERATOR,
  ADMIN,
}

final codeValues = EnumValues({
  "guest": Code.GUEST,
  "banned-user": Code.BANNED_USER,
  "basic-user": Code.BASIC_USER,
  "limited-user": Code.LIMITED_USER,
  "moderator": Code.MODERATOR,
  "moderator-in-training": Code.MODERATOR_IN_TRAINING,
  "super-moderator": Code.SUPER_MODERATOR,
  "paid-gold-user": Code.PAID_GOLD_USER,
  "gold-user": Code.GOLD_USER,
});

class ThreadSubforum {
  ThreadSubforum({
    this.id,
    this.name,
    this.description,
    this.iconId,
    this.icon,
    this.lastPost,
    this.totalThreads,
    this.totalPosts,
  });

  int id;
  String name;
  String description;
  int iconId;
  String icon;
  LastPost lastPost;
  int totalThreads;
  int totalPosts;

  factory ThreadSubforum.fromJson(Map<String, dynamic> json) => ThreadSubforum(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        description: json["description"] == null ? null : json["description"],
        iconId: json["iconId"] == null ? null : json["iconId"],
        icon: json["icon"] == null ? null : json["icon"],
        lastPost: json["lastPost"] == null
            ? null
            : LastPost.fromJson(json["lastPost"]),
        totalThreads:
            json["totalThreads"] == null ? null : json["totalThreads"],
        totalPosts: json["totalPosts"] == null ? null : json["totalPosts"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "description": description == null ? null : description,
        "iconId": iconId == null ? null : iconId,
        "icon": icon == null ? null : icon,
        "lastPost": lastPost == null ? null : lastPost.toJson(),
        "totalThreads": totalThreads == null ? null : totalThreads,
        "totalPosts": totalPosts == null ? null : totalPosts,
      };
}

class LastPost {
  LastPost();

  factory LastPost.fromJson(Map<String, dynamic> json) => LastPost();

  Map<String, dynamic> toJson() => {};
}

class ThreadViewers {
  ThreadViewers({
    this.memberCount,
    this.guestCount,
  });

  int memberCount;
  int guestCount;

  factory ThreadViewers.fromJson(Map<String, dynamic> json) => ThreadViewers(
        memberCount: json["memberCount"] == null ? null : json["memberCount"],
        guestCount: json["guestCount"] == null ? null : json["guestCount"],
      );

  Map<String, dynamic> toJson() => {
        "memberCount": memberCount == null ? null : memberCount,
        "guestCount": guestCount == null ? null : guestCount,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}

class ThreadUserProfile {
  ThreadUserProfile({
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
    this.totalPosts,
    this.currentPage,
    this.threadBackgroundUrl,
    this.threadBackgroundType,
    this.posts,
    this.readThreadLastSeen,
    this.subscribed,
    this.subscriptionLastSeen,
    this.subscriptionLastPostNumber,
  });

  int id;
  String title;
  int iconId;
  int subforumId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  bool deleted;
  bool locked;
  bool pinned;
  ThreadPost lastPost;
  dynamic backgroundUrl;
  dynamic backgroundType;
  int user;
  int postCount;
  int recentPostCount;
  int unreadPostCount;
  int readThreadUnreadPosts;
  bool read;
  bool hasRead;
  bool hasSeenNoNewPosts;
  ThreadSubforum subforum;
  List<dynamic> tags;
  ThreadViewers viewers;
  int totalPosts;
  int currentPage;
  dynamic threadBackgroundUrl;
  dynamic threadBackgroundType;
  List<ThreadPost> posts;
  DateTime readThreadLastSeen;
  bool subscribed;
  DateTime subscriptionLastSeen;
  int subscriptionLastPostNumber;

  factory ThreadUserProfile.fromJson(Map<String, dynamic> json) =>
      ThreadUserProfile(
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
            : ThreadPost.fromJson(json["lastPost"]),
        backgroundUrl: json["backgroundUrl"],
        backgroundType: json["backgroundType"],
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
        subforum: json["subforum"] == null
            ? null
            : ThreadSubforum.fromJson(json["subforum"]),
        tags: json["tags"] == null
            ? null
            : List<dynamic>.from(json["tags"].map((x) => x)),
        viewers: json["viewers"] == null
            ? null
            : ThreadViewers.fromJson(json["viewers"]),
        totalPosts: json["totalPosts"] == null ? null : json["totalPosts"],
        currentPage: json["currentPage"] == null ? null : json["currentPage"],
        threadBackgroundUrl: json["threadBackgroundUrl"],
        threadBackgroundType: json["threadBackgroundType"],
        posts: json["posts"] == null
            ? null
            : List<ThreadPost>.from(
                json["posts"].map((x) => ThreadPost.fromJson(x))),
        readThreadLastSeen: json["readThreadLastSeen"] == null
            ? null
            : DateTime.parse(json["readThreadLastSeen"]),
        subscribed: json["subscribed"] == null ? null : json["subscribed"],
        subscriptionLastSeen: json["subscriptionLastSeen"] == null
            ? null
            : DateTime.parse(json["subscriptionLastSeen"]),
        subscriptionLastPostNumber: json["subscriptionLastPostNumber"] == null
            ? null
            : json["subscriptionLastPostNumber"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "iconId": iconId == null ? null : iconId,
        "subforumId": subforumId == null ? null : subforumId,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "deletedAt": deletedAt,
        "deleted": deleted == null ? null : deleted,
        "locked": locked == null ? null : locked,
        "pinned": pinned == null ? null : pinned,
        "lastPost": lastPost == null ? null : lastPost.toJson(),
        "backgroundUrl": backgroundUrl,
        "backgroundType": backgroundType,
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
        "subforum": subforum == null ? null : subforum.toJson(),
        "tags": tags == null ? null : List<dynamic>.from(tags.map((x) => x)),
        "viewers": viewers == null ? null : viewers.toJson(),
        "totalPosts": totalPosts == null ? null : totalPosts,
        "currentPage": currentPage == null ? null : currentPage,
        "threadBackgroundUrl": threadBackgroundUrl,
        "threadBackgroundType": threadBackgroundType,
        "posts": posts == null
            ? null
            : List<dynamic>.from(posts.map((x) => x.toJson())),
        "readThreadLastSeen": readThreadLastSeen == null
            ? null
            : readThreadLastSeen.toIso8601String(),
        "subscribed": subscribed == null ? null : subscribed,
        "subscriptionLastSeen": subscriptionLastSeen == null
            ? null
            : subscriptionLastSeen.toIso8601String(),
        "subscriptionLastPostNumber": subscriptionLastPostNumber == null
            ? null
            : subscriptionLastPostNumber,
      };
}
