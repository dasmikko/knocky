import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';

class PostListItem extends StatelessWidget {
  final ThreadPost threadPost;

  PostListItem({@required this.threadPost});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        // todo: avatar/bg here
        Row(), // todo: post metadata + controls
        Container(
            // todo: actual post here
            child: Text(this.threadPost.content))
      ],
    ));
  }
}
