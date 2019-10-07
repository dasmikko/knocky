import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:hive/hive.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/hiveHelper.dart';
import 'package:knocky/models/syncData.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/state/appState.dart';
import 'package:knocky/widget/Drawer.dart';
import 'package:knocky/widget/Subscription/SubscriptionListItem.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:knocky/state/subscriptions.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/events.dart';

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
  void afterFirstLayout(BuildContext context) async {
    Box box = await AppHiveBox.getBox();
    if (await box.get('isLoggedIn') == true) {
      loadSubscriptions();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadSubscriptions() async {
    ScopedModel.of<SubscriptionModel>(context).getSubscriptions(
        errorCallback: () {
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Failed to get subscriptions. Try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
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

  void onLongPressItem(ThreadAlert item) {
    showJumpDialog(context, item);
  }

  void showJumpDialog(BuildContext context, ThreadAlert item) {
    int totalPages = (item.threadPostCount / 20).ceil();
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: 1,
            maxValue: totalPages,
            title: new Text("Jump to page"),
            initialIntegerValue: 1,
          );
        }).then((int value) {
      if (value != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThreadScreen(
              title: item.threadTitle,
              postCount: item.threadPostCount,
              threadId: item.threadId,
              page: value,
            ),
          ),
        );
      }
    });
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
          postIdToJumpTo: item.firstUnreadId,
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
    var alerts =
        ScopedModel.of<SubscriptionModel>(context, rebuildOnChange: true)
            .subscriptions;
    bool fetching =
        ScopedModel.of<SubscriptionModel>(context, rebuildOnChange: true)
            .isFetching;

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
        title: Text('Subscriptions'),
      ),
      drawer: DrawerWidget(),
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
                onLongPress: onLongPressItem,
                onUnsubscribe: () => onTapUnsubscribe(context, item),
              );
            },
          ),
        ),
      ),
    );
  }
}
