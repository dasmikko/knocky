import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widget/SubscriptionListItem.dart';

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
    setState(() {
      fetching = true;
    });

    KnockoutAPI().getAlerts().then((List<ThreadAlert> res) {
      setState(() {
        alerts = res;
        fetching = true;
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
    double pagenumber = (item.threadPostCount-(item.unreadPosts-1)) / 20;

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
        title: Text('Subscriptions'),
      ),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (BuildContext context, int index) {
          ThreadAlert item = alerts[index];
          return SubscriptionListItem(
            item: item,
            onTapItem: onTapItem,
            onTapNewPostButton: onTapNewPostsButton,
          );
        },
      ),
    );
  }
}
