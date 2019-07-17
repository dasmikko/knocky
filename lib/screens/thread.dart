import 'package:flutter/material.dart';
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
    with AfterLayoutMixin<ThreadScreen> {
  Thread details;
  int _currentPage;
  int _totalPages = 0;
  bool _isLoading = true;
  final scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentPage = this.widget.page;

    _totalPages = (widget.postCount / 20).ceil();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    var api = new KnockoutAPI();
    // Calling the same function "after layout" to resolve the issue.
    api.getThread(widget.threadId, page: _currentPage).then((res) {
      setState(() {
        details = res;
        _isLoading = false;
      });
      checkIfShouldMarkThreadRead();
    });
  }

  void checkIfShouldMarkThreadRead() {
    DateTime lastPostDate = details.posts.last.createdAt;

    if (details.isSubscribedTo == 0) {
      // Check if last read is null
      if (details.readThreadLastSeen == null) {
        print('Is null! Mark thread as read');
        KnockoutAPI().readThreads(lastPostDate, details.id).then((res) {
          //print('Thread marked read!');
        });
      } else if (details.readThreadLastSeen.isBefore(lastPostDate)) {
        print('last read date is before last post date! Mark thread as read');
        KnockoutAPI().readThreads(lastPostDate, details.id).then((res) {
          print('Thread marked read!');
        });
      }
    } else {
      // Handle for subscribed thread
      // Check if last read is null
      if (details.subscriptionLastSeen == null) {
        print('Is null! Mark thread as read');
        KnockoutAPI().readThreads(lastPostDate, details.id).then((res) {
          //print('Thread marked read!');
        });
      } else if (details.subscriptionLastSeen.isBefore(lastPostDate)) {
        print('last read date is before last post date! Mark thread as read');
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

    var api = new KnockoutAPI();

    api.getThread(widget.threadId, page: _currentPage).then((res) {
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

    var api = new KnockoutAPI();

    api.getThread(widget.threadId, page: _currentPage).then((res) {
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

    var api = new KnockoutAPI();

    api.getThread(widget.threadId, page: _currentPage).then((res) {
      setState(() {
        details = res;
        _isLoading = false;
      });
      checkIfShouldMarkThreadRead();
    });
  }

  void refreshPage() {
    KnockoutAPI().getThread(widget.threadId, page: _currentPage).then((res) {
      setState(() {
        details = res;
        _isLoading = false;
      });
    });
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
    ;
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

  @override
  Widget build(BuildContext context) {
    final _isLoggedIn = ScopedModel.of<AuthenticationModel>(context).isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.title),
        actions: <Widget>[
          if (_isLoggedIn)
            Builder(
              builder: (BuildContext bcontext) {
                return IconButton(
                  tooltip: 'Subscribe to thread',
                  icon: Icon(FontAwesomeIcons.eye),
                  onPressed:
                      details != null ? () => onTapSubscribe(bcontext) : null,
                );
              },
            ),
        ],
      ),
      key: scaffoldkey,
      drawer: DrawerWidget(),
      body: _isLoading
          ? KnockoutLoadingIndicator()
          : ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: details.posts.length,
              itemBuilder: (BuildContext context, int index) {
                ThreadPost item = details.posts[index];
                return ThreadPostItem(
                  scaffoldKey: scaffoldkey,
                  postDetails: item,
                  onPostRated: () {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Post rated!'),
                      behavior: SnackBarBehavior.floating,
                    ));
                    refreshPage();
                  },
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          height: 56,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('Page: ' +
                    _currentPage.toString() +
                    ' / ' +
                    _totalPages.toString()),
              ),
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: _currentPage == 1 ? null : navigateToPrevPage,
              ),
              IconButton(
                onPressed: showJumpDialog,
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewPostScreen()),
          );
        },
      ),
    );
  }
}
