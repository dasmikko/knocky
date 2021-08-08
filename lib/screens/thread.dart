import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/jumpToPageDialog.dart';
import 'package:knocky/widgets/post/postListItem.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  final ItemScrollController itemScrollController = new ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();

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
      itemScrollController.jumpTo(index: 0);
      threadController.goToPage(page);
    }
  }

  goToPage(int pageNum) {
    itemScrollController.jumpTo(index: 0);
    threadController.goToPage(pageNum);
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
                      : () => goToPage(threadController.page - 1),
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
                      : () => goToPage(threadController.page + 1),
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
        child: IntrinsicHeight(
            child: Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: <Widget>[
          PageSelector.pageSelector(itemScrollController, threadController),
          posts(),
          PageSelector.pageSelector(itemScrollController, threadController)
        ],
      ),
    )));
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
}
