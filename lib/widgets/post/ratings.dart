import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/ratingsController.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/post/ratingsChooser.dart';

class Ratings extends StatefulWidget {
  final List<ThreadPostRatings> ratings;
  final int postId;
  final Function onRated;

  Ratings({@required this.postId, this.ratings, this.onRated});

  @override
  _RatingsState createState() => _RatingsState();
}

class _RatingsState extends State<Ratings> {
  final RatingsController ratingsController = Get.put(RatingsController());
  List<ThreadPostRatings> ratings;
  bool showChooser = false;

  @override
  void initState() {
    super.initState();
    ratings = widget.ratings;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(4, 16, 0, 0),
        height: 48,
        width: double.infinity,
        child: showChooser ? showRatingsChooser() : showExistingRatings());
  }

  onRatingDone() async {
    var ratings = await ratingsController.getRatingsOf(widget.postId);
    setState(() {
      this.ratings = ratings;
    });
  }

  Widget showRatingsChooser() {
    return Row(children: [
      Expanded(
          child: RatingsChooser(
              postId: widget.postId,
              onRatingDone: onRatingDone,
              onRatingClicked: () => toggleShowChooser(false))),
      TextButton(
          onPressed: () => toggleShowChooser(false),
          child: Text(
            'Close',
            style: TextStyle(color: Colors.grey),
          ))
    ]);
  }

  Widget showExistingRatings() {
    return Row(children: [
      Expanded(child: ratingsList()),
      TextButton(
          onPressed: () => toggleShowChooser(true),
          child: Text(
            'Rate',
            style: TextStyle(color: Colors.grey),
          ))
    ]);
  }

  toggleShowChooser(bool toggled) {
    setState(() {
      showChooser = toggled;
    });
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
        width: RATING_ICON_SIZE,
        height: RATING_ICON_SIZE,
        margin: EdgeInsets.only(bottom: 8),
        child: CachedNetworkImage(imageUrl: ratingUrl),
      ),
      Text(rating.count.toString())
    ]);
  }
}
