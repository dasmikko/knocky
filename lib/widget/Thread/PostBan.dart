import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostBan extends StatelessWidget {
  final ThreadPostBan ban;

  PostBan({this.ban});

  int calcHours () {
    DateTime now = DateTime.now();
    DateTime expires = ban.banExpiresAt;

    Duration difference = now.difference(expires);
    return difference.inHours;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      color: Colors.red,
      child: Column(children: <Widget>[
        Text('User was banned by ' + ban.banBannedBy + ' for this post for ' + calcHours().toString() + ' with reason: ' + ban.banReason)
      ],),
    );
  }
}