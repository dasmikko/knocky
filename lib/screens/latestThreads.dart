import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/syncData.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/state/appState.dart';
import 'package:knocky/widget/Drawer.dart';
import 'package:knocky/widget/SubforumPopularLatestDetailListItem.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:knocky/events.dart';
import 'package:scoped_model/scoped_model.dart';

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
    final List<SyncDataMentionModel> mentions =
        ScopedModel.of<AppStateModel>(context, rebuildOnChange: true).mentions;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Latest threads'),
      ),
      drawerEdgeDragWidth: 30.0,
      drawer: DrawerWidget(),
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
