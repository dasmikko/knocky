import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/helpers/format.dart';
import 'package:knocky/models/thread.dart';

class Toolbar extends StatelessWidget {
  final ThreadPost post;
  final bool showThreadPostNumber;
  final Function onToggleBBCode;
  final Function onToggleEditPost;
  final ThreadController threadController = Get.put(ThreadController());
  final AuthController authController = Get.put(AuthController());

  Toolbar(
      {@required this.post,
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
    return [timestamp(), postNumber(), Expanded(child: controls())];
  }

  @protected
  Widget timestamp() {
    return Text(Format.humanReadableTimeSince(post.createdAt));
  }

  Widget postNumber() {
    return Container(
        margin: EdgeInsets.only(left: 8),
        child: Text(
          "#${post.threadPostNumber.toString()}",
          style: TextStyle(color: Colors.white60),
        ));
  }

  // TODO: post tags
  // ignore: missing_return
  Widget tags() {}

  // ignore: missing_return
  Widget controls() {
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          (authController.isAuthenticated.value &&
                  post.user.id == authController.userId.value)
              ? IconButton(
                  iconSize: 12,
                  icon: FaIcon(
                    FontAwesomeIcons.pen,
                  ),
                  onPressed: () => this.onToggleEditPost.call(),
                )
              : Container(),
          IconButton(
            iconSize: 12,
            icon: FaIcon(
              FontAwesomeIcons.code,
            ),
            onPressed: () => this.onToggleBBCode.call(),
          ),
          IconButton(
            iconSize: 12,
            icon: FaIcon(
              FontAwesomeIcons.reply,
            ),
            onPressed: () async {
              // TODO: Test if threadid is recieved
              String contentToInsert =
                  '[quote mentionsUser="${post.user.id}" postId="${post.id}" threadPage="${post.page}" threadId="${post.threadId}" username="${post.user.username}"]${post.content}[/quote]';

              threadController.replyToAdd.value = contentToInsert;
              threadController.itemScrollController.jumpTo(index: 999);
            },
          )
        ],
      ),
    );
  }
}
