import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widget/SubscriptionListItem.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with AfterLayoutMixin<SubscriptionScreen> {
  List<ThreadAlert> alerts = List();
  bool fetching = false;

  @override
  void afterFirstLayout(BuildContext context) {
    loadSubscriptions();
  }

  Future<void> loadSubscriptions() {
    setState(() {
      fetching = true;
    });

    return KnockoutAPI().getAlerts().then((List<ThreadAlert> res) {
      setState(() {
        alerts = res;
        fetching = false;
      });
    });
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

  void onTapUnsubscribe(ThreadAlert item) {
    KnockoutAPI().deleteThreadAlert(item.threadId).then((val) {
      loadSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriptions'),
      ),
      body: RefreshIndicator(
        onRefresh: loadSubscriptions,
        child: fetching
            ? KnockoutLoadingIndicator()
            : ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (BuildContext context, int index) {
                  ThreadAlert item = alerts[index];
                  return SubscriptionListItem(
                    item: item,
                    onTapItem: onTapItem,
                    onTapNewPostButton: onTapNewPostsButton,
                    onUnsubscribe: () => onTapUnsubscribe(item),
                  );
                },
              ),
      ),
    );
  }
}
