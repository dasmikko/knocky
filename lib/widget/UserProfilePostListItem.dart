import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/Thread/PostContent.dart';

class UserProfilePostListItem extends StatelessWidget {
  final ThreadPost post;

  UserProfilePostListItem({this.post});

  @override
  Widget build(BuildContext context) {
    return PostContent(
      content: this.post.content,
      textSelectable: true,
    );
  }
}