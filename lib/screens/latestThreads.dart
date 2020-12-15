import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky_edge/helpers/api.dart';
import 'package:knocky_edge/models/subforumDetails.dart';
import 'package:knocky_edge/models/syncData.dart';
import 'package:knocky_edge/models/threadAlert.dart';
import 'package:knocky_edge/screens/thread.dart';
import 'package:knocky_edge/state/appState.dart';
import 'package:knocky_edge/widget/Drawer.dart';
import 'package:knocky_edge/widget/SubforumPopularLatestDetailListItem.dart';
import 'package:knocky_edge/widget/KnockoutLoadingIndicator.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
          page: item.lastPost.page,
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
          threadId: item.threadId,
          page: item.lastPost.page,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<SyncDataMentionModel> mentions =
        ScopedModel.of<AppStateModel>(context, rebuildOnChange: true).mentions;

    return Scaffold(
      key: _scaffoldKey,
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
      drawer: DrawerWidget(
        scaffoldKey: _scaffoldKey,
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
