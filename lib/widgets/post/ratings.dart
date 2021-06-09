import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
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
  final AuthController authController = Get.put(AuthController());
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
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Row(children: [
        Expanded(child: ratingsList()),
        Obx(
          () => authController.isAuthenticated.value
              ? TextButton(
                  onPressed: () => toggleShowChooser(true),
                  child: Text(
                    'Rate',
                    style: TextStyle(color: Colors.grey),
                  ))
              : Container(),
        )
      ]),
    );
  }

  toggleShowChooser(bool toggled) {
    setState(() {
      showChooser = toggled;
    });
  }

  onRatingDone() async {
    var ratings = await ratingsController.getRatingsOf(widget.postId);
    setState(() {
      this.ratings = ratings;
    });
  }

  Widget ratingsList() {
    return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ratings.length,
        separatorBuilder: (context, index) => Container(width: 4),
        itemBuilder: (context, index) {
          var rating = ratings.elementAt(index);
          return ratingColumn(rating);
        });
  }

  Widget ratingColumn(ThreadPostRatings rating) {
    var ratingItem = ratingIconMap[rating.rating];
    bool userChose = rating.users.contains(authController.username?.value);
    return Stack(children: [
      if (userChose)
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(RATING_ICON_SIZE),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withAlpha(50),
                    blurRadius: 6,
                  )
                ]),
            height: RATING_ICON_SIZE,
            width: RATING_ICON_SIZE),
      Column(children: [
        Container(
          width: RATING_ICON_SIZE,
          height: RATING_ICON_SIZE,
          margin: EdgeInsets.only(bottom: 4),
          child: RatingsChooser.ratingButton(ratingItem, widget.postId,
              () => toggleShowChooser(false), onRatingDone),
        ),
        Text(rating.count.toString(),
            style: TextStyle(fontSize: 12, color: Colors.grey))
      ]),
    ]);
  }
}
