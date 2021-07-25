import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/post/postListItem.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ThreadScreen extends StatefulWidget {
  final int id;
  final int page;
  // TODO: actually use this
  final int linkedPostId;

  ThreadScreen({@required this.id, this.page: 1, this.linkedPostId});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final ThreadController threadController = Get.put(ThreadController());
  final ItemScrollController itemScrollController = new ItemScrollController();

  @override
  void initState() {
    super.initState();
    threadController.initState(widget.id, widget.page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(threadController.title ?? 'Loading thread...')),
          actions: [],
        ),
        body: Container(
          child: Obx(
            () => KnockoutLoadingIndicator(
              show: threadController.isFetching.value,
              child: RefreshIndicator(
                  onRefresh: () async => threadController.fetch(),
                  // TODO: this should probably be a column but there is an issue
                  child: Stack(children: [
                    PageSelector.pageSelector(
                        itemScrollController, threadController),
                    posts()
                  ])),
            ),
          ),
        ));
  }

  Widget posts() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 48, 0, 0),
        child: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          addAutomaticKeepAlives: true,
          minCacheExtent: MediaQuery.of(context).size.height,
          itemCount: threadController.thread.value?.posts?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            ThreadPost post = threadController.thread.value.posts[index];
            return PostListItem(
              post: post,
            );
          },
        ));
  }
}
