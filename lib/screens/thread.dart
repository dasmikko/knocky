import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/helpers/postsPerPage.dart';
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
  int _page = 1;

  @override
  void initState() {
    _page = widget.page;
    fetch();
    super.initState();
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
                  onRefresh: () async => fetch(),
                  // todo: this should probably be a column but there is an issue
                  child: Stack(children: [pageSelector(), posts()])),
            ),
          ),
        ),
        drawer: MainDrawer());
  }

  void fetch() {
    threadController.fetchThreadPage(this.widget.id, page: _page);
  }

  void nextPage() {
    this.setState(() {
      _page++;
    });
    fetch();
  }

  void goToPage(page) {
    print(page);
    this.setState(() {
      _page = page;
    });
    fetch();
  }

  Widget pageSelector() {
    int pageCount =
        (threadController.thread.value.totalPosts / PostsPerPage.POSTS_PER_PAGE)
            .ceil();
    return PageSelector(
      pageCount: pageCount,
      onNext: () => nextPage(),
      onPage: (page) => goToPage(page),
      currentPage: _page,
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
