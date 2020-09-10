import 'package:flutter/material.dart';
import 'package:knocky_edge/helpers/icons.dart';
import 'package:knocky_edge/helpers/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky_edge/models/thread.dart';

class RatePostContent extends StatefulWidget {
  final int postId;
  final BuildContext buildContext;
  final Function onPostRated;
  final Thread thread;

  RatePostContent(
      {this.buildContext, this.postId, this.onPostRated, this.thread});

  @override
  _RatePostContentState createState() => _RatePostContentState();
}

class _RatePostContentState extends State<RatePostContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: Text(
              'Rate post',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView(
              children: ratingsIconList
                  .where((item) {
                    // Only show ratings that has no ids in allow list and those who are allowed
                    if (item.allowedSubforums == null) return true;
                    if (item.allowedSubforums != null &&
                        item.allowedSubforums
                            .contains(widget.thread.subforumId)) return true;
                    return false;
                  })
                  .map((o) => ListTile(
                        leading: CachedNetworkImage(
                          width: 22,
                          height: 22,
                          imageUrl: o.url,
                        ),
                        title: Text(o.name),
                        onTap: () {
                          KnockoutAPI()
                              .ratePost(this.widget.postId, o.id)
                              .then((res) {
                            if (this.widget.onPostRated != null) {
                              this.widget.onPostRated();
                            }
                            Navigator.pop(context);
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
