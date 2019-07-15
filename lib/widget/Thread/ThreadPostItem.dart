import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/widget/Thread/PostHeader.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/helpers/api.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/widget/Thread/RatePostContent.dart';

class ThreadPostItem extends StatelessWidget {
  final ThreadPost postDetails;
  final GlobalKey scaffoldKey;
  Function onPostRated = () {};

  ThreadPostItem({this.postDetails, this.scaffoldKey, this.onPostRated});

  Widget buildRatings(List<ThreadPostRatings> ratings) {
    List<Widget> items = List();

    if (ratings != null) {
      ratings.sort((a, b) => b.count.compareTo(a.count));
      ratings.forEach((rating) {
        RatingistItem icon =
            ratingsIconList.where((icon) => icon.id == rating.rating).first;

        items.add(
          Container(
            margin: EdgeInsets.only(right: 5.0),
            child: Column(children: <Widget>[
              CachedNetworkImage(
                imageUrl: icon.url,
              ),
              Text(rating.count.toString())
            ]),
          ),
        );
      });
    }

    return Row(children: items);
  }

  void onPressSpoiler(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onPressRatePost(BuildContext context) {
    showModalBottomSheet(
        context: context,
        elevation: 10,
        builder: (BuildContext bContext) {
          return RatePostContent(buildContext: context, postId: postDetails.id, onPostRated: onPostRated,);
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .isLoggedIn;
    final int ownUserId =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .userId;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: PostHeader(
                      username: postDetails.user.username,
                      avatarUrl: postDetails.user.avatarUrl,
                      backgroundUrl: postDetails.user.backgroundUrl,
                      threadPost: postDetails,
                      context: context,
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: SlateDocumentParser(
                slateObject: postDetails.content,
                onPressSpoiler: (text) {
                  onPressSpoiler(context, text);
                },
                context: context,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 10),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: buildRatings(postDetails.ratings),
                  ),
                  if (isLoggedIn && postDetails.user.id != ownUserId)
                    FlatButton(
                      child: Text('Rate'),
                      onPressed: () => onPressRatePost(context),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
