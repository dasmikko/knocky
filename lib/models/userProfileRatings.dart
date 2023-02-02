// To parse this JSON data, do
//
//     final userProfileRatings = userProfileRatingsFromJson(jsonString);

import 'dart:convert';

class UserProfileRating {
  UserProfileRating({
    this.name,
    this.count,
  });

  String? name;
  int? count;

  factory UserProfileRating.fromRawJson(String str) =>
      UserProfileRating.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserProfileRating.fromJson(Map<String, dynamic> json) =>
      UserProfileRating(
        name: json["name"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "count": count,
      };
}
