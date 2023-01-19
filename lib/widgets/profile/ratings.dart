import 'package:flutter/cupertino.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/models/userProfileRatings.dart';
import 'package:knocky/widgets/post/ratingsChooser.dart';

class ProfileRatings extends StatelessWidget {
  final List<UserProfileRating> ratings;

  ProfileRatings({@required this.ratings});

  @override
  Widget build(BuildContext context) {
    ratings.sort((a, b) => b.count.compareTo(a.count));
    return Container(
        height: double.infinity,
        margin: EdgeInsets.only(bottom: 8),
        alignment: Alignment.bottomCenter,
        child: Container(
            height: 24,
            child: ListView(
                scrollDirection: Axis.horizontal,
                children: [for (var i in ratings) rating(i)])));
  }

  Widget rating(UserProfileRating rating) {
    var ratingItem = ratingIconMap[rating.name];
    if (ratingItem == null) {
      print(rating.name);
      return Container();
    }
    return Row(children: [
      RatingsChooser.ratingIcon(ratingItem),
      Container(
          child: Text(rating.count.toString(), style: TextStyle(fontSize: 12)),
          margin: EdgeInsets.fromLTRB(4, 0, 8, 0))
    ]);
  }
}
