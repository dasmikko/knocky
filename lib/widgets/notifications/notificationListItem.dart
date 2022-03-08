import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/notification.dart';
import 'package:knocky/widgets/shared/avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
  final int index;

  const NotificationListItem(this.notification, this.index, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notification.type == 'POST_REPLY') {
      return Opacity(
        opacity: notification.read ? 0.5 : 1,
        child: Card(
          child: replyContent(),
        ),
      );
    }

    if (notification.type == 'MESSAGE') {
      return Opacity(
        opacity: notification.read ? 0.5 : 1,
        child: Card(
          child: messageContent(),
        ),
      );
    }

    return Container(child: Text('New unsupported notification item!'));
  }

  Widget replyContent() {
    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            height: 50,
            child: notification.replyData.user.avatarUrl == 'none.webp'
                ? CachedNetworkImage(
                    imageUrl: 'https://img.icons8.com/color/96/000000/chat.png')
                : Avatar(
                    avatarUrl: notification.replyData.user.avatarUrl,
                    isBanned: notification.replyData.user.isBanned),
          ),
          Divider(
            indent: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: notification.replyData.user.username,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      TextSpan(
                        text: " replied to your post in ",
                      ),
                      TextSpan(
                        text: notification.replyData.thread.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Text(timeago.format(notification.createdAt)),
              ],
            ),
          ),
          notification.read
              ? Container()
              : Container(
                  margin: EdgeInsets.only(left: 12),
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: Colors.blue, shape: BoxShape.circle))
        ],
      ),
    );
  }

  Widget messageContent() {
    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            height: 50,
            child: notification.messageData.users.first.avatarUrl == 'none.webp'
                ? CachedNetworkImage(
                    imageUrl: 'https://img.icons8.com/color/96/000000/chat.png')
                : Avatar(
                    avatarUrl: notification.messageData.users.first.avatarUrl,
                    isBanned: notification.messageData.users.first.isBanned),
          ),
          Divider(
            indent: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: notification.messageData.users.first.username,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      TextSpan(
                        text: " Sent you a message.",
                      ),
                    ],
                  ),
                ),
                Text(timeago.format(notification.createdAt)),
              ],
            ),
          ),
          notification.read
              ? Container()
              : Container(
                  margin: EdgeInsets.only(left: 12),
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: Colors.blue, shape: BoxShape.circle))
        ],
      ),
    );
  }
}
