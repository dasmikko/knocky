import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserProfileRatings {
  final List<UserProfileRating> ratings;

  UserProfileRatings({this.ratings});

  factory UserProfileRatings.fromJson(String json) => fromJson(json);
}

UserProfileRatings fromJson(String json) {
  List<dynamic> ratingListMap = jsonDecode(json);
  var ratings = ratingListMap
      .map((mapEntries) => new UserProfileRating(
          name: mapEntries['name'], count: mapEntries['count']))
      .toList();
  return new UserProfileRatings(ratings: ratings);
}

@JsonSerializable()
class UserProfileRating {
  final int count;
  final String name;
  UserProfileRating({this.count, this.name});
}
