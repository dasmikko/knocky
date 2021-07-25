import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/userProfile.dart';
import 'package:knocky/models/userProfileDetails.dart';
import 'package:knocky/models/userProfileRatings.dart';
import 'package:knocky/widgets/profile/ratings.dart';
import 'package:knocky/widgets/shared/avatar.dart';
import 'package:knocky/widgets/shared/background.dart';
import 'package:knocky/widgets/shared/usergroup.dart';
import 'package:knocky/widgets/shared/username.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfileRatings ratings;
  final UserProfile profile;
  final UserProfileDetails details;

  ProfileHeader(
      {@required this.profile, @required this.ratings, @required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 208,
        child: Stack(fit: StackFit.expand, children: [
          Background(backgroundUrl: profile?.backgroundUrl),
          gradientOverlay(),
          Container(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Stack(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Avatar(
                      avatarUrl: profile?.avatarUrl, isBanned: profile?.banned),
                  headerLabels(context)
                ]),
                ProfileRatings(ratings: ratings)
              ]))
        ]));
  }

  Widget headerLabels(BuildContext context) {
    return Expanded(
        child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Username(
                  username: profile.username,
                  usergroup: profile.usergroup,
                  bold: true,
                  banned: profile?.banned,
                  fontSize: 26),
              UsergroupLabel(
                  usergroup: profile.usergroup,
                  banned: profile?.banned,
                  joinDate: profile.joinDate),
              Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Text(details?.bio,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color.fromRGBO(255, 255, 255, 0.6))))
            ])));
  }

  Widget gradientOverlay() {
    return Container(
        alignment: Alignment.bottomCenter,
        child: Container(
            height: 64,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.75)],
            ))));
  }
}
