import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/bbcode/bbcodeRenderer.dart';
import 'package:knocky/widgets/post/toolbar.dart';
import 'package:knocky/widgets/post/userInfo.dart';

class PostListItem extends StatelessWidget {
  final ThreadPost post;

  PostListItem({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserInfo(user: post.user),
          Toolbar(post: post),
          Container(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
              // TODO: use BB renderer
              child: BBcodeRenderer(
                parentContext: context,
                bbcode: post.content,
                postDetails: post,
              ))
        ],
      ),
    );
  }
}
