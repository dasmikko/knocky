import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widget/Subscription/SubscriptionListItem.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:knocky/state/subscriptions.dart';
import 'package:scoped_model/scoped_model.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with AfterLayoutMixin<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    loadSubscriptions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future <void> loadSubscriptions() async {
    return ScopedModel.of<SubscriptionModel>(context).getSubscriptions().asFuture();
  }

  void onTapItem(ThreadAlert item) {
    print('onTapItem');
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

  void onTapUnsubscribe(BuildContext bcontext, ThreadAlert item) {
    KnockoutAPI().deleteThreadAlert(item.threadId).then((val) {
      Scaffold.of(bcontext).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Removed subscription'),
      ));
      loadSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    var alerts = ScopedModel.of<SubscriptionModel>(context, rebuildOnChange: true).subscriptions;
    bool fetching = ScopedModel.of<SubscriptionModel>(context, rebuildOnChange: true).isFetching;

    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriptions'),
      ),
      body: RefreshIndicator(
          onRefresh: loadSubscriptions,
          child: KnockoutLoadingIndicator(
            show: fetching,
            child: ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (BuildContext context, int index) {
                ThreadAlert item = alerts[index];
                return SubscriptionListItem(
                  item: item,
                  onTapItem: onTapItem,
                  onTapNewPostButton: onTapNewPostsButton,
                  onUnsubscribe: () => onTapUnsubscribe(context, item),
                );
              },
            ),
          )),
    );
  }
}
