import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/helpers/containers.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/colors.dart';
import 'dart:ui' as ui;

import 'package:knocky/screens/thread.dart';

class ThreadListItem extends StatelessWidget {
  final dynamic threadDetails;
  ThreadListItem({this.threadDetails});

  @protected
  void onTapItem(BuildContext context) {
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
  List<WidgetSpan> getDetailIcons(BuildContext context) {
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
        ),
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
  Widget getSubtitle(BuildContext context) {
    return Container();
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
