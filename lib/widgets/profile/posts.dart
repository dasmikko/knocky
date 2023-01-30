import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/profilePostController.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/profile/post.dart';
import 'package:knocky/widgets/shared/paginatedListView.dart';

class ProfilePosts extends PaginatedListView {
  ProfilePosts({@required id, page = 1}) : super(id: id, page: page);

  @override
  _ProfilePostsState createState() => _ProfilePostsState();
}

class _ProfilePostsState
    extends PaginatedListViewState<ProfilePostController, ProfilePosts> {
  @override
  void initState() {
    dataController = Get.put(ProfilePostController());
    super.initState();
  }

  @override
  Widget listItem(dynamic listItemData) {
    return ProfilePostListItem(post: listItemData as ThreadPost);
  }
}
