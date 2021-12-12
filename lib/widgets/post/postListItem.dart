import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/bbcode/bbcodeRenderer.dart';
import 'package:knocky/widgets/post/ratings.dart';
import 'package:knocky/widgets/post/toolbar.dart';
import 'package:knocky/widgets/post/userInfo.dart';

class PostListItem extends StatefulWidget {
  final ThreadPost post;
  final DateTime readThreadLastSeen;
  PostListItem({@required this.post, this.readThreadLastSeen});

  @override
  State<PostListItem> createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  final AuthController authController = Get.put(AuthController());
  bool showBBCode = false;

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
    if (widget.readThreadLastSeen != null &&
        widget.readThreadLastSeen.isBefore(widget.post.createdAt)) {
      isNewPost = true;
    }

    return [
      UserInfo(
        user: widget.post.user,
        isNewPost: isNewPost,
      ),
      Toolbar(
        post: widget.post,
        onToggleBBCode: () {
          setState(() {
            showBBCode = !showBBCode;
          });
        },
      ),
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
          showBBCode
              ? SelectableText(widget.post.content)
              : BBcodeRenderer(
                  parentContext: context,
                  bbcode: widget.post.content,
                  postDetails: widget.post,
                ),
          ratings()
        ],
      ),
    );
  }

  @protected
  Widget ratings() {
    return Ratings(
        postId: widget.post.id, ratings: widget.post.ratings, onRated: onRated);
  }

  onRated() {
    print('rated');
  }
}
