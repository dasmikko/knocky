import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:knocky/screens/thread.dart';

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
          String iconUrl =
              iconList.where((icon) => icon.id == item.iconId).first.url;

          return Card(
            color: Color.fromRGBO(45, 45, 48, 1),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CachedNetworkImage(
                          width: 25,
                          imageUrl: iconUrl,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      color: Color.fromRGBO(34, 34, 38, 1),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onTapItem(item),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: Text(item.threadTitle),
                                ),
                                if (item.unreadPosts > 0)
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        color: Color.fromRGBO(255, 201, 63, 1),
                                        child: Text(
                                          '${item.unreadPosts} new posts',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                Text(
                                  item.threadUsername,
                                  style: TextStyle(color: Colors.blue),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 130,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 4),
                          child: Text(
                              item.lastPost.thread.postCount.toString() +
                                  ' replies'),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 4),
                          child: Text(
                            timeago.format(item.createdAt),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 4),
                          child: Text(
                            item.lastPost.user.username,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 4),
                          child: Text(timeago.format(item.lastPost.createdAt)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
