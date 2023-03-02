import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/blockedUsersController.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/dialogs/confirmDialog.dart';
import 'package:knocky/dialogs/reportPostDialog.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:knocky/models/thread.dart';
import 'package:emoji_flag_converter/emoji_flag_converter.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

class Toolbar extends StatelessWidget {
  final ThreadPost? post;
  final bool showThreadPostNumber;
  final Function? onToggleBBCode;
  final Function? onToggleEditPost;
  final ThreadController threadController = Get.put(ThreadController());
  final AuthController authController = Get.put(AuthController());

  Toolbar(
      {required this.post,
      this.showThreadPostNumber = true,
      this.onToggleBBCode,
      this.onToggleEditPost});

  static Widget toolbarBox(Color color, List<Widget> contents) {
    return Container(
        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
        color: color,
        height: 30,
        child: Row(
          children: [...contents],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return toolbarBox(Theme.of(context).primaryColor, contents());
  }

  @protected
  List<Widget> contents() {
    return [timestamp(), country(), postNumber(), Expanded(child: controls())];
  }

  @protected
  Widget timestamp() {
    return Text(timeago.format(post!.createdAt!));
  }

  Widget country() {
    if (post?.countryCode != null) {
      String flag = EmojiConverter.fromAlpha2CountryCode(post!.countryCode!);
      return Container(
        margin: EdgeInsets.only(left: 4),
        child: Text(
          'from ${flag}',
          style: TextStyle(fontFamily: 'Roboto'),
        ),
      );
    }
    return Container();
  }

  Widget postNumber() {
    return Container(
        margin: EdgeInsets.only(left: 8),
        child: Text(
          "#${post!.threadPostNumber.toString()}",
          style: TextStyle(color: Colors.white60),
        ));
  }

  // TODO: post tags
  // ignore: missing_return
  Widget tags() {
    return Container();
  }

  Widget postMenuBottomSheetContent() {
    final BlockedUsersController blockedUsersController =
        Get.put(BlockedUsersController());

    return Container(
      color: Get.theme.bottomAppBarTheme.color,
      padding: EdgeInsets.all(8),
      child: Wrap(
        children: <Widget>[
          blockedUsersController.userIsBlocked(post!.user!.id!)
              ? ListTile(
                  leading: FaIcon(FontAwesomeIcons.userSlash),
                  title: Text('Unblock user'),
                  onTap: () async {
                    Get.back();

                    bool confirmResult = await (Get.dialog(ConfirmDialog(
                      content: "Do you want to unblock the user?",
                    )));

                    if (!confirmResult) return;

                    blockedUsersController.removeBlockedUserId(post!.user!.id!);

                    KnockySnackbar.success('User is now unblocked!');
                  })
              : ListTile(
                  leading: FaIcon(FontAwesomeIcons.userSlash),
                  title: Text('Block user'),
                  onTap: () async {
                    Get.back();

                    bool confirmResult = await (Get.dialog(ConfirmDialog(
                      content: "Do you want to block the user?",
                    )));

                    if (!confirmResult) return;

                    blockedUsersController.addBlockedUserId(post!.user!.id!);
                    KnockySnackbar.success('User is now blocked!');
                  }),
        ],
      ),
    );
  }

  // ignore: missing_return
  Widget controls() {
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          (authController.isAuthenticated.value &&
                  post!.user!.id != authController.userId.value)
              ? IconButton(
                  iconSize: 12,
                  icon: FaIcon(
                    FontAwesomeIcons.solidFlag,
                  ),
                  onPressed: () async {
                    String? reportReason = await Get.dialog(ReportPostDialog());

                    if (reportReason != null) {
                      SnackbarController snackbar = KnockySnackbar.normal(
                          'Report post', 'Sending report...',
                          isDismissible: false, showProgressIndicator: true);
                      try {
                        await KnockoutAPI()
                            .createReport(post!.id!, reportReason);
                        snackbar.close();
                        KnockySnackbar.success(
                          'Post was reported!',
                          title: 'Report post',
                        ).show();
                      } catch (e) {
                        snackbar.close();
                        KnockySnackbar.error(
                          'Failed to report post... Try again...',
                          title: 'Report post',
                        ).show();
                      }
                    }
                  },
                )
              : Container(),
          (authController.isAuthenticated.value &&
                  post!.user!.id == authController.userId.value)
              ? IconButton(
                  iconSize: 12,
                  icon: FaIcon(
                    FontAwesomeIcons.pen,
                  ),
                  onPressed: () => this.onToggleEditPost!.call(),
                )
              : Container(),
          IconButton(
            iconSize: 12,
            icon: FaIcon(
              FontAwesomeIcons.code,
            ),
            onPressed: () => this.onToggleBBCode!.call(),
          ),
          IconButton(
            iconSize: 12,
            icon: FaIcon(
              FontAwesomeIcons.reply,
            ),
            onPressed: () async {
              String contentToInsert =
                  '[quote mentionsUser="${post!.user!.id}" postId="${post!.id}" threadPage="${post!.page}" threadId="${post!.thread}" username="${post!.user!.username}"]${post!.content}[/quote]';

              threadController.replyToAdd.value = contentToInsert;
              threadController.itemScrollController.jumpTo(index: 999);
            },
          ),
          IconButton(
            iconSize: 12,
            icon: FaIcon(
              FontAwesomeIcons.ellipsisVertical,
            ),
            onPressed: () async {
              print('Show menu');
              Get.bottomSheet(
                postMenuBottomSheetContent(),
                enterBottomSheetDuration: Duration(milliseconds: 150),
                exitBottomSheetDuration: Duration(milliseconds: 150),
              );
            },
          )
        ],
      ),
    );
  }
}
