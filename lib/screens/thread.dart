import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/jumpToPageDialog.dart';
import 'package:knocky/widgets/post/postListItem.dart';
import 'package:knocky/widgets/shared/newPost.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';

class ThreadScreen extends StatefulWidget {
  final int id;
  final int page;
  final int linkedPostId;

  ThreadScreen({@required this.id, this.page: 1, this.linkedPostId});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen>
    with SingleTickerProviderStateMixin {
  final ThreadController threadController = Get.put(ThreadController());
  final AuthController authController = Get.put(AuthController());
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();

  ItemPosition lastItemPostion;

  var subscription;

  @override
  void initState() {
    super.initState();
    threadController.initState(widget.id, widget.page);

    itemPositionListener.itemPositions.addListener(() {
      ItemPosition newItemPosition =
          itemPositionListener.itemPositions.value.first;

      int widgetlistLength = generateWidgetList().length - 2;
      if (itemPositionListener.itemPositions.value.last.index >=
          (widgetlistLength - 2)) {
        threadController.hideFAB.value = true;
        return;
      }

      String scrollDirection = 'none';

      if (lastItemPostion == null) {
        lastItemPostion = newItemPosition;
      } else {
        if (newItemPosition.index != lastItemPostion.index) {
          // If index is going up, user is scrolling down
          if (newItemPosition.index > lastItemPostion.index) {
            scrollDirection = 'down';
          }
          if (newItemPosition.index < lastItemPostion.index) {
            scrollDirection = 'up';
          }
        }

        // If index are the same, compare scroll positons
        if (newItemPosition.index == lastItemPostion.index) {
          if (newItemPosition.itemLeadingEdge <
              lastItemPostion.itemLeadingEdge) {
            scrollDirection = 'down';
          }

          if (newItemPosition.itemLeadingEdge >
              lastItemPostion.itemLeadingEdge) {
            scrollDirection = 'up';
          }
        }

        if (scrollDirection == 'down' &&
            threadController.hideFAB.value != true) {
          threadController.hideFAB.value = true;
        }

        if (scrollDirection == 'up' &&
            threadController.hideFAB.value != false) {
          threadController.hideFAB.value = false;
        }

        // Update lastItemPosition
        lastItemPostion = newItemPosition;
      }
    });

    // Listen for when we have fetched the thread data, and scroll to specific post, if requested
    subscription = threadController.data.listen((Thread thread) async {
      if (thread != null) {
        // User request to scroll to specific post
        if (this.widget.linkedPostId != null) {
          // The delayed if a huge stupid fucking hack, to make it work while in debug mode.
          await Future.delayed(Duration(milliseconds: 100));

          // Find the index of the post to scroll to
          int postIndex =
              thread.posts.indexWhere((o) => o.id == this.widget.linkedPostId) +
                  1;

          // If we can't find the postIndex, just scroll to the top.
          threadController.itemScrollController
              .jumpTo(index: postIndex == -1 ? 0 : postIndex);

          // Stop listening for more change, as we will never have to scroll to specific post anymore
          subscription.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();

    // Clear new text as we have leaved the thread
    threadController.currentNewPostText.value = '';
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
      threadController.itemScrollController.jumpTo(index: 0);
      threadController.goToPage(page);
    }
  }

  void onTapSubscribe() async {
    Thread thread = threadController.data.value;

    try {
      SnackbarController snackbarController = KnockySnackbar.normal(
        "Subscribing...",
        "Subscribing thread...",
        isDismissible: false,
        showProgressIndicator: true,
      );
      await KnockoutAPI()
          .subscribe(thread.posts.last.threadPostNumber, thread.id);
      snackbarController.close();
      threadController.fetch();
      KnockySnackbar.success("Subscribed thread");
    } catch (error) {}
  }

  void onTabUnsubscribed() async {
    Thread thread = threadController.data.value;
    SnackbarController snackbarController = KnockySnackbar.normal(
      "Unsubscribing...",
      "Unsubscribing thread...",
      isDismissible: false,
      showProgressIndicator: true,
    );

    await KnockoutAPI().deleteThreadAlert(thread.id);
    snackbarController.close();
    threadController.fetch();
    KnockySnackbar.success("Unsubscribed thread");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Obx(
            () => GestureDetector(
              onTap: () {
                threadController.itemScrollController.scrollTo(
                  index: 0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOutCirc,
                );
              },
              child: Text(threadController.title ?? 'Loading thread...'),
            ),
          ),
          actions: [
            IconButton(
              tooltip: "Jump to page",
              icon: Icon(Icons.redo),
              onPressed: () => showJumpDialog(),
            ),
            GetBuilder<ThreadController>(
              init: ThreadController(), // INIT IT ONLY THE FIRST TIME
              builder: (_) => PopupMenuButton(
                onSelected: (value) async {
                  switch (value) {
                    case 1:
                      Clipboard.setData(
                        new ClipboardData(
                            text:
                                'https://knockout.chat/thread/${_.id}/${_.page}'),
                      );
                      KnockySnackbar.success("Thread link was copied");
                      break;
                    case 2:
                      onTabUnsubscribed();
                      break;
                    case 3:
                      onTapSubscribe();
                      break;
                    case 4:
                      String url =
                          'https://knockout.chat/thread/${_.id}/${_.page}';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch url';
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  _.data.value.subscribed
                      ? overFlowItem(
                          FaIcon(
                            FontAwesomeIcons.solidBellSlash,
                            size: 15,
                          ),
                          'Unsubscribe',
                          2)
                      : null,
                  !_.data.value.subscribed
                      ? overFlowItem(
                          FaIcon(
                            FontAwesomeIcons.solidBell,
                            size: 15,
                          ),
                          'Subscribe',
                          3)
                      : null,
                  overFlowItem(
                      FaIcon(
                        FontAwesomeIcons.copy,
                        size: 15,
                      ),
                      'Copy link to thread',
                      1),
                  overFlowItem(
                      FaIcon(
                        FontAwesomeIcons.chrome,
                        size: 15,
                      ),
                      'Open in browser',
                      4),
                ],
              ),
            )
          ]),
      body: Container(
        child: Obx(
          () => KnockoutLoadingIndicator(
            show: threadController.isFetching.value,
            child: RefreshIndicator(
              onRefresh: () async => threadController.fetch(),
              child:
                  threadController.data.value != null ? posts() : Container(),
            ),
          ),
        ),
      ),
      floatingActionButton: Obx(
        () => authController.isAuthenticated.value &&
                (threadController.data.value != null &&
                    (threadController.data.value.locked != null &&
                        !threadController.data.value.locked))
            ? AnimatedScale(
                curve: Curves.easeOutCirc,
                scale: threadController.hideFAB.value ? 0.0 : 1.0,
                duration: Duration(milliseconds: 250),
                child: FloatingActionButton(
                  child: FaIcon(
                    FontAwesomeIcons.chevronDown,
                    color: Theme.of(context).textTheme.bodyText1.color,
                  ),
                  onPressed: () {
                    threadController.itemScrollController.scrollTo(
                      index: 999,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOutCirc,
                    );
                  },
                ),
              )
            : Container(),
      ),
    );
  }

  PopupMenuItem<int> overFlowItem(Widget icon, String title, int value) {
    return PopupMenuItem<int>(
      value: value,
      child: ListTile(
        horizontalTitleGap: 0,
        leading: icon,
        title: Text(title),
      ),
    );
  }

  goToPage(int pageNum) {
    threadController.itemScrollController.jumpTo(index: 0);
    threadController.goToPage(pageNum);
  }

  Widget pageSelector() {
    return PageSelector(
      onNext: () {
        threadController.itemScrollController.jumpTo(index: 0);
        threadController.nextPage();
      },
      onPage: (page) {
        threadController.itemScrollController.jumpTo(index: 0);
        threadController.goToPage(page);
      },
      pageCount: threadController.pageCount,
      currentPage: threadController.page,
    );
  }

  void onSubmit() async {
    threadController.itemScrollController.jumpTo(index: 0);
    if (threadController.data.value.posts.length ==
        PostsPerPage.POSTS_PER_PAGE) {
      threadController.itemScrollController.jumpTo(index: 0);
      threadController.nextPage();
    } else {
      threadController.fetch();
    }
    Thread thread = threadController.data.value;

    // Subscribe to the thread if not!
    if (!thread.subscribed) {
      await KnockoutAPI()
          .subscribe(thread.posts.last.threadPostNumber, thread.id);
    }
  }

  Widget postEditor() {
    if (!authController.isAuthenticated.value ||
        threadController.data.value.locked) {
      return Container();
    }
    return Container(
        padding: EdgeInsets.all(8),
        child: NewPost(
          threadId: widget.id,
          onSubmit: onSubmit,
        ));
  }

  List<Widget> generateWidgetList() {
    List<Widget> widgets = [];

    // Add paginator
    widgets.add(
      Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: pageSelector(),
      ),
    );

    if (threadController.data.value != null) {
      threadController.data.value.posts.forEach((post) {
        widgets.add(
          PostListItem(
            post: post,
            readThreadLastSeen: threadController.data.value.readThreadLastSeen,
          ),
        );
      });
    }

    widgets.add(
      postEditor(),
    );

    widgets.add(
      Container(
        margin: EdgeInsets.only(bottom: 8),
        child: pageSelector(),
      ),
    );

    return widgets;
  }

  Widget posts() {
    List<Widget> widgets = generateWidgetList();

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: ScrollablePositionedList.builder(
        itemScrollController: threadController.itemScrollController,
        itemPositionsListener: itemPositionListener,
        itemCount:
            widgets.length, //(threadController.data.value?.posts?.length) ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return widgets[index];
        },
      ),
    );
  }
}
