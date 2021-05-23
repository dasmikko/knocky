import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/models/thread.dart';

class Ratings extends StatelessWidget {
  final List<ThreadPostRatings> ratings;

  Ratings({this.ratings});

  @override
  Widget build(BuildContext context) {
    return Container(height: 48, child: ratingsList());
  }

  Widget ratingsList() {
    return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ratings.length,
        separatorBuilder: (context, index) => Container(width: 8),
        itemBuilder: (context, index) {
          var rating = ratings.elementAt(index);
          return ratingColumn(rating);
        });
  }

  Widget ratingColumn(ThreadPostRatings rating) {
    var ratingUrl = ratingIconMap[rating.rating].url;
    return Column(children: [
      Container(
        width: 24,
        height: 24,
        margin: EdgeInsets.only(bottom: 4),
        child: CachedNetworkImage(imageUrl: ratingUrl),
      ),
      Text(rating.count.toString())
    ]);
  }
}
