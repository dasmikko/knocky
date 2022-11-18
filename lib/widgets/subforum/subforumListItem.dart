import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/subforumv2.dart' as Subforumv2;
import 'package:knocky/widgets/jumpToPageDialog.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';

class SubforumListItem extends ThreadListItem {
  final Subforumv2.Thread threadDetails;
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

    if (page != null)
      Get.to(() => ThreadScreen(id: threadDetails.id, page: page));
  }

  @override
  List getTagWidgets(BuildContext context) {
    return [
      ...threadTags(context),
      if (threadDetails.readThreadUnreadPosts > 0 && threadDetails.hasRead)
        unreadPostsButton(context, threadDetails.readThreadUnreadPosts),
    ];
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
}
