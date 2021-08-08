import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/jumpToPageDialog.dart';
import 'package:knocky/widgets/post/postListItem.dart';
import 'package:knocky/widgets/shared/newPost.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:knocky/widgets/shared/postEditorBBCode.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:rxdart/rxdart.dart';

class ThreadScreen extends StatefulWidget {
  final int id;
  final int page;
  // TODO: https://stackoverflow.com/questions/48900769/how-to-scroll-singlechildscrollview-programmatically
  final int linkedPostId;

  ThreadScreen({@required this.id, this.page: 1, this.linkedPostId});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen>
    with SingleTickerProviderStateMixin {
  final ThreadController threadController = Get.put(ThreadController());
  final AuthController authController = Get.put(AuthController());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    threadController.initState(widget.id, widget.page);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showJumpDialog() async {
    int page = await Get.dialog(
      JumpToPageDialog(
        minValue: 1,
        maxValue: threadController.pageCount,
        value: threadController.page,
      ),
    );

    if (page != null) {
      pageClicked(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(threadController.title ?? 'Loading thread...')),
        actions: [
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: () => showJumpDialog(),
          )
        ],
      ),
      body: Container(
        child: Obx(
          () => KnockoutLoadingIndicator(
            show: threadController.isFetching.value,
            child: RefreshIndicator(
              onRefresh: () async => threadController.fetch(),
              child: bodyWidgets(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            height: 56,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text('Page ' +
                      threadController.page.toString() +
                      ' of ' +
                      threadController.pageCount.toString()),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: threadController.page == 1
                      ? null
                      : () => pageClicked(threadController.page - 1),
                ),
                IconButton(
                  onPressed:
                      threadController.pageCount > 1 ? showJumpDialog : null,
                  icon: Icon(Icons.redo),
                  tooltip: 'Jump to page',
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: threadController.pageCount == threadController.page
                      ? null
                      : () => pageClicked(threadController.page + 1),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bodyWidgets() {
    return SingleChildScrollView(
        controller: scrollController,
        child: IntrinsicHeight(
            child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              pageSelector(),
              posts(),
              postEditor(),
              pageSelector(),
            ],
          ),
        )));
  }

  Widget pageSelector() {
    return PageSelector(
      onNext: () => nextPageClicked(),
      onPage: (page) => pageClicked(page),
      pageCount: threadController.pageCount,
      currentPage: threadController.page,
    );
  }

  nextPageClicked() {
    scrollTo(0);
    threadController.nextPage();
  }

  pageClicked(int page) {
    scrollTo(0);
    threadController.goToPage(page);
  }

  scrollTo(double value) {
    threadController.isFetching.stream
        .skip(1)
        .take(1)
        .delay(Duration(milliseconds: 600))
        .listen((data) => {
              scrollController.animateTo(value,
                  duration: Duration(milliseconds: 300), curve: Curves.ease)
            });
  }

  Widget posts() {
    if (threadController.data.value?.posts == null) {
      return Container();
    }

    var posts = threadController.data.value.posts
        .map((post) => PostListItem(post: post));
    return Container(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: Column(children: [...posts]));
  }

  void onSubmit() {
    scrollTo(0);
    if (threadController.data.value.posts.length ==
        PostsPerPage.POSTS_PER_PAGE) {
      scrollTo(0);
      threadController.nextPage();
    } else {
      // scrollTo(0); // TODO: scroll to new post, not to the top
      threadController.fetch();
    }
  }

  Widget postEditor() {
    if (!authController.isAuthenticated.value) {
      return Container();
    }
    return Container(
        padding: EdgeInsets.all(8),
        child: NewPost(
          threadId: widget.id,
          onSubmit: onSubmit,
        ));
  }
}
