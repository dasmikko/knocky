import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/Thread/PostContent.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserProfilePostListItem extends StatelessWidget {
  final ThreadPost post;

  UserProfilePostListItem({this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
          color: Theme.of(context).brightness == Brightness.dark
              ? Color.fromRGBO(45, 45, 48, 1)
              : Color.fromRGBO(230, 230, 230, 1),
          child: Row(
            children: <Widget>[Text(timeago.format(post.createdAt))],
          ),
        ),
        Container(
          padding: EdgeInsets.all(10.0),
          child: PostContent(
            content: this.post.content,
            textSelectable: false,
          ),
        ),
      ],
    ));
  }
}
