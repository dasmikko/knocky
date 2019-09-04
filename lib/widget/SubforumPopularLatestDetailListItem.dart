import 'package:flutter/material.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/screens/thread.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/widget/InkWellOnWidget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:ui' as ui;
import 'package:numberpicker/numberpicker.dart';

class SubforumPopularLatestDetailListItem extends StatelessWidget {
  final SubforumThreadLatestPopular threadDetails;
  final BuildContext rootContext;
  SubforumPopularLatestDetailListItem({this.threadDetails, this.rootContext});

  void onTapNewPostsButton(BuildContext context, SubforumThreadLatestPopular item) {
    double pagenumber =
        (item.postCount - (item.readThreadUnreadPosts - 1)) / 20;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadScreen(
          title: item.title,
          postCount: item.postCount,
          threadId: item.id,
          page: pagenumber.ceil(),
        ),
      ),
    );
  }

  void onTapItem(BuildContext context, SubforumThreadLatestPopular item) {
    print('Clicked item ' + threadDetails.id.toString());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadScreen(
          title: threadDetails.title,
          postCount: threadDetails.postCount,
          threadId: threadDetails.id,
        ),
      ),
    );
  }

  void showJumpDialog(BuildContext context) {
    int totalPages = (threadDetails.postCount / 20).ceil();
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: 1,
            maxValue: totalPages,
            title: new Text("Jump to page"),
            initialIntegerValue: 1,
          );
        }).then((int value) {
      if (value != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThreadScreen(
              title: threadDetails.title,
              postCount: threadDetails.postCount,
              threadId: threadDetails.id,
              page: value,
            ),
          ),
        );
      }
    });
  }

  Widget newPostsButton(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWellOverWidget(
                child: Container(
                  padding: EdgeInsets.all(5),
                  color: Color.fromRGBO(255, 201, 63, 1),
                  child: Text(
                    '${threadDetails.readThreadUnreadPosts} new posts',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                onTap: () {
                  onTapNewPostsButton(context, threadDetails);
                },
              )),
        ),
      ],
    );
  }

  Widget newPostsSubscriptionButton(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWellOverWidget(
                child: Container(
                  padding: EdgeInsets.all(5),
                  color: Color.fromRGBO(255, 142, 204, 1),
                  child: Text(
                    '${threadDetails.unreadPostCount} new posts',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                onTap: () {
                  onTapNewPostsButton(context, threadDetails);
                },
              )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String _iconUrl = threadDetails.iconId != null ? iconList
        .firstWhere((IconListItem item) => item.id == threadDetails.iconId)
        .url : '';



    return Card(
      color: Color.fromRGBO(45, 45, 48, 1),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CachedNetworkImage(
                    width: 25,
                    imageUrl: _iconUrl,
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                color: Color.fromRGBO(34, 34, 38, 1),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTapItem(context, threadDetails),
                    onLongPress: () => showJumpDialog(context),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: RichText(
                              text: TextSpan(children: <InlineSpan>[
                                if (threadDetails.locked == 1)
                                  WidgetSpan(
                                    child: Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        FontAwesomeIcons.lock,
                                        size: 14,
                                        color: HexColor('b38d4f'),
                                      ),
                                    ),
                                  ),
                                if (threadDetails.pinned == 1)
                                  WidgetSpan(
                                    alignment: ui.PlaceholderAlignment.bottom,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        FontAwesomeIcons.solidStickyNote,
                                        size: 14,
                                        color: HexColor('b4e42d'),
                                      ),
                                    ),
                                  ),
                                TextSpan(
                                  text: threadDetails.title,
                                ),
                              ]),
                            ),
                          ),
                          if (threadDetails.readThreadUnreadPosts > 0 && threadDetails.unreadType == 1)
                            newPostsButton(context),
                          if (threadDetails.unreadPostCount > 0 && threadDetails.unreadType == 0)
                            newPostsSubscriptionButton(context),
                          Text(
                            threadDetails.user.username,
                            style: TextStyle(color: Colors.blue),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (threadDetails.lastPost.id != null)
            Container(
              width: 110,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 4),
                    child: Text(
                      threadDetails.postCount.toString() + ' replies',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 4),
                    child: Text(
                      timeago.format(threadDetails.createdAt),
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 4),
                    child: Text(
                      threadDetails.lastPost.user.username,
                      style: TextStyle(color: Colors.blue, fontSize: 11),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 4),
                    child: Text(
                      timeago.format(threadDetails.lastPost.createdAt),
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    /*return Card(
      margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
      child: InkWell(
        onTap: () {
          print('Clicked item ' + threadDetails.id.toString());

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadScreen(
                    title: threadDetails.title,
                    postCount: threadDetails.postCount,
                    threadId: threadDetails.id,
                  ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10.0),
                child: CachedNetworkImage(
                  width: 40,
                  imageUrl: _iconUrl,
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (threadDetails.locked == 1)
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: Icon(
                                FontAwesomeIcons.lock,
                                size: 14,
                                color: HexColor('b38d4f'),
                              ),
                            ),
                          if (threadDetails.pinned == 1)
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: Icon(
                                FontAwesomeIcons.solidStickyNote,
                                size: 14,
                                color: HexColor('b4e42d'),
                              ),
                            ),
                          Flexible(
                            child: Container(
                              margin: EdgeInsets.only(
                                  bottom:
                                      threadDetails.readThreadUnreadPosts > 0
                                          ? 10
                                          : 0),
                              child: Text(threadDetails.title),
                            ),
                          ),
                        ],
                      ),
                      if (threadDetails.readThreadUnreadPosts > 0)
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWellOverWidget(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  color: Color.fromRGBO(255, 201, 63, 1),
                                  child: Text(
                                    '${threadDetails.readThreadUnreadPosts} new posts',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                onTap: () {
                                  onTapNewPostsButton(context, threadDetails);
                                },
                              )),
                        ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );*/
  }
}
