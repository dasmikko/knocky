import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/post/userInfo.dart';

class PostListItem extends StatelessWidget {
  final ThreadPost post;

  PostListItem({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          children: [
            UserInfo(user: post.user),
            Container(
                color: Theme.of(context).primaryColor,
                height: 30,
                child: Row() // todo: post metadata + controls
                ),
            Container(
                padding: EdgeInsets.fromLTRB(8, 24, 16, 24),
                // todo: use BB renderer
                child: Text(this.post.content))
          ],
        ));
  }
}
