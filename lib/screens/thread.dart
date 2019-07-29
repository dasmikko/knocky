import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/api.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/Thread/ThreadPostItem.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:knocky/widget/Drawer.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/screens/newPost.dart';

class ThreadScreen extends StatefulWidget {
  final String title;
  final int postCount;
  final int threadId;
  final int page;

  ThreadScreen({this.title, this.page = 1, this.postCount, this.threadId});

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
  ScrollController scrollController = ScrollController();
  StreamSubscription<Thread> _dataSub;
  bool _bottomBarVisible = true;
  AnimationController expandController;
  Animation<double> animation;
  BuildContext self;
  List<ThreadPost> postsToReplyTo = List();

  @override
  void initState() {
    super.initState();
    _currentPage = this.widget.page;

    _totalPages = (widget.postCount / 20).ceil();

    prepareAnimations();

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_bottomBarVisible) {
          setState(() {
            expandController.forward();
            _bottomBarVisible = false;
          });
        }
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_bottomBarVisible) {
          setState(() {
            expandController.reverse();
            _bottomBarVisible = true;
          });
        }
      }

      if (scrollController.position.atEdge) {
        expandController.reverse();
      }
    });
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

  void checkIfShouldMarkThreadRead() {
    DateTime lastPostDate = details.posts.last.createdAt;

    // Check if last read is null
    if (details.readThreadLastSeen == null) {
      KnockoutAPI().readThreads(lastPostDate, details.id).then((res) {});
    } else if (details.readThreadLastSeen.isBefore(lastPostDate)) {
      KnockoutAPI().readThreads(lastPostDate, details.id).then((res) {});
    }

    if (details.isSubscribedTo != 0) {
      // Handle for subscribed thread
      // Check if last read is null
      if (details.subscriptionLastSeen == null) {
        KnockoutAPI().readThreads(lastPostDate, details.id).then((res) {});
      } else if (details.subscriptionLastSeen.isBefore(lastPostDate)) {
        KnockoutAPI()
            .readThreadSubsciption(lastPostDate, details.id)
            .then((res) {
          print('Subscribed Thread marked read!');
        });
      }
    }
  }

  void navigateToNextPage() {
    setState(() {
      _isLoading = true;
      _currentPage = _currentPage + 1;
    });

    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }

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

    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }

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

    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }

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
    print('Finish refreshing');
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

  void onPressReply(ThreadPost post) async {
    if (postsToReplyTo.length > 0) {
      onLongPressReply(post);
    } else {
      List<ThreadPost> reply = List();
      reply.add(
        new ThreadPost(
            bans: post.bans,
            content: post.content,
            createdAt: post.createdAt,
            id: post.id,
            ratings: post.ratings,
            user: post.user),
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
        scrollController.jumpTo(scrollController.positions.length.toDouble());
      }
    }
  }

  void onLongPressReply(ThreadPost post) {
    if (postsToReplyTo.where((o) => o.id == post.id).length > 0) {
      setState(() {
        postsToReplyTo.removeWhere((o) => o.id == post.id);

        Scaffold.of(context)
            .hideCurrentSnackBar(reason: SnackBarClosedReason.hide);
        Scaffold.of(context).showSnackBar(SnackBar(
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

        Scaffold.of(context)
            .hideCurrentSnackBar(reason: SnackBarClosedReason.hide);
        Scaffold.of(context).showSnackBar(SnackBar(
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

  void onSelectOverflowItem(int item) {
    switch (item) {
      case 1:
        onTapSubscribe(context);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final _isLoggedIn = ScopedModel.of<AuthenticationModel>(context).isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.title),
        actions: <Widget>[
          Builder(
            builder: (BuildContext bcontext) {
              return PopupMenuButton(
                onSelected: onSelectOverflowItem,
                itemBuilder: (BuildContext context) {
                  return [
                    if (details != null)
                      overFlowItem(
                          Icon(FontAwesomeIcons.eye), 'Subscribe to thread', 1),
                  ];
                },
              );
            },
          ),
        ],
      ),
      key: scaffoldkey,
      body: KnockoutLoadingIndicator(
        show: _isLoading,
        child: details != null
            ? CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  if (postsToReplyTo.length > 0)
                    SliverAppBar(
                      title: Text('Replying to ${postsToReplyTo.length} posts'),
                      automaticallyImplyLeading: false,
                      floating: true,
                      actions: <Widget>[
                        IconButton(
                            tooltip: 'Clear selected replies',
                            icon: Icon(FontAwesomeIcons.eraser),
                            onPressed: () {
                              setState(() {
                                postsToReplyTo = List();
                              });
                            }),
                      ],
                    ),
                  SliverList(
                    // Use a delegate to build items as they're scrolled on screen.
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        ThreadPost item = details.posts[index];
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          child: ThreadPostItem(
                            scaffoldKey: scaffoldkey,
                            postDetails: item,
                            isOnReplyList: postsToReplyTo
                                    .where((o) => o.id == item.id)
                                    .length >
                                0,
                            onPressReply: onPressReply,
                            onLongPressReply: onLongPressReply,
                            onPostRated: () {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('Post rated!'),
                                behavior: SnackBarBehavior.floating,
                              ));
                              refreshPage();
                            },
                          ),
                        );
                      },
                      // Builds 1000 ListTiles
                      childCount: details.posts.length,
                    ),
                  ),
                ],
              )
            : Container(),
      ),
      extendBody: false,
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
              print('Do the scroll');
              scrollController
                  .jumpTo(scrollController.positions.length.toDouble());
            }
          },
        ),
      ),
    );
  }
}
