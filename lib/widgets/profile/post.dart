import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/post/postListItem.dart';
import 'package:knocky/widgets/post/ratings.dart';
import 'package:knocky/widgets/profile/toolbar.dart';

class ProfilePostListItem extends PostListItem {
  final ThreadPost post;
  ProfilePostListItem({@required this.post}) : super(post: post);

  @override
  // ignore: override_on_non_overriding_member
  List<Widget> contents(BuildContext context) {
    return [
      ProfilePostToolbar(post: post),
    ];
  }

  @override
  // ignore: override_on_non_overriding_member
  Widget ratings() {
    return Ratings(postId: post.id, ratings: post.ratings, canRate: false);
  }
}
