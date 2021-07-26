import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/profileThreadController.dart';
import 'package:knocky/widgets/profile/thread.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:knocky/widgets/significantThreads/popularThreadListItem.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../KnockoutLoadingIndicator.dart';

class ProfileThreads extends StatefulWidget {
  final int id;
  final int page;

  ProfileThreads({@required this.id, this.page: 1});

  @override
  _ProfileThreadsState createState() => _ProfileThreadsState();
}

class _ProfileThreadsState extends State<ProfileThreads> {
  final postsController = Get.put(ProfileThreadController());
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
          itemCount: postsController.threads.value?.threads?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            var thread = postsController.threads.value.threads[index];
            return ProfileThreadListItem(thread: thread);
          },
        ));
  }
}
