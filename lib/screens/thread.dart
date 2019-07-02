import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/ThreadPostItem.dart';

class ThreadScreen extends StatefulWidget {
  final SubforumThread threadModel;

  ThreadScreen({this.threadModel});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen>
    with AfterLayoutMixin<ThreadScreen> {
  Thread details;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  final scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _totalPages = (widget.threadModel.postCount / 20).ceil();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    var api = new KnockoutAPI();
    // Calling the same function "after layout" to resolve the issue.
    api.getThread(widget.threadModel.id).then((res) {
      setState(() {
        details = res;
        _isLoading = false;
      });
    });
  }

  void navigateToNextPage() {
    setState(() {
      _isLoading = true;
      _currentPage = _currentPage + 1;
    });

     var api = new KnockoutAPI();

    api.getThread(widget.threadModel.id, page: _currentPage).then((res) {
      setState(() {
        details = res;
        _isLoading = false;
      });
    });
  }

  void navigateToPrevPage() {
    setState(() {
      _isLoading = true;
      _currentPage = _currentPage - 1;
    });

    var api = new KnockoutAPI();

    api.getThread(widget.threadModel.id, page: _currentPage).then((res) {
      setState(() {
        details = res;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.threadModel.title)),
      key: scaffoldkey,
      body: _isLoading
          ? Text('Node graph out of date')
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
