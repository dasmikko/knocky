import 'package:flutter/material.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/screens/thread.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/widget/InkWellOnWidget.dart';

class SubforumDetailListItem extends StatelessWidget {
  final SubforumThread threadDetails;

  SubforumDetailListItem({this.threadDetails});

  void onTapNewPostsButton(BuildContext context, SubforumThread item) {
    double pagenumber =
        (item.postCount - (item.readThreadUnreadPosts - 1)) / 20;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadScreen(
              title: item.title,
              postCount: item.postCount,
              threadId: item.id,
              page: pagenumber.ceil(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String _iconUrl = iconList
        .firstWhere((IconListItem item) => item.id == threadDetails.iconId)
        .url;

    return Card(
      color: threadDetails.pinned == 1 ? Colors.green : null,
      margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
      child: InkWell(
        onTap: () {
          print('Clicked item ' + threadDetails.id.toString());

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadScreen(
                    title: threadDetails.title,
                    postCount: threadDetails.postCount,
                    threadId: threadDetails.id,
                  ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10.0),
                child: CachedNetworkImage(
                  imageUrl: _iconUrl,
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: threadDetails.readThreadUnreadPosts > 0 ? 10 : 0),
                        child: Text(threadDetails.title),
                      ),
                      if (threadDetails.readThreadUnreadPosts > 0)
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWellOverWidget(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  color: Color.fromRGBO(255, 201, 63, 1),
                                  child: Text(
                                    '${threadDetails.readThreadUnreadPosts} new posts',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                onTap: () {
                                  onTapNewPostsButton(context, threadDetails);
                                },
                              )),
                        ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
