import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky_edge/helpers/api.dart';
import 'package:knocky_edge/models/syncData.dart';
import 'package:knocky_edge/models/threadAlert.dart';
import 'package:knocky_edge/screens/thread.dart';
import 'package:knocky_edge/state/appState.dart';
import 'package:knocky_edge/widget/Drawer.dart';
import 'package:knocky_edge/widget/Subscription/SubscriptionListItem.dart';
import 'package:knocky_edge/widget/KnockoutLoadingIndicator.dart';
import 'package:knocky_edge/state/subscriptions.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:knocky_edge/events.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with AfterLayoutMixin<SubscriptionScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') == true) {
      loadSubscriptions();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadSubscriptions() async {
    if (ScopedModel.of<SubscriptionModel>(context).subscriptions.length == 0) {
      ScopedModel.of<SubscriptionModel>(context)
          .getSubscriptions(errorCallback: () {});
    }
  }

  Future<void> forceLoadSubscriptions() async {
    ScopedModel.of<SubscriptionModel>(context).getSubscriptions(
        errorCallback: (error) {
      print('Error getting subscriptions');
      print(error);
    });
  }

  void onTapItem(ThreadAlert item) {
    print('Thread id' + item.threadId.toString());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadScreen(
          title: item.threadTitle,
          postCount: item.threadPostCount,
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
    int pagenumber =
        ((item.threadPostCount - (item.unreadPosts - 1)) / 20).ceil();

    print(pagenumber);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadScreen(
          title: item.threadTitle,
          page: pagenumber,
          threadId: item.threadId,
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
      forceLoadSubscriptions();
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
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Subscriptions'),
      ),
      drawerEdgeDragWidth: 30.0,
      drawer: DrawerWidget(
        scaffoldKey: _scaffoldKey,
      ),
      body: RefreshIndicator(
        onRefresh: forceLoadSubscriptions,
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
