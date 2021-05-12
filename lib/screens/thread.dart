import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/drawer/mainDrawer.dart';
import 'package:knocky/widgets/post/postListItem.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ThreadScreen extends StatefulWidget {
  final int id;
  final int page;
  // todo: actually use this
  final int linkedPostId;

  ThreadScreen({@required this.id, this.page: 1, this.linkedPostId});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final ThreadController threadController = Get.put(ThreadController());

  @override
  void initState() {
    super.initState();
    threadController.initState(widget.id, widget.page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Knocky"),
          actions: [],
        ),
        body: Container(
          child: Obx(
            () => KnockoutLoadingIndicator(
              show: threadController.isFetching.value,
              child: RefreshIndicator(
                  onRefresh: () async => threadController.fetch(),
                  // todo: this should probably be a column but there is an issue
                  child: Stack(children: [pageSelector(), posts()])),
            ),
          ),
        ),
        drawer: MainDrawer());
  }

  Widget pageSelector() {
    return PageSelector(
      pageCount: threadController.pageCount,
      onNext: () => threadController.nextPage(),
      onPage: (page) => threadController.goToPage(page),
      currentPage: threadController.page,
    );
  }

  Widget posts() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 48, 0, 0),
        child: ScrollablePositionedList.builder(
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
