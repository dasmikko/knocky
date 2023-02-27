import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/dialogs/confirmDialog.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/models/subforumv2.dart' as Subforumv2;
import 'package:knocky/widgets/jumpToPageDialog.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';

class SubforumListItem extends ThreadListItem {
  final Subforumv2.Thread? threadDetails;
  final Function? onShouldRefresh;
  SubforumListItem({this.threadDetails, this.onShouldRefresh});

  @override
  void onLongPressItem(BuildContext context) async {
    Get.bottomSheet(
      longPressBottomSheetContent(),
      enterBottomSheetDuration: Duration(milliseconds: 150),
      exitBottomSheetDuration: Duration(milliseconds: 150),
    );
  }

  void showJumpDialog() async {
    int? page = await Get.dialog(
      JumpToPageDialog(
        minValue: 1,
        maxValue: PostsPerPage.totalPagesFromPosts(threadDetails!.postCount!),
        value: 1,
      ),
    );

    if (page != null) {
      Get.to(() => ThreadScreen(id: threadDetails?.id, page: page));
    }
  }

  Widget longPressBottomSheetContent() {
    return Container(
      color: Get.theme.bottomAppBarTheme.color,
      child: Wrap(
        children: <Widget>[
          ListTile(
              enabled: threadDetails?.read == true,
              leading: FaIcon(FontAwesomeIcons.glasses),
              title: Text('Mark thread unread'),
              onTap: () async {
                Get.back();

                bool confirmResult = await (Get.dialog(ConfirmDialog(
                  content: "Do you want to mark thread unread?",
                )));

                if (!confirmResult) return;

                SnackbarController snackbarController = KnockySnackbar.normal(
                  "Marking thread unread...",
                  "Please wait...",
                  isDismissible: false,
                  showProgressIndicator: true,
                );

                await KnockoutAPI().readThreadsMarkUnread(threadDetails!.id!);
                snackbarController.close();

                KnockySnackbar.success("Thread was marked unread");

                if (onShouldRefresh != null) {
                  onShouldRefresh!();
                }
              }),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.arrowRotateRight),
            title: Text('Go to page'),
            onTap: () {
              Get.back();
              showJumpDialog();
            },
          ),
        ],
      ),
    );
  }

  @override
  List getTagWidgets(BuildContext context) {
    return [
      ...threadTags(context),
      if (threadDetails!.readThreadUnreadPosts! > 0 && threadDetails!.hasRead!)
        unreadPostsButton(context, threadDetails!.readThreadUnreadPosts!),
    ];
  }

  List<Widget> threadTags(BuildContext context) {
    List<Widget> widgets = [];

    threadDetails!.tags!.forEach((tag) {
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

    return widgets;
  }
}
