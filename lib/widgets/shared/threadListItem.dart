import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/helpers/containers.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/widgets/InkWellOnWidget.dart';
import 'dart:ui' as ui;
import 'package:timeago/timeago.dart' as timeago;

import 'package:knocky/screens/thread.dart';

class ThreadListItem extends StatelessWidget {
  final dynamic threadDetails;
  ThreadListItem({this.threadDetails});

  @protected
  void onTapItem(BuildContext context) {
    print(threadDetails.id);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ThreadScreen(id: threadDetails.id)));
  }

  @protected
  void onLongPressItem(BuildContext context) {}

  @protected
  List getTagWidgets(BuildContext context) {
    return [];
  }

  @protected
  Widget getIcon(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CachedNetworkImage(
            width: 32,
            imageUrl: getIconOrDefault(threadDetails.iconId).url,
          )
        ]));
  }

  @protected
  BoxDecoration getBackground(BuildContext context) {
    return Containers.getBackgroundDecoration(
        context, threadDetails.backgroundUrl);
  }

  @protected
  lockedIcon() {
    return [
      if (threadDetails.locked)
        WidgetSpan(
          child: Container(
            margin: EdgeInsets.only(right: 4),
            child: Icon(
              FontAwesomeIcons.lock,
              size: 14,
              color: HexColor('b38d4f'),
            ),
          ),
        )
    ];
  }

  @protected
  pinnedIcon() {
    return [
      if (threadDetails.pinned)
        WidgetSpan(
          alignment: ui.PlaceholderAlignment.bottom,
          child: Container(
            margin: EdgeInsets.only(right: 4),
            child: Icon(
              FontAwesomeIcons.solidStickyNote,
              size: 14,
              color: HexColor('b4e42d'),
            ),
          ),
        )
    ];
  }

  @protected
  void onTapUnreadPostsButton(
      BuildContext context, int unreadCount, int totalCount) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ThreadScreen(
                id: threadDetails.id,
                page: PostsPerPage.unreadPostsPage(unreadCount, totalCount),
                linkedPostId: threadDetails.firstUnreadId)));
  }

  @protected
  Widget unreadPostsButton(BuildContext context, int unreadCount) {
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
                  color: AppColors(context).unreadPostsColor(),
                  child: Text(
                    '$unreadCount new post${unreadCount > 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                onTap: () {
                  onTapUnreadPostsButton(
                      context, unreadCount, threadDetails.postCount);
                },
              )),
        ),
      ],
    );
  }

  @protected
  List<WidgetSpan> getDetailIcons(BuildContext context) {
    return [...lockedIcon(), ...pinnedIcon()];
  }

  @protected
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
                onTap: () => onTapItem(context),
                onLongPress: () => onLongPressItem(context),
                child: getIcon(context)),
            Flexible(
              child: Container(
                decoration: getBackground(context),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTapItem(context),
                    onLongPress: () => onLongPressItem(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 4),
                            child: RichText(
                              text: TextSpan(children: <InlineSpan>[
                                ...getDetailIcons(context),
                                TextSpan(
                                  text: threadDetails.title,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ]),
                            ),
                          ),
                          ...getTagWidgets(context),
                          getSubtitle(context)
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
