import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widget/SubforumDetailListItem.dart';
import 'package:knocky/widget/SubforumPopularLatestDetailListItem.dart';
import 'package:knocky/widget/Subscription/SubscriptionListItem.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:knocky/state/subscriptions.dart';
import 'package:scoped_model/scoped_model.dart';

class PopularThreadsScreen extends StatefulWidget {
  @override
  _PopularThreadsScreenState createState() => _PopularThreadsScreenState();
}

class _PopularThreadsScreenState extends State<PopularThreadsScreen>
    with AfterLayoutMixin<PopularThreadsScreen> {
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
    super.dispose();
    _dataSub?.cancel();
  }

  Future<void> loadThreads() {
    setState(() {
      fetching = true;
    });

    _dataSub?.cancel();
    _dataSub =
        KnockoutAPI().popularThreads().asStream().listen((List<SubforumThreadLatestPopular> res) {
      setState(() {
        items = res;
        fetching = false;
      });
    });

    return _dataSub.asFuture();
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
        title: Text('Popular threads'),
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
