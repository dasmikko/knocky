import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/notification.dart';
import 'package:knocky/widgets/shared/avatar.dart';

class NotificationPostReplyListItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationPostReplyListItem(this.notification, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          child: Column(
        children: [
          notification.data.user.avatarUrl == null
              ? CachedNetworkImage(
                  imageUrl: 'https://img.icons8.com/color/96/000000/chat.png')
              : Avatar(
                  avatarUrl: notification.data.user.avatarUrl,
                  isBanned: notification.data.user.isBanned),
        ],
      )),
    );
  }
}
