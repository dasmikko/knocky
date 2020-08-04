import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky_edge/helpers/api.dart';
import 'package:knocky_edge/models/events.dart';
import 'package:knocky_edge/models/subforumDetails.dart';
import 'package:knocky_edge/models/threadAlert.dart';
import 'package:knocky_edge/screens/thread.dart';
import 'package:knocky_edge/widget/Events/EventsListItem.dart';
import 'package:knocky_edge/widget/KnockoutLoadingIndicator.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with AfterLayoutMixin<EventsScreen> {
  List<KnockoutEvent> items = List();
  bool fetching = false;
  StreamSubscription<List<SubforumThreadLatestPopular>> _dataSub;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    loadEvents();
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    super.dispose();
  }

  Future<void> loadEvents() {
    setState(() {
      fetching = true;
    });

    Future _future = KnockoutAPI().getEvents().then((res) {
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
        content: Text('Failed to get events. Try again.'),
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
        title: Text('Events'),
      ),
      body: RefreshIndicator(
        onRefresh: loadEvents,
        child: KnockoutLoadingIndicator(
          show: fetching,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              KnockoutEvent item = items[index];
              return EventsListItem(
                content: item.content,
              );
            },
          ),
        ),
      ),
    );
  }
}
