import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/ThreadPostItem.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';

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
    
    // Check if last read is null
    if (details.readThreadLastSeen == null) {
      //print('Is null! Mark thread as read');
      KnockoutAPI().readThreads(lastPostDate, details.id).then((res) {
        //print('Thread marked read!');
      });
    } else if (details.readThreadLastSeen.isBefore(lastPostDate)) {
      //print('last read date is before last post date! Mark thread as read');
      KnockoutAPI().readThreads(lastPostDate, details.id).then((res) {
        //print('Thread marked read!');
      });
    } else { 
      //print('All is fine, do not mark as read');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      key: scaffoldkey,
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
                icon: Icon(Icons.chevron_right),
                onPressed:
                    _totalPages == _currentPage ? null : navigateToNextPage,
              )
            ],
          ),
        ),
      ),
    );
  }
}
