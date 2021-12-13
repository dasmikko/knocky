import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/bbcode/bbcodeRendererNew.dart';
import 'package:knocky/widgets/post/ratings.dart';
import 'package:knocky/widgets/post/toolbar.dart';
import 'package:knocky/widgets/post/userInfo.dart';
import 'package:knocky/widgets/shared/editPost.dart';

class PostListItem extends StatefulWidget {
  final ThreadPost post;
  final DateTime readThreadLastSeen;
  final Function onPostUpdate;
  PostListItem(
      {@required this.post, this.readThreadLastSeen, this.onPostUpdate});

  @override
  State<PostListItem> createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  final AuthController authController = Get.put(AuthController());
  final textEditingController = new TextEditingController();
  bool showBBCode = false;
  bool editPost = false;

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
        onToggleEditPost: () {
          setState(() {
            editPost = !editPost;
          });
        },
      ),
      postBody(context),
    ];
  }

  @protected
  Widget postBody(BuildContext context) {
    Widget innerBody;

    if (editPost) {
      innerBody = EditPost(
        postId: widget.post.id,
        content: widget.post.content,
        onSubmit: () {
          setState(() {
            editPost = false;
          });
          widget.onPostUpdate.call();
        },
      );
    } else if (showBBCode) {
      innerBody = SelectableText(widget.post.content);
    } else {
      innerBody = BBcodeRendererNew(
        parentContext: context,
        bbcode: widget.post.content,
        postDetails: widget.post,
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(8, 16, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [innerBody, ratings()],
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
