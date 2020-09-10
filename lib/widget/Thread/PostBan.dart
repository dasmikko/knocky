import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky_edge/models/thread.dart';

class PostBan extends StatelessWidget {
  final ThreadPostBan ban;

  PostBan({this.ban});

  String calcHours() {
    DateTime created = ban.banCreatedAt;
    DateTime expires = ban.banExpiresAt;
    Duration difference = expires.difference(created);

    if (difference.inHours < 24) {
      if (difference.inHours > 2) {
        return difference.inHours.toString() + ' hours';
      } else {
        return difference.inHours.toString() + ' hour';
      }
    } else {
      if (difference.inDays > 2) {
        return difference.inDays.toString() + ' days';
      } else {
        return difference.inDays.toString() + ' day';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 5),
      color: Color.fromRGBO(220, 64, 53, 1),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 15),
            child: CachedNetworkImage(
              imageUrl:
                  'https://img.icons8.com/color/50/000000/police-badge.png',
            ),
          ),
          Flexible(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(text: 'User was banned by '),
                TextSpan(
                    text: ban.banBannedBy,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' for this post for '),
                TextSpan(
                    text: calcHours(),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' with reason: '),
                TextSpan(
                    text: ban.banReason,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
