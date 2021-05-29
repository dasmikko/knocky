import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/models/usergroup.dart';

class RatingsChooser extends StatelessWidget {
  final int postId;
  final Function onRated;
  RatingsChooser({@required this.postId, this.onRated});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 16), height: 48, child: ratingsList());
  }

  Widget ratingsList() {
    // TODO: add actual user group and sub forum
    var ratings = ratingsMapForContext(Usergroup.regular, 1).entries;
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ratings.length,
        itemBuilder: (context, index) {
          var rating = ratings.elementAt(index);
          return ratingButton(rating);
        });
  }

  Widget ratingButton(MapEntry<String, RatingItem> ratingEntry) {
    var ratingUrl = ratingIconMap[ratingEntry.key].url;
    return IconButton(
        color: Colors.green,
        padding: EdgeInsets.all(4),
        visualDensity: VisualDensity.compact,
        onPressed: () => onRatingPressed(postId, ratingEntry.value.id, onRated),
        icon: CachedNetworkImage(imageUrl: ratingUrl));
  }

  static Future<void> onRatingPressed(
      int postId, String ratingId, Function onRated) async {
    await KnockoutAPI().ratePost(postId, ratingId);
    onRated();
  }
}
