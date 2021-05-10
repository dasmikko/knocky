import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/shared/avatar.dart';

class UserInfo extends StatelessWidget {
  final ThreadPostUser user;

  UserInfo({@required this.user});

  @override
  Widget build(BuildContext context) {
    // todo: background
    return Container(
        child: Row(children: [
      // CachedNetworkImage(imageUrl: user.avatarUrl),
      Container(
          child: Avatar(avatarUrl: user.avatarUrl, isBanned: user.isBanned)),
      Text(user.username) // todo: render name according to user group
    ]));
  }
}
