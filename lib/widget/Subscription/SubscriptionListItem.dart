import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/widget/InkWellOnWidget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SubscriptionListItem extends StatelessWidget {
  final ThreadAlert item;
  final Function onTapItem;
  final Function onTapNewPostButton;
  final Function onLongPress;
  final Function onUnsubscribe;

  SubscriptionListItem(
      {this.item, this.onTapItem, this.onTapNewPostButton, this.onUnsubscribe, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    String iconUrl = iconList.where((icon) => icon.id == item.iconId).first.url;

    return Card(
      color: Color.fromRGBO(45, 45, 48, 1),
      clipBehavior: Clip.antiAlias,
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Unsubscribe',
            iconWidget: Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Icon(
                FontAwesomeIcons.trash,
                size: 12,
              ),
            ),
            color: Colors.red,
            onTap: onUnsubscribe,
          ),
        ],
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CachedNetworkImage(
                      width: 25,
                      imageUrl: iconUrl,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  color: Color.fromRGBO(34, 34, 38, 1),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onTapItem(item),
                      onLongPress: () => onLongPress(item),
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
                                  if (item.locked == 1)
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
                                  if (item.pinned == 1)
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.bottom,
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
                                    text: item.threadTitle,
                                  ),
                                ]),
                              ),
                            ),
                            if (item.unreadPosts > 0)
                              Stack(
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
                                            color:
                                                Color.fromRGBO(255, 201, 63, 1),
                                            child: Text(
                                              '${item.unreadPosts} new posts',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          onTap: () {
                                            onTapNewPostButton(item);
                                          },
                                        )),
                                  ),
                                ],
                              ),
                            Text(
                              item.threadUsername,
                              style: TextStyle(color: AppColors(context).userGroupToColor(item.threadUserUsergroup)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 130,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 4),
                      child: Text(
                        item.lastPost.thread.postCount.toString() + ' replies',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 4),
                      child: Text(
                        timeago.format(item.threadCreatedAt),
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 4),
                      child: Text(
                        item.lastPost.user.username,
                        style: TextStyle(color: AppColors(context).userGroupToColor(item.lastPost.user.usergroup), fontSize: 11),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 4),
                      child: Text(
                        timeago.format(item.lastPost.createdAt),
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
