import 'package:json_annotation/json_annotation.dart';

part 'thread_ad.g.dart';

@JsonSerializable()
class ThreadAd {
  final int id;
  final String description;
  final String query;
  final String imageUrl;

  ThreadAd({
    required this.id,
    required this.description,
    required this.query,
    required this.imageUrl,
  });

  factory ThreadAd.fromJson(Map<String, dynamic> json) => _$ThreadAdFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadAdToJson(this);
}
