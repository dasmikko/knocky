import 'package:json_annotation/json_annotation.dart';

part 'rating.g.dart';

@JsonSerializable()
class Rating {
  final int id;
  final String rating;
  final int ratingId;
  final List<dynamic> users;
  final int count;

  Rating({
    required this.id,
    required this.rating,
    required this.ratingId,
    required this.users,
    required this.count,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);
  Map<String, dynamic> toJson() => _$RatingToJson(this);
}
