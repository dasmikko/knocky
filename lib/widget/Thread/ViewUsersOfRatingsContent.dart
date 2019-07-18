import 'package:flutter/material.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/helpers/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/models/thread.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:knocky/helpers/colors.dart';

class ViewUsersOfRatingsContent extends StatefulWidget {
  final List<ThreadPostRatings> ratings;
  final BuildContext buildContext;

  ViewUsersOfRatingsContent({this.buildContext, this.ratings});

  @override
  _ViewUsersOfRatingsContentState createState() =>
      _ViewUsersOfRatingsContentState();
}

class _ViewUsersOfRatingsContentState extends State<ViewUsersOfRatingsContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: Text(
              'Ratings',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView(
              children: this
                  .widget
                  .ratings
                  .map(
                    (o) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          StickyHeader(
                            header: Container(
                              padding: EdgeInsets.all(12),
                              color: AppColors(context).ratingsListUserHeader(),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 20),
                                    child: CachedNetworkImage(
                                      imageUrl: ratingsIconList
                                          .where((i) => i.id == o.rating)
                                          .first
                                          .url,
                                    ),
                                  ),
                                  Text(ratingsIconList
                                          .where((i) => i.id == o.rating)
                                          .first
                                          .name +
                                      ' x${o.users.length}'),
                                ],
                              ),
                            ),
                            content: Container(
                              margin: EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: o.users
                                    .map(
                                      (user) => Container(
                                        padding: EdgeInsets.only(bottom: 12, left: 12, right: 12),
                                        child: Text(user),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
