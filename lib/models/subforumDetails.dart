import 'package:json_annotation/json_annotation.dart';

part 'subforumDetails.g.dart';

@JsonSerializable()
class SubforumDetails {
  final int id;
  final int currentPage;
  final int iconId;
  final String name;
  final int totalThreads;
  List<SubforumThread> threads;


  SubforumDetails({this.id, this.currentPage, this.iconId, this.name, this.totalThreads, this.threads});

  factory SubforumDetails.fromJson(Map<String, dynamic> json) => _$SubforumDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumDetailsToJson(this);
}

@JsonSerializable()
class SubforumThread {
  final int firstUnreadId;

  @JsonKey(name: 'icon_id')
  final int iconId;
  final int id;
  final int locked;
  final int pinned;
  final int postCount;
  final int readThreadUnreadPosts;
  final String title;
  final int unreadType;

  SubforumThread({this.firstUnreadId, this.iconId, this.id, this.locked, this.pinned, this.postCount, this.readThreadUnreadPosts, this.title, this.unreadType});

  factory SubforumThread.fromJson(Map<String, dynamic> json) => _$SubforumThreadFromJson(json);
  Map<String, dynamic> toJson() => _$SubforumThreadToJson(this);

}