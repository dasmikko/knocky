import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky_edge/helpers/api.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky_edge/models/syncData.dart';
import 'package:knocky_edge/screens/threadGallery.dart';
import 'package:knocky_edge/state/appState.dart';
import 'package:knocky_edge/state/subscriptions.dart';
import 'package:knocky_edge/models/thread.dart';
import 'package:knocky_edge/widget/Drawer.dart';
import 'package:knocky_edge/widget/Thread/ThreadPostItem.dart';
import 'package:knocky_edge/widget/KnockoutLoadingIndicator.dart';
import 'package:knocky_edge/widget/scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky_edge/state/authentication.dart';
import 'package:knocky_edge/screens/newPost.dart';

class ThreadScreen extends StatefulWidget {
  final String title;
  final int postCount;
  final int threadId;
  final int page;
  final int postIdToJumpTo;

  ThreadScreen(
      {this.title = 'Loading thread',
      this.page = 1,
      this.postCount,
      this.threadId,
      this.postIdToJumpTo});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen>
    with AfterLayoutMixin<ThreadScreen>, SingleTickerProviderStateMixin {
  Thread details;
  int _currentPage;
  int _totalPages = 0;
  bool _isLoading = true;
  final scaffoldkey = new GlobalKey<ScaffoldState>();
  final ItemScrollController scrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();
  StreamSubscription<Thread> _dataSub;
  bool _bottomBarVisible = true;
  AnimationController expandController;
  Animation<double> animation;
  BuildContext self;
  List<ThreadPost> postsToReplyTo = List();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (this.widget.page != null) {
      _currentPage = this.widget.page;
    } else {
      _currentPage = 1;
    }

    if (_totalPages == 0 && _currentPage != null) _totalPages = _currentPage;
    if (widget.postCount != null) {
      _totalPages = (widget.postCount / 20).ceil();
    }

    prepareAnimations();
  }

  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    Animation curve = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    animation = Tween(begin: 1.0, end: 0.0).animate(curve);
  }

  @override
  void dispose() {
    expandController.dispose();
    _dataSub.cancel();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    var api = new KnockoutAPI();

    setState(() {
      self = context;
    });

    Future _future =
        api.getThread(widget.threadId, page: _currentPage).catchError((error) {
      throw (error);
      setState(() {
        _isLoading = false;
      });

      /*Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load thread. Try again'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));*/
    });

    _dataSub = _future.asStream().listen((res) {
      setState(() {
        details = res;
        _isLoading = false;
        _totalPages = (details.totalPosts / 20).ceil();
      });

      checkIfShouldMarkThreadRead();
    });
  }

  void checkIfShouldMarkThreadRead() async {
    DateTime lastPostDate = details.posts.last.createdAt;

    // Check if last read is null
    if (details.readThreadLastSeen == null) {
      await KnockoutAPI().readThreads(lastPostDate, details.id).then((res) {});
    } else if (details.readThreadLastSeen.isBefore(lastPostDate)) {
      await KnockoutAPI().readThreads(lastPostDate, details.id).then((res) {});
    }

    if (details.isSubscribedTo != 0) {
      // Handle for subscribed thread
      // Check if last read is null
      if (details.subscriptionLastSeen == null) {
        await KnockoutAPI()
            .readThreads(lastPostDate, details.id)
            .then((res) {});
      } else if (details.subscriptionLastSeen.isBefore(lastPostDate)) {
        await KnockoutAPI()
            .readThreadSubsciption(lastPostDate, details.id)
            .then((res) {});
      }
    }
    ScopedModel.of<SubscriptionModel>(context).getSubscriptions();

    // Handle mentions too!
    final List<SyncDataMentionModel> mentions =
        ScopedModel.of<AppStateModel>(context, rebuildOnChange: true).mentions;

    List<int> mentionsPostIds = mentions.map((o) => o.postId).toList();
    List<int> threadPostIds = details.posts.map((o) => o.id).toList();
    List<int> idsToMarkRead = List();

    mentionsPostIds.forEach((postId) {
      if (threadPostIds.contains(postId)) {
        idsToMarkRead.add(postId);
      }
    });

    if (idsToMarkRead.length > 0) {
      KnockoutAPI().markMentionsAsRead(idsToMarkRead).then((wasMarkedRead) {
        ScopedModel.of<AppStateModel>(context).updateSyncData();
      });
    }
  }

  void navigateToNextPage() {
    setState(() {
      _isLoading = true;
      _currentPage = _currentPage + 1;
    });

    scrollController.jumpTo(index: 0);

    var api = new KnockoutAPI();

    _dataSub?.cancel();

    Future _future =
        api.getThread(widget.threadId, page: _currentPage).catchError((error) {
      setState(() {
        _isLoading = false;
      });

      Scaffold.of(self).hideCurrentSnackBar();
      Scaffold.of(self).showSnackBar(SnackBar(
        content: Text('Failed to load thread. Try again'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    });

    _dataSub = _future.asStream().listen((res) {
      setState(() {
        details = res;
        _isLoading = false;
      });
      checkIfShouldMarkThreadRead();
    });
  }

  void navigateToPrevPage() {
    setState(() {
      _isLoading = true;
      _currentPage = _currentPage - 1;
    });

    scrollController.jumpTo(index: 0);

    var api = new KnockoutAPI();

    _dataSub?.cancel();

    Future _future =
        api.getThread(widget.threadId, page: _currentPage).catchError((error) {
      setState(() {
        _isLoading = false;
      });

      Scaffold.of(self).hideCurrentSnackBar();
      Scaffold.of(self).showSnackBar(SnackBar(
        content: Text('Failed to load thread. Try again'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    });

    _dataSub = _future.asStream().listen((res) {
      setState(() {
        details = res;
        _isLoading = false;
      });
      checkIfShouldMarkThreadRead();
    });
  }

  void navigateToPage(int page) {
    setState(() {
      _isLoading = true;
      _currentPage = page;
    });

    scrollController.jumpTo(index: 0);

    var api = new KnockoutAPI();

    _dataSub?.cancel();
    Future _future =
        api.getThread(widget.threadId, page: _currentPage).catchError((error) {
      setState(() {
        _isLoading = false;
      });

      Scaffold.of(self).hideCurrentSnackBar();
      Scaffold.of(self).showSnackBar(SnackBar(
        content: Text('Failed to load thread. Try again'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    });

    _dataSub = _future.asStream().listen((res) {
      setState(() {
        details = res;
        _isLoading = false;
      });
      checkIfShouldMarkThreadRead();
    });
  }

  Future<void> refreshPage() async {
    setState(() {
      _isLoading = true;
    });

    Thread res = await KnockoutAPI()
        .getThread(widget.threadId, page: _currentPage)
        .catchError((error) {
      setState(() {
        _isLoading = false;
      });

      Scaffold.of(self).hideCurrentSnackBar();
      Scaffold.of(self).showSnackBar(SnackBar(
        content: Text('Failed to load thread. Try again'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    });
    setState(() {
      details = res;
      _isLoading = false;
    });
    checkIfShouldMarkThreadRead();
  }

  void onCancelSubscription(BuildContext scaffoldcontext) {
    KnockoutAPI().deleteThreadAlert(details.id).then((onValue) {
      Scaffold.of(scaffoldcontext).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Canceled subscription'),
            elevation: 6),
      );
    }).catchError((onError) {
      Scaffold.of(scaffoldcontext).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          content: Text('Cancel failed. Try again'),
        ),
      );
    });
  }

  void onTapSubscribe(BuildContext scaffoldcontext) {
    DateTime lastSeen;

    if (details.readThreadLastSeen != null) {
      lastSeen = details.readThreadLastSeen;
    } else {
      lastSeen = details.posts.last.createdAt;
    }

    KnockoutAPI().subscribe(lastSeen, details.id).then(
      (avoid) {
        Scaffold.of(scaffoldcontext).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Subscribed to thread'),
            elevation: 6,
            action: SnackBarAction(
              label: 'Cancel',
              onPressed: () => onCancelSubscription(scaffoldcontext),
            ),
          ),
        );
      },
    ).catchError((onError) {
      Scaffold.of(scaffoldcontext).showSnackBar(
        SnackBar(
          content: Text('Subscribing failed. Try again'),
        ),
      );
    });
  }

  void showJumpDialog() {
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: 1,
            maxValue: _totalPages,
            title: new Text("Jump to page"),
            initialIntegerValue: 1,
          );
        }).then((int value) {
      if (value != null) navigateToPage(value);
    });
  }

  void onPressReply(ThreadPost post, BuildContext buildContext) async {
    if (postsToReplyTo.length > 0) {
      onLongPressReply(new ThreadPost.clone(post), buildContext);
    } else {
      List<ThreadPost> reply = List();
      reply.add(
        new ThreadPost.clone(post),
      );

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewPostScreen(
            thread: details,
            replyList: reply,
          ),
        ),
      );

      if (result != null) {
        scaffoldkey.currentState.showSnackBar(SnackBar(
          content: Text('Posted!'),
          behavior: SnackBarBehavior.floating,
        ));
        await refreshPage();
        print('Do the scroll');
        //scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    }
  }

  void onLongPressReply(ThreadPost post, BuildContext buildContext) {
    if (postsToReplyTo.where((o) => o.id == post.id).length > 0) {
      setState(() {
        postsToReplyTo.removeWhere((o) => o.id == post.id);

        Scaffold.of(buildContext)
            .hideCurrentSnackBar(reason: SnackBarClosedReason.hide);
        Scaffold.of(buildContext).showSnackBar(SnackBar(
          content: Text('Removed post from reply list'),
          behavior: SnackBarBehavior.floating,
        ));
      });
    } else {
      setState(() {
        postsToReplyTo.add(new ThreadPost(
            bans: post.bans,
            content: post.content,
            createdAt: post.createdAt,
            id: post.id,
            ratings: post.ratings,
            user: post.user));

        Scaffold.of(buildContext)
            .hideCurrentSnackBar(reason: SnackBarClosedReason.hide);
        Scaffold.of(buildContext).showSnackBar(SnackBar(
          content: Text('Added post to reply list'),
          behavior: SnackBarBehavior.floating,
        ));
      });
    }
  }

  PopupMenuItem<int> overFlowItem(Icon icon, String title, int value) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 15),
            child: icon,
          ),
          Text(title)
        ],
      ),
    );
  }

  void onTapRenameThread() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller =
            new TextEditingController(text: details.title);
        return AlertDialog(
          title: Text('Rename thread'),
          contentPadding: EdgeInsets.all(25),
          content: TextField(
            controller: controller,
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (String finalText) {
              Navigator.of(context).pop(finalText);
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Rename'),
              onPressed: () => {Navigator.pop(context, controller.text)},
            )
          ],
        );
      },
    ).then((String newTitle) {
      if (newTitle != null) {
        KnockoutAPI()
            .renameThread(details.id, newTitle)
            .then((updatedThreadDetails) {
          setState(() {
            details.title = newTitle;
          });
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Thread renamed'),
            backgroundColor: Colors.green,
          ));
        });
      }
    });
  }

  void onSelectOverflowItem(int item) {
    switch (item) {
      case 0:
        refreshPage();
        break;
      case 1:
        onTapSubscribe(context);
        break;
      case 2:
        onTapRenameThread();
        break;
      case 3:
        navigateToPage(1);
        break;
      case 4:
        navigateToPage(_totalPages);
        break;
      case 5:
        Clipboard.setData(new ClipboardData(
            text:
                'https://knockout.chat/thread/${details.id}/${_currentPage}'));
        break;
      case 10:
        scrollController.jumpTo(index: 3);
        break;
      default:
    }
  }

  void onTapEditPost(BuildContext context, ThreadPost post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewPostScreen(
          editingPost: true,
          thread: details,
          post: post,
          replyList: List(),
        ),
      ),
    );

    if (result != null) {
      scaffoldkey.currentState.showSnackBar(SnackBar(
        content: Text('Posted!'),
        behavior: SnackBarBehavior.floating,
      ));
      await refreshPage();
      print('Do the scroll');
      scrollController.jumpTo(index: details.posts.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(details == null ? widget.title : details.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => refreshPage(),
          ),
          IconButton(
              icon: Icon(Icons.image),
              tooltip: 'Embed gallery',
              onPressed: details == null
                  ? null
                  : () {
                      Navigator.of(context, rootNavigator: true).push(
                          PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (context, anim, anim2) =>
                                  ThreadGalleryScreen(
                                    thread: details,
                                  ),
                              transitionsBuilder: (___,
                                  Animation<double> animation,
                                  ____,
                                  Widget child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              }));
                    }),
          Builder(
            builder: (BuildContext bcontext) {
              return PopupMenuButton(
                onSelected: onSelectOverflowItem,
                itemBuilder: (BuildContext context) {
                  return [
                    if (details != null)
                      overFlowItem(
                          Icon(
                            FontAwesomeIcons.eye,
                            size: 18,
                          ),
                          'Subscribe to thread',
                          1),
                    if (details != null &&
                        details.userId ==
                            ScopedModel.of<AuthenticationModel>(context).userId)
                      overFlowItem(
                          Icon(
                            FontAwesomeIcons.pen,
                            size: 18,
                          ),
                          'Rename thread',
                          2),
                    overFlowItem(
                        Icon(
                          Icons.content_copy,
                          size: 18,
                        ),
                        'Copy link to thread',
                        5),
                    PopupMenuItem(
                      enabled: false,
                      value: 0,
                      child: PopupMenuDivider(),
                    ),
                    overFlowItem(
                        Icon(
                          FontAwesomeIcons.undo,
                          size: 18,
                        ),
                        'Jump to first page',
                        3),
                    overFlowItem(
                        Icon(
                          FontAwesomeIcons.redo,
                          size: 18,
                        ),
                        'Jump to last page',
                        4),
                  ];
                },
              );
            },
          ),
        ],
      ),
      drawerEdgeDragWidth: 30.0,
      drawer: DrawerWidget(
        scaffoldKey: _scaffoldKey,
      ),
      key: scaffoldkey,
      body: KnockoutLoadingIndicator(
        show: _isLoading,
        child: Stack(
          children: <Widget>[
            if (details != null && details.threadBackgroundUrl != null)
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image:
                      CachedNetworkImageProvider(details.threadBackgroundUrl),
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.dstATop),
                )),
              ),
            details != null
                ? ScrollablePositionedList.builder(
                    padding: EdgeInsets.only(bottom: 66),
                    itemCount: details.posts.length,
                    itemBuilder: (context, index) {
                      ThreadPost item = details.posts[index];
                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        child: ThreadPostItem(
                          scaffoldKey: scaffoldkey,
                          thread: details,
                          currentPage: _currentPage,
                          postDetails: item,
                          isOnReplyList: postsToReplyTo
                                  .where((o) => o.id == item.id)
                                  .length >
                              0,
                          onPressReply: (post) => onPressReply(post, context),
                          onLongPressReply: (post) =>
                              onLongPressReply(post, context),
                          onPostRated: () {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Post rated!'),
                              behavior: SnackBarBehavior.floating,
                            ));
                            refreshPage();
                          },
                          onTapEditPost: (ThreadPost post) =>
                              onTapEditPost(context, post),
                        ),
                      );
                    },
                    itemScrollController: scrollController,
                    itemPositionsListener: itemPositionListener,
                    didAttach:
                        (ScrollController scrollControllerFromListView) async {
                      scrollControllerFromListView.addListener(() {
                        if (scrollControllerFromListView
                                .position.userScrollDirection ==
                            ScrollDirection.reverse) {
                          if (expandController.isDismissed) {
                            print('Forward');
                            expandController.forward();
                          }
                        }
                        if (scrollControllerFromListView
                                .position.userScrollDirection ==
                            ScrollDirection.forward) {
                          if (expandController.isCompleted) {
                            print('reverse');
                            expandController.reverse();
                          }
                        }

                        if (scrollControllerFromListView.position.atEdge) {
                          expandController.reverse();
                        }
                      });

                      // The delayed if a huge stupid fucking hack, to make it work while in debug mode.
                      await Future.delayed(Duration(milliseconds: 100));
                      if (this.widget.postIdToJumpTo != null) {
                        int postIndex = details.posts.indexWhere(
                            (o) => o.id == this.widget.postIdToJumpTo);
                        scrollController.jumpTo(
                            index: postIndex == -1 ? 0 : postIndex);
                      }
                    },
                    onScroll: (ScrollPosition position) async {},
                  )
                : Container(),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: SizeTransition(
        axisAlignment: -1.0,
        sizeFactor: animation,
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            height: 56,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text('Page ' +
                      _currentPage.toString() +
                      ' of ' +
                      _totalPages.toString()),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: _currentPage == 1 ? null : navigateToPrevPage,
                ),
                IconButton(
                  onPressed: _totalPages > 1 ? showJumpDialog : null,
                  icon: Icon(Icons.redo),
                  tooltip: 'Jump to page',
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed:
                      _totalPages == _currentPage ? null : navigateToNextPage,
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ScaleTransition(
        scale: animation,
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewPostScreen(
                  thread: details,
                  replyList: postsToReplyTo,
                ),
              ),
            );

            if (result != null) {
              scaffoldkey.currentState.showSnackBar(SnackBar(
                content: Text('Posted!'),
                behavior: SnackBarBehavior.floating,
              ));
              await refreshPage();
              /*scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);*/
            }
          },
        ),
      ),
    );
  }
}
