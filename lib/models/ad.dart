import 'package:json_annotation/json_annotation.dart';

part 'ad.g.dart';

@JsonSerializable()
class KnockoutAd {
  String description;
  String imageUrl;
  String query;

  KnockoutAd({this.description, this.imageUrl, this.query});

  factory KnockoutAd.fromJson(Map<String, dynamic> json) =>
      _$KnockoutAdFromJson(json);
  Map<String, dynamic> toJson() => _$KnockoutAdToJson(this);
}
