import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';
import 'package:time_formatter/time_formatter.dart';

class Toolbar extends StatelessWidget {
  final ThreadPost post;

  Toolbar({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        color: Theme.of(context).primaryColor,
        height: 30,
        child: Row(
          children: [
            Text(formatTime(post.createdAt.millisecondsSinceEpoch)),
            Container(
              margin: EdgeInsets.only(left: 8),
              child: Text(
                "#${post.threadPostNumber.toString()}",
                style: TextStyle(color: Colors.white60),
              ),
            )
          ],
        ) // TODO: post metadata + controls
        );
  }
}
