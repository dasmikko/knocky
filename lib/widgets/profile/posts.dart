import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/postController.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/post/postListItem.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../KnockoutLoadingIndicator.dart';

class ProfilePosts extends StatefulWidget {
  final int id;
  final int page;

  ProfilePosts({@required this.id, this.page: 1});

  @override
  _ProfilePostsState createState() => _ProfilePostsState();
}

class _ProfilePostsState extends State<ProfilePosts> {
  final postsController = Get.put(ProfilePostController());
  final itemScrollController = new ItemScrollController();

  @override
  void initState() {
    super.initState();
    postsController.initState(widget.id, widget.page);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(
        () => KnockoutLoadingIndicator(
          show: postsController.isFetching.value,
          child: RefreshIndicator(
              onRefresh: () async => postsController.fetch(),
              child: Stack(children: [
                PageSelector.pageSelector(
                    itemScrollController, postsController),
                posts()
              ])),
        ),
      ),
    );
  }

  Widget posts() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 48, 0, 0),
        child: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          addAutomaticKeepAlives: true,
          minCacheExtent: MediaQuery.of(context).size.height,
          itemCount: postsController.thread.value?.posts?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            ThreadPost post = postsController.thread.value.posts[index];
            return PostListItem(
              post: post,
              showUserInfo: false,
            );
          },
        ));
  }
}
