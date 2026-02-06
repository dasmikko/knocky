// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rating _$RatingFromJson(Map<String, dynamic> json) => Rating(
  id: (json['id'] as num).toInt(),
  rating: json['rating'] as String,
  ratingId: (json['ratingId'] as num).toInt(),
  users: json['users'] as List<dynamic>,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$RatingToJson(Rating instance) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'ratingId': instance.ratingId,
  'users': instance.users,
  'count': instance.count,
};
