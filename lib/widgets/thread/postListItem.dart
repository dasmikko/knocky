import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/thread/userInfo.dart';

class PostListItem extends StatelessWidget {
  final ThreadPost post;

  PostListItem({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        UserInfo(user: post.user),
        Row(), // todo: post metadata + controls
        Container(
            // todo: use BB renderer
            child: Text(this.post.content))
      ],
    ));
  }
}
