import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/bbcode/bbcodeRenderer.dart';
import 'package:knocky/widgets/post/ratings.dart';
import 'package:knocky/widgets/post/toolbar.dart';
import 'package:knocky/widgets/post/userInfo.dart';

class PostListItem extends StatelessWidget {
  final ThreadPost post;
  final AuthController authController = Get.put(AuthController());

  PostListItem({@required this.post});

  Widget postBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 16, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BBcodeRenderer(
            parentContext: context,
            bbcode: post.content,
            postDetails: post,
          ),
          Ratings(postId: post.id, ratings: post.ratings, onRated: onRated)
        ],
      ),
    );
  }

  onRated() {
    print('rated');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        UserInfo(user: post.user),
        Toolbar(post: post),
        postBody(context)
      ]),
    );
  }
}
