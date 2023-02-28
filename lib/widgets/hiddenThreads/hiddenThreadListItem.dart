import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/hiddenThreadsController.dart';
import 'package:knocky/controllers/subscriptionController.dart';
import 'package:knocky/dialogs/confirmDialog.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/models/v2/thread.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widgets/jumpToPageDialog.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';

class HiddenThreadListItem extends ThreadListItem {
  final ForumThread? threadDetails;
  final HiddenThreadsController hiddenThreadsController =
      Get.put(HiddenThreadsController());

  HiddenThreadListItem({required this.threadDetails})
      : super(threadDetails: threadDetails);

  @override
  void onTapItem(BuildContext context) async {
    // TODO: implement onTapItem
    bool confirmResult = await (Get.dialog(ConfirmDialog(
      content: "Do you want unhide the thread?",
    )));

    if (!confirmResult) return;

    SnackbarController snackbarController = KnockySnackbar.normal(
      "Unhiding thread...",
      "Please wait...",
      isDismissible: false,
      showProgressIndicator: true,
    );

    await KnockoutAPI().unhideThread(threadDetails!.id!);
    snackbarController.close();

    KnockySnackbar.success('Thread is now unhidden!');
    hiddenThreadsController.fetch();
  }
}
