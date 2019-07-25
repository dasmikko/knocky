import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widget/SubforumPopularLatestDetailListItem.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';

class LatestThreadsScreen extends StatefulWidget {
  @override
  _LatestThreadsScreenState createState() => _LatestThreadsScreenState();
}

class _LatestThreadsScreenState extends State<LatestThreadsScreen>
    with AfterLayoutMixin<LatestThreadsScreen> {
  List<SubforumThreadLatestPopular> items = List();
  bool fetching = false;
  StreamSubscription<List<SubforumThreadLatestPopular>> _dataSub;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    loadThreads();
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    super.dispose();
  }

  Future<void> loadThreads() {
    setState(() {
      fetching = true;
    });

    Future _future = KnockoutAPI().latestThreads().then((res) {
      setState(() {
        items = res;
        fetching = false;
      });
    }).catchError((error) {
      setState(() {
        fetching = false;
      });

      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Failed to get latest threads. Try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    });

    return _future;
  }

  void onTapItem(ThreadAlert item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadScreen(
          title: item.threadTitle,
          postCount: item.lastPost.thread.postCount,
          threadId: item.threadId,
        ),
      ),
    );
  }

  void onTapNewPostsButton(ThreadAlert item) {
    double pagenumber = (item.threadPostCount - (item.unreadPosts - 1)) / 20;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadScreen(
          title: item.threadTitle,
          postCount: item.lastPost.thread.postCount,
          threadId: item.threadId,
          page: pagenumber.ceil(),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latest threads'),
      ),
      body: RefreshIndicator(
          onRefresh: loadThreads,
          child: KnockoutLoadingIndicator(
            show: fetching,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                SubforumThreadLatestPopular item = items[index];
                return SubforumPopularLatestDetailListItem(
                  threadDetails: item,
                );
              },
            ),
          )),
    );
  }
}
