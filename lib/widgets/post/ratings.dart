import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/ratingsController.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/post/ViewUsersOfRatingsContent.dart';
import 'package:knocky/widgets/post/rateButton.dart';
import 'package:knocky/widgets/post/ratingsChooser.dart';

class Ratings extends StatefulWidget {
  final List<ThreadPostRating> ratings;
  final int postId;
  final Function onRated;
  final bool canRate;

  Ratings(
      {@required this.postId, this.ratings, this.onRated, this.canRate = true});

  @override
  _RatingsState createState() => _RatingsState();
}

class _RatingsState extends State<Ratings> {
  final RatingsController ratingsController = Get.put(RatingsController());
  final AuthController authController = Get.put(AuthController());
  SnackbarController snackbarController;
  bool showChooser = false;

  Duration animatonDuration = Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(4, 16, 0, 0),
      height: 48,
      width: double.infinity,
      child: showExistingRatings(),
    );
  }

  Widget showRatingsChooser(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: RatingsChooser(
              postId: widget.postId,
              onRatingDone: onRatingDone,
              onRatingClicked: () {
                Get.back();
                snackbarController = KnockySnackbar.normal(
                    'Rating', 'Rating post...',
                    showProgressIndicator: true, isDismissible: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget showExistingRatings() {
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Row(
        children: [
          widget.ratings.length > 0
              ? IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        elevation: 10,
                        builder: (BuildContext bContext) {
                          return ViewUsersOfRatingsContent(
                            buildContext: context,
                            ratings: widget.ratings,
                          );
                        });
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.eye,
                    size: 15.0,
                    color: Colors.grey[600],
                  ),
                )
              : Container(),
          Expanded(
            child: ratingsList(),
          ),
          Obx(
            () => authController.isAuthenticated.value && widget.canRate
                ? RateButton(
                    popOverContent: showRatingsChooser(context),
                  )
                : Container(),
          )
        ],
      ),
    );
  }

  onRatingDone() async {
    widget.onRated.call();
    snackbarController.close();
    KnockySnackbar.success('Post was rated');
  }

  Widget ratingsList() {
    return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.ratings.length,
        separatorBuilder: (context, index) => Container(width: 4),
        itemBuilder: (context, index) {
          var rating = widget.ratings.elementAt(index);
          return ratingColumn(rating);
        });
  }

  Widget ratingColumn(ThreadPostRating rating) {
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
              () => {}, onRatingDone, widget.canRate),
        ),
        Text(
          rating.count.toString(),
          style: TextStyle(fontSize: 12, color: Colors.grey),
        )
      ]),
    ]);
  }
}
