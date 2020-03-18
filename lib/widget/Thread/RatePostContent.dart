import 'package:flutter/material.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/helpers/api.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RatePostContent extends StatefulWidget {
  final int postId;
  final BuildContext buildContext;
  final Function onPostRated;

  RatePostContent({this.buildContext, this.postId, this.onPostRated});

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