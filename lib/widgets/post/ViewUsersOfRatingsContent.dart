import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/models/thread.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    return ListView(
      children: this
          .widget
          .ratings
          .map(
            (o) => StickyHeader(
              header: Container(
                padding: EdgeInsets.all(12),
                color: AppColors(context).ratingsListUserHeader(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 18),
                      child: ExtendedImage.network(
                        ratingIconMap[o.rating].url,
                        height: 32,
                        width: 32,
                      ),
                    ),
                    Text(
                      ratingIconMap[o.rating].name + ' x ${o.users.length}',
                    ),
                  ],
                ),
              ),
              content: Container(
                margin: EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: o.users
                      .map(
                        (user) => Container(
                          padding:
                              EdgeInsets.only(bottom: 12, left: 12, right: 12),
                          child: Text(user),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
