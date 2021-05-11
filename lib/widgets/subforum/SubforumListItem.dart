import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/widgets/InkWellOnWidget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/widgets/jumpToPageDialog.dart';
import 'package:knocky/screens/thread.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:ui' as ui;

class SubforumListItem extends StatelessWidget {
  final SubforumThread threadDetails;
  SubforumListItem({this.threadDetails});

  void onTapNewPostsButton(BuildContext context, SubforumThread item) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ThreadScreen(
                id: threadDetails.id,
                page: PostsPerPage.unreadPostsPage(
                    item.unreadPostCount, item.postCount),
                linkedPostId: item.firstUnreadId)));
  }

  void onTapItem(BuildContext context, SubforumThread item) {
    print('Clicked item ' + threadDetails.id.toString());

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ThreadScreen(id: threadDetails.id)));
  }

  void showJumpDialog(BuildContext context) async {
    int totalPages = (threadDetails.postCount / 20).ceil();

    int page = await Get.dialog(
      JumpToPageDialog(
        minValue: 1,
        maxValue: totalPages,
        value: 1,
      ),
    );

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ThreadScreen(id: threadDetails.id, page: page)));
  }

  List<Widget> threadTags(BuildContext context) {
    List<Widget> widgets = [];

    if (threadDetails.tags != null) {
      threadDetails.tags.forEach((tag) {
        widgets.add(Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  padding: EdgeInsets.all(5),
                  color: Colors.red,
                  child: Text(
                    tag.values.first,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ));
      });
    }

    return widgets;
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
    String _iconUrl = getIconOrDefault(threadDetails.iconId).url;

    bool isNSFWThread = false;

    if (threadDetails.tags != null) {
      threadDetails.tags.forEach((item) {
        print(item['1']);

        if (item['1'] == 'NSFW') isNSFWThread = true;
      });
    }

    Color userColor =
        AppColors(context).userGroupToColor(threadDetails.user.usergroup);

    return Card(
      color: Color.fromRGBO(45, 45, 48, 1),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () => onTapItem(context, threadDetails),
              onLongPress: () => showJumpDialog(context),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CachedNetworkImage(
                      width: 35,
                      imageUrl: _iconUrl,
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.7), BlendMode.darken),
                      image: CachedNetworkImageProvider(
                          threadDetails.backgroundUrl),
                    )),
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
                                if (threadDetails.locked)
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
                                if (threadDetails.pinned)
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
                                  style: TextStyle(fontSize: 15),
                                ),
                              ]),
                            ),
                          ),
                          ...threadTags(context),
                          if (threadDetails.readThreadUnreadPosts > 0 &&
                              threadDetails.hasRead &&
                              !threadDetails.subscribed)
                            newPostsButton(context),
                          if (threadDetails.unreadPostCount > 0 &&
                              !threadDetails.hasRead &&
                              threadDetails.subscribed)
                            newPostsSubscriptionButton(context),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: 'by '),
                                TextSpan(
                                  text: threadDetails.user.username,
                                  style: TextStyle(
                                      color: userColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                WidgetSpan(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 5, right: 5),
                                    child: Icon(
                                      Icons.reply_all_rounded,
                                      size: 15,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: timeago
                                      .format(threadDetails.lastPost.createdAt),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
