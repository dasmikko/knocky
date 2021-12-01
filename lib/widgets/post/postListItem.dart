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
  final DateTime readThreadLastSeen;
  PostListItem({@required this.post, this.readThreadLastSeen});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...contents(context)]),
    );
  }

  @protected
  List<Widget> contents(BuildContext context) {
    bool isNewPost = false;
    if (readThreadLastSeen != null &&
        readThreadLastSeen.isBefore(post.createdAt)) {
      isNewPost = true;
    }

    return [
      UserInfo(
        user: post.user,
        isNewPost: isNewPost,
      ),
      Toolbar(post: post),
      postBody(context),
    ];
  }

  @protected
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
          ratings()
        ],
      ),
    );
  }

  @protected
  Widget ratings() {
    return Ratings(postId: post.id, ratings: post.ratings, onRated: onRated);
  }

  onRated() {
    print('rated');
  }
}
