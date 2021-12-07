import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/subscriptionController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widgets/jumpToPageDialog.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';

class SubscriptionListItem extends ThreadListItem {
  final ThreadAlert threadAlert;
  SubscriptionController subscriptionController =
      Get.put(SubscriptionController());

  SubscriptionListItem({@required this.threadAlert})
      : super(threadDetails: threadAlert);

  @override
  List getTagWidgets(BuildContext context) {
    return [
      if (threadAlert.unreadPostCount > 0)
        unreadPostsButton(context, threadAlert.unreadPostCount)
    ];
  }

  @override
  List<WidgetSpan> getDetailIcons(BuildContext context) {
    return [...lockedIcon()];
  }

  void showJumpDialog() async {
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
  void onLongPressItem(BuildContext context) {
    Get.bottomSheet(Container(
      color: Get.theme.bottomAppBarColor,
      child: Wrap(
        children: <Widget>[
          ListTile(
              leading: FaIcon(FontAwesomeIcons.bellSlash),
              title: Text('Unsubscribe'),
              onTap: () async {
                Get.back();
                SnackbarController snackbarController = Get.snackbar(
                  "Unsubscribing...", // title
                  "Unsubscribing thread...", // message
                  borderRadius: 0,
                  isDismissible: false,
                  showProgressIndicator: true,
                );
                await KnockoutAPI().deleteThreadAlert(threadDetails.id);
                snackbarController.close();
                subscriptionController.fetch();

                Get.snackbar(
                  "Success", // title
                  "Unsubscribed thread", // message
                  borderRadius: 0,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.redo),
            title: Text('Go to page'),
            onTap: () {
              Get.back();
              showJumpDialog();
            },
          ),
        ],
      ),
    ));
  }
}
