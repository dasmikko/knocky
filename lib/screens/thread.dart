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
                child: posts(),
              ),
            ),
          ),
        ));
  }

  Widget pageSelector() {
    return PageSelector(
      onNext: () {
        itemScrollController.jumpTo(index: 0);
        threadController.nextPage();
      },
      onPage: (page) {
        itemScrollController.jumpTo(index: 0);
        threadController.goToPage(page);
      },
      pageCount: threadController.pageCount,
      currentPage: threadController.page,
    );
  }

  Widget posts() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          addAutomaticKeepAlives: true,
          minCacheExtent: MediaQuery.of(context).size.height,
          itemCount: (threadController.thread.value?.posts?.length) ?? 0,
          itemBuilder: (BuildContext context, int index) {
            print(threadController.thread.value.posts.length);
            print(index);
            ThreadPost post = threadController.thread.value.posts[index];

            if (index == 0) {
              // Insert header
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: pageSelector(),
                  ),
                  PostListItem(
                    post: post,
                  )
                ],
              );
            }

            if (index == (threadController.thread.value.posts.length - 1)) {
              return Column(
                children: [
                  PostListItem(
                    post: post,
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: pageSelector(),
                  ),
                ],
              );
            }

            return PostListItem(
              post: post,
            );
          },
        ));
  }
}
