import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/widgets/InkWellOnWidget.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/widgets/jumpToPageDialog.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';
import 'package:timeago/timeago.dart' as timeago;

class SubforumListItem extends ThreadListItem {
  final SubforumThread threadDetails;
  SubforumListItem({this.threadDetails});

  @override
  void onLongPressItem(BuildContext context) async {
    int page = await Get.dialog(
      JumpToPageDialog(
        minValue: 1,
        maxValue: PostsPerPage.totalPagesFromPosts(threadDetails.postCount),
        value: 1,
      ),
    );

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ThreadScreen(id: threadDetails.id, page: page)));
  }

  @override
  List getTagWidgets(BuildContext context) {
    return [
      ...threadTags(context),
      if (threadDetails.readThreadUnreadPosts > 0 &&
          threadDetails.hasRead &&
          !threadDetails.subscribed)
        newPostsButton(context),
      if (threadDetails.unreadPostCount > 0 &&
          !threadDetails.hasRead &&
          threadDetails.subscribed)
        newPostsSubscriptionButton(context)
    ];
  }

  @override
  Widget getSubtitle(BuildContext context) {
    Color userColor =
        AppColors(context).userGroupToColor(threadDetails.user.usergroup);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: 'by '),
          TextSpan(
            text: threadDetails.user.username,
            style: TextStyle(color: userColor, fontWeight: FontWeight.bold),
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
            text: timeago.format(threadDetails.lastPost.createdAt),
          )
        ],
      ),
    );
  }

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

  List<Widget> threadTags(BuildContext context) {
    List<Widget> widgets = [];

    if (threadDetails.tags != null) {
      threadDetails.tags.forEach((tag) {
        widgets.add(Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  padding: EdgeInsets.all(4),
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
          margin: EdgeInsets.only(bottom: 4),
          child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWellOverWidget(
                child: Container(
                  padding: EdgeInsets.all(4),
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
          margin: EdgeInsets.only(bottom: 4),
          child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWellOverWidget(
                child: Container(
                  padding: EdgeInsets.all(4),
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
}
